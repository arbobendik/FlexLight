import sqlite3
import os
import time
import binascii
import base64
from fastapi import WebSocket
from interfaces import connection_manager, db


class player:
    name: str = ""
    last_response: float = time.time()
    last_vector: float = time.time()
    responsive: bool
    square_x: int
    square_y: int
    lx: int = 0
    ly: int = 0
    x: int = 0
    y: int = 0
    dx: int = 0
    dy: int = 0

    def __init__(self, this_database, ip, **kwargs):
        # Get private and public key for new player or assign provided players
        self.ip = ip
        keys = kwargs.get('keys', False)
        if not keys:
            keys = self.generate_new_keys(this_database)
        # Encrypt keys.
        self.keys = keys

    def jsonify(self, **kwargs):
        # Jsonify player without coordinates.
        if kwargs.get("nocords", False):
            return {'player': self.keys['public'], 'name': self.name, 'last_vector': self.last_vector, 'dx': self.dx, 'dy': self.dy}
        # Jsonify in default format.
        return {'player': self.keys['public'], 'name': self.name, 'last_vector': self.last_vector, 'dx': self.dx, 'dy': self.dy, 'x': self.x, 'y': self.y}

    @staticmethod
    def generate_new_keys(this_database):
        # Key generation function.
        random_key = lambda : str(binascii.hexlify(os.urandom(12)))
        keys = {}
        while True:
            # Generate new key pair.
            keys = {'private': random_key(), 'public': random_key() }
            # Check if Keys are unique and break if they are.
            if not this_database.keys_duplicate(keys):
                break
        return keys


class game:
    speed: float = 1.5
    active_players: list = {}

    def __init__(self):
        return None

    async def add_player(self, connections, socket, this_database, p):
        self.active_players[p.keys['public']] = p
        # Add p to database if unknown.
        if not this_database.player_exists(p.ip, p.keys):
            this_database.add_player(p)
        # Inform all existing players that new player has joined.
        await connections.broadcast('add_player', p.jsonify(), socket)

    async def remove_player(self, connections, socket, p):
        # Remove p from active_players dictionary and tell all other players that p is gone.
        self.active_players.pop(p.keys['public'])
        await connections.broadcast('remove_player', {'player' :p.keys['public']}, socket)

    def identify_player(self, this_database, ip, keys):
        # Encrypt keys to compare to database.
        if self.active_players[keys['public']].keys['private'] == keys['private'] and self.active_players[keys['public']].ip == ip:
            return self.active_players[keys['public']]

    def update(self, p, x, y, dx, dy, **kwargs):
        # Test if p even exists.
        if p == None:
            return False
        # Determine if player moved to fast since last test.
        test_speed = lambda x, t: x / t <= self.speed * 100
        # Test if deltaX or deltaY values are correct.
        t = round((time.time() - p.last_response)*100)/100
        # Test if movement vectors are not too large.
        test_delta = lambda x: abs(x) == self.speed or x == 0

        # Test if user should be allowed to sync position.
        if kwargs.get('asynchronous', False):
            try:
                allowed: bool = t <= 0.5 and test_delta(dx) and test_delta(dy) and test_speed(abs(p.lx-x), t) and test_speed(abs(p.ly-y), t) and p.responsive
            except ZeroDivisionError:
                allowed: bool = False
        else:
            allowed: bool = t <= 0.5 and t >= 0.49 and test_delta(dx) and test_delta(dy) and test_speed(abs(p.lx-x), t) and test_speed(abs(p.ly-y), t) and p.responsive
        # Update real positions if allowed.
        if allowed:
            # Update position.
            p.x = x
            p.y = y
            # Update last position.
            p.lx = x
            p.ly = y
        else:
            # Update last position to position before.
            p.lx = p.x
            p.ly = p.y
        # Update vector anyway.
        p.dx = dx
        p.dy = dy
        return allowed


class map:
    struct = []
    file: str

    def __init__(self, file_location):
        # Load map.
        return None

    def request_map(self, square_x, square_y):
        # Return square and all surrounding squares.
        return None


class db_interactions:
    def __init__(self, name):
        # Initialize database.
        self.db = db(name)

    def keys_duplicate(self, keys):
        # Check if object is even available.
        if keys == None:
            return False
        # Encrypt keys.
        encr_keys = self.encrypt_keys(keys.copy())
        # Execute search query to test if either private or public are already in use.
        output = self.db.execute_query('SELECT public_key FROM players WHERE private_key="{}" OR public_key="{}";'.format(encr_keys['private'], encr_keys['public']))
        # Return False if keys are not in use.
        return not (output == None)

    def player_exists(self, ip, keys):
        # Check if object is even available.
        if keys == None or ip == None:
            return False
        # Encrypt keys.
        encr_keys = self.encrypt_keys(keys.copy())
        # Test if player exists.
        output = self.db.execute_query('SELECT public_key FROM players WHERE ip="{}" AND private_key="{}" AND public_key="{}";'.format(ip, encr_keys['private'], encr_keys['public']))
        # Return False if none such player exists.
        return not (output == None)


    def add_player(self, p):
        # Encrypt keys.
        encr_keys = self.encrypt_keys(p.keys.copy())
        # Write keys and ip into database.
        self.db.execute_query('INSERT INTO players (ip, private_key, public_key, name) VALUES ("{}", "{}", "{}", "{}");'.format(p.ip, encr_keys['private'], encr_keys['public'], p.name))

    def update_position(self, p):
        # Encrypt keys.
        encr_keys = self.encrypt_keys(p.keys.copy())
        # Update position of player in database.
        self.db.execute_query('UPDATE players SET x = {}, y = {} WHERE public_key = "{}"'.format(p.x, p.y, encr_keys['public']))

    def encrypt_keys(self, keys):
        keys['private'] = self.db.encrypt(keys['private'])
        keys['public'] = self.db.encrypt(keys['public'])
        return keys

    def decrypt_keys(self, keys):
        keys['private'] = self.db.decrypt(keys['private'])
        keys['public'] = self.db.decrypt(keys['public'])
        return keys
