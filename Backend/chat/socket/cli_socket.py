import asyncio
from views import SendMensage
from websockets.sync.client import connect

def hello():
    with connect("ws://localhost:8765") as websocket:
        # name = input("¿Cual es tu nombre?")
        websocket.send(SendMensage)
        message = websocket.recv()
        print(f"Received: {message}")

hello()