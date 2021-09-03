from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from fastapi.routing import Mount
from fastapi.staticfiles import StaticFiles

# Define routes for static content.
routes = [Mount('/static', app=StaticFiles(directory='static'), name="static")]
app = FastAPI(routes=routes)

# Use fastapi as simple webserver.
@app.get('/', response_class=HTMLResponse)
async def index():
    with open('./static/index.html') as file:
        return HTMLResponse('\n'.join(file.readlines()))
