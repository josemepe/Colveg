# chat/consumers.py
import json

from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async


class ChatConsumer(AsyncWebsocketConsumer):
    # async def connect(self):
    #     self.room_name = self.scope["url_route"]["kwargs"]["room_name"]
    #     self.room_group_name = f"chat_{self.room_name}"

    #     # Join room group
    #     await self.channel_layer.group_add(self.room_group_name, self.channel_name)

    #     await self.accept()

    # async def disconnect(self, close_code):
    #     # Leave room group
    #     await self.channel_layer.group_discard(self.room_group_name, self.channel_name)

    async def connect(self):
        self.room_name = 'prueba'
        # self.scope["url_route"]["kwargs"]["room_name"]
        self.room_group_name = f"chat_{self.room_name}"

        # Join room group
        await self.channel_layer.group_add(self.room_group_name, self.channel_name)

        await self.accept()

    async def disconnect(self, close_code):
        # Leave room group
        await self.channel_layer.group_discard(self.room_group_name, self.channel_name)

    async def send_message_to_group(self, event):
        message = event["message"]
        sender_id = event["senderId"]

        # Send message to WebSocket
        await self.send(text_data=json.dumps({"message": message, "senderId": sender_id}))

    # Receive message from WebSocket
    async def receive(self, text_data):
        text_data_json = json.loads(text_data)
        message = text_data_json["message"]
        sender_id = text_data_json.get("senderId")

        # Send message to room group
        await self.channel_layer.group_send(
            self.room_group_name, {"type": "chat.message", "message": message, "senderId": sender_id}
        )

    # Receive message from room group
    async def chat_message(self, event):
        message = event["message"]
        sender_id = event["senderId"]

        # Send message to WebSocket
        await self.send(text_data=json.dumps({"message": message,  "senderId": sender_id}))

    
# class CommentConsumer(AsyncWebsocketConsumer):
#     # function connect post-room
#     async def connect(self):
#         self.room_name ='comment'
#         self.room_group_name = f'comment_{self.room_name}'

#         await self.channel_layer.group_add(self.room_group_name, self.room_name)
        
#         await self.accept()

#     async def send_message_to_group(self, event):
#         message = event["comment"]

#         # Send message to WebSocket
#         await self.send(text_data=json.dumps({"comment": message}))

#     # function disconnet post-room
#     async def disconnect(self, code):
#         await self.channel_layer.group_discard(self.room_group_name, self.room_name)

#     # # function to comment post
#     # async def post_room(self, event):
#     #     comment = event['comment']
        

#     #     await self.send(text_data=json.dumps({"comment": comment}))

#     # function receive comments
#     async def receive(self, text_data):
#         text_data_json = json.loads(text_data)
#         comment = text_data_json["comment"]
        

#         # Send message to room group
#         await self.channel_layer.group_send(
#             self.room_group_name, {"type": "chat.comment", "comment": comment}
#         )


# import json
# import asgi_redis

# from channels.generic.websocket import AsyncWebsocketConsumer
# from channels.db import database_sync_to_async
# from django.conf import settings

# # Configurar el canal de capa de mensajes para usar Redis
# redis_layer = asgi_redis.RedisChannelLayer(
#     config=settings.CHANNEL_LAYERS["default"]["CONFIG"]
# )



class CommentConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_name = self.scope["url_route"]["kwargs"]["room_name"]
        self.room_group_name = f"chat_{self.room_name}"

        # Join room group
        await self.channel_layer.group_add(self.room_group_name, self.channel_name)

        await self.accept()

    async def disconnect(self, close_code):
        # Leave room group
        await self.channel_layer.group_discard(self.room_group_name, self.channel_name)

    # Receive message from WebSocket
    async def receive(self, text_data):
        text_data_json = json.loads(text_data)
        message = text_data_json["comment"]

        # Send message to room group
        await self.channel_layer.group_send(
            self.room_group_name, {"type": "chat.comment", "comment": message}
        )

    # Receive message from room group
    async def chat_comment(self, event):
        message = event["comment"]

        # Send message to WebSocket
        await self.send(text_data=json.dumps({"message":message}))


# consumer to likes
class LikeConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_name = self.scope['url_route']['kwargs']['room_name']
        self.room_group_name = f'post_{self.room_name}'

        await self.channel_layer.group_add(self.room_group_name, self.channel_name)

        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.room_group_name, self.channel_name)

    async def receive(self, text_data):
        text_data_json = json.loads(text_data)
        id = text_data_json["id"]
        like = text_data_json["like"]

        # Send message to room group
        await self.channel_layer.group_send(
            self.room_group_name, {"type": "chat.like", "id": id, "like": like}
        )
        print(id)
        print(like)

    async def chat_like(self, event):
        id = event["id"]
        like = event["like"]

        # Send message to WebSocket
        await self.send(text_data=json.dumps({"id": id, "like": like}))

