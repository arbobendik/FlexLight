import sqlite3
import os
import base64
import json
from fastapi import WebSocket
from cryptography.fernet import Fernet


class connection_manager:
    def __init__(self):
        # Keep track of active connections.
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        print("disconnect from connection_manager")
        self.active_connections.remove(websocket)

    @staticmethod
    async def emit(event, package, websocket: WebSocket):
        # Set target event.
        package['event'] = event
        # Convert object to json.
        await websocket.send_text(json.dumps(package))

    async def broadcast(self, event, package, websocket: WebSocket):
        # Set target event.
        package['event'] = event

        for connection in self.active_connections:
            # Skip broadcasting user.
            if not connection == websocket:
                # Convert object to json.
                await connection.send_text(json.dumps(package))


class db:
    def __init__(self, name):
        # Get environment variable DB_PASS to get database password.
        key = os.environ.get('DB_PASS').encode('utf-8')
        key = base64.urlsafe_b64encode(key + bytes(32 - len(key)))
        self.__key = Fernet(key)
        # Save name as attribute.
        self.name = name
        # Create Neuron object table.
        self.execute_query(
            'CREATE TABLE IF NOT EXISTS players (ip VARCHAR, private_key VARCHAR, public_key VARCHAR, x MEDIUMINT, y MEDIUMINT, name VARCHAR);'
        )

    def encrypt(self, val):
        return self.__key.encrypt(str(val).encode())

    def decrypt(self, val):
        return self.__key.decrypt(val).decode()

    def execute_query(self, sql_query):
        # Establish connection.
        connection = sqlite3.connect(self.name)
        cursor = connection.cursor()
        # Save name as attribute.
        cursor.execute(sql_query)
        # Get output of query.
        output = cursor.fetchone()
        # Close database connection.
        connection.commit()
        # Return output of the query.
        return output