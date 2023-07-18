from django.urls import path
from .views import CreateChat, SendMensage, ListChat, IdChat
from channels.routing import ProtocolTypeRouter, URLRouter
from . import views


urlpatterns = [
    path("index/", views.prueba, name="index"),
    path("room/<str:room_name>/", views.room, name="room"),
    path("comment/<str:room_name>/", views.room, name="comment"),
    path("post/<str:room_name>/", views.room, name="post"),

    path('chat/<str:createChatAuthot>/', CreateChat.as_view(), name='chat'),
    path('chat/', CreateChat.as_view(), name='chat'),
    path('enviar/<str:name_receptro>/', SendMensage.as_view(), name='enviar'),
    path('listChats/', ListChat.as_view(), name='listChats'),
    path('id/<str:name_receptro>/', IdChat.as_view(), name='idChat')
]

# application = ProtocolTypeRouter({
#     # ... (otras configuraciones)

#     # Configuración de rutas de WebSocket
#     'websocket': URLRouter([
#         path(r'ws/chat/', ChatConsumer.as_asgi()),
#     ]),
# })

