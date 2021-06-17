from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.responses import HTMLResponse
from fastapi.routing import Mount
from fastapi.staticfiles import StaticFiles
import time
import json
# Import classes.py to keep app.py tidy.
from classes import player, game, db_interactions
# Import connection class.
from interfaces import connection_manager

# Define routes for static content.
routes = [Mount('/static', app=StaticFiles(directory='static'), name="static")]

app = FastAPI(routes=routes)
# Initialize global game and database object.
connections = connection_manager()
this_game = game()
this_database = db_interactions('players.db')


@app.get('/', response_class=HTMLResponse)
async def index():
    with open('./static/game.html') as file:
        return HTMLResponse('\n'.join(file.readlines()))


@app.get('/login', response_class=HTMLResponse)
async def login():
    return HTMLResponse('./static/login.html')


@app.websocket('/ws')
async def web_socket_endpoint(s: WebSocket):
    await connections.connect(s)
    # Wait for new API calls.
    while True:
        try:
            # Convert raw json package into usable response.
            pkg = json.loads(await s.receive_text())
            # Make API calls depending on what client. sends.
            await api[pkg['event']](pkg, s)
        except WebSocketDisconnect as e:
            # Disconnect on error.
            print('error:', e)
            break
    # Remove player on disconnect.
    print("disconnect")
    tp = None
    for key, p in this_game.active_players.items():
        if p.ip == s.client:
            tp = p
    await this_game.remove_player(connections, s, tp)
    connections.disconnect(s)


async def init(pkg, s):
    # Get user ip to prevent abuse of the session key system.
    ip = s.client
    # Test if user wants to provide keys and if these keys are valid.
    if not pkg['generate_new'] and this_database.player_exists(ip, pkg['keys']):
        tp = player(this_database, ip, keys=pkg['keys'])
    else:
        # Generate new public and private Session key for user if none is provided.
        tp = player(this_database, ip)
    # Add player to game and database.
    await this_game.add_player(connections, s, this_database, tp)
    # Send private key back to user.
    await connections.emit('init', {'name': tp.name, 'ip': tp.ip, 'keys': tp.keys}, s)
    # Initialize last_response, that it can be used to determine if player is inactive or not.
    tp.last_response = time.time()
    # Send information about all existing players to new player.
    for key, p in this_game.active_players.items():
        print(p.jsonify())
        if not p == tp:
            await connections.emit('add_player', p.jsonify(), s)


async def vector(pkg, s):
    # Get user ip to prevent abuse of the session key system.
    ip = s.client
    # Identify player by private_key and ip.
    p = this_game.identify_player(ip, pkg['keys'])
    await connections.broadcast('player_vector_change', {
        'player': p.keys['public'],
        'dx': pkg['dx'],
        'dy': pkg['dy']
    }, s)
    # Update last vector variable.
    p.last_vector = time.time()
    # Sync game.
    await sync_game(pkg, s, asynchronous=True)


async def sync_game(pkg, s, **kwargs):
    # Get user ip to prevent abuse of the session key system.
    ip = s.client
    # Identify player by private_key and ip.
    p = this_game.identify_player(ip, pkg['keys'])
    # Update player responsiveness.
    p.responsive = round((time.time() - p.last_response)*10) <= 5
    # Approve position and broadcast it to other players if allowed.
    if kwargs.get('asynchronous', False):
        this_game.update(p, pkg['x'], pkg['y'], pkg['dx'], pkg['dy'])
    else:
        this_game.update(p, pkg['x'], pkg['y'], pkg['dx'], pkg['dy'], asynchronous=True)
        # Update response timer.
        p.last_response = time.time()
    # Give information about all other players back.
    await connections.emit('sync_game', {
        'players': [op.jsonify() for keys, op in this_game.active_players.items() if not op == p]
    }, s)

# Initialize api global to handle socket communication.
api = {
    'init': init,
    'vector': vector,
    'sync_game': sync_game
}
