from Backend.asgi import websocket_application

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(websocket_application, host="0.0.0.0", port=8030)
