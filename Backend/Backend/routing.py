# chat/routing.py
from django.urls import re_path

from . import consumers

websocket_urlpatterns = [
    re_path(r'ws/chat/room/(?P<room_name>\w+)/$', consumers.ChatConsumer.as_asgi()),
    re_path(r'ws/chat/comment/(?P<room_name>\w+)/$', consumers.CommentConsumer.as_asgi()),
    re_path(r'ws/chat/post/(?P<room_name>\w+)/$', consumers.LikeConsumer.as_asgi()),
]
# from django.urls import re_path

# from . import consumers

# websocket_urlpatterns = [
#     re_path(r'ws/notificacion/', consumers.ChatConsumer.as_asgi())
# ]
