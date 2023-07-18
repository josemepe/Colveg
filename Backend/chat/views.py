#se hace la importacion de librerias
from datetime import datetime
import json
from django.http import JsonResponse
from firebase_admin import firestore, storage, db
from rest_framework.views import APIView
from django.shortcuts import render
import secrets
# api para crea el chat
def prueba(request):
    return render(request, "chat/index.html")

def room(request, room_name):
    return render(request, "chat/room.html", {"room_name": room_name})

class IdChat(APIView):
    def get(self, request, name_receptro):
        try:
            author = None
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'error': 'Se requiere una token de autorización para acceder a esta función'}, status=401)

            db_collection = firestore.client()
            query = db_collection.collection('users').where('token', '==', token).get()
            for user in query:
                author = user.to_dict().get('user_name')
                image_user = user.to_dict().get('image_user')

            ref_chat = db.reference('chat')
            query_chat = ref_chat.order_by_child('author'and 'receptor').equal_to(author and name_receptro).get()


            # Obtener la información de los chats en los que el usuario es receptor
            id = None
            id_receptor = None
            for key, chat in query_chat.items():
                id = chat.get('id')
                id_receptor = chat.get('id_receptor')

            # Retornar la información del ID del chat como respuesta
            print(id)
            print(id_receptor)
            print(({'id': id, 'id_receptor': id_receptor}))
            return JsonResponse({'id': id, 'id_receptor': id_receptor}, status=200)


        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)



class CreateChat(APIView):
    # metodo get para traer informacion del chat 
    def get(self, request, createChatAuthot):
        try:
            author = None
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'error': 'Se requiere una token de autorización para acceder a esta función'}, status=401)

            db_collection = firestore.client()
            query = db_collection.collection('users').where('token', '==', token).get()
            for user in query:
                author = user.to_dict().get('user_name')
                image_user = user.to_dict().get('image_user')

            ref_chat = db.reference('chat')
            query_chat = ref_chat.order_by_child('author' and 'receptor').equal_to(createChatAuthot and author).get()

            # Obtener la información de los chats en los que el usuario es receptor
            chats = []
            for key, chat in query_chat.items():
                chats = chat.get('mensajes enviados', [])
                # chats.append({
                #     'mensajes_enviados': chats
                # })

            # Retornar la información de los chats como respuesta
            return JsonResponse({'chats': chats}, status=200)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
        # metodo post para crear el chat
    def post(self, request):
        try:
            data = json.loads(request.body)
            author = None
            token = request.headers.get('Authorization')
            print(token)
            if not token:
                return JsonResponse({'error': 'Se requiere una token de autorización para acceder a esta función'}, status=401)
            
            db_collection = firestore.client()
            query = db_collection.collection('users').where('token', '==', token).get()
            for user in query:
                author = user.to_dict().get('user_name')
                image_user = user.to_dict().get('image_user')
                tokenMensajes = user.to_dict().get('tockenMensajes')

            ref_chat = db.reference('chat')
            chat_id = secrets.token_hex(4)
            id_receptor = secrets.token_hex(4)
            # Si no se encuentra el chat, crear uno nuevo
            inicia_chat = {
                    'id': chat_id,
                    'id_receptor': id_receptor,
                    'author': author,
                    'image_author': image_user,
                    'tockenMnesajes': data.get('tokenMensajes'),
                    'receptor': data.get('receptor'),
                    'image_receptor': data.get('image_receptor'),   
                }
            ref_chat.push(inicia_chat)
            ref_chat.push({'author': data.get('receptor'),
                    'image_author': data.get('image_receptor'),
                    'tockenMnesajes': tokenMensajes,
                    'receptor': author,
                    'image_receptor':image_user,
                    'id': id_receptor,
                    'id_receptor': chat_id,
                    })
            return JsonResponse({'message': 'Chat creado exitosamente'}, status=201)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

# api para mandar mensajes 
class SendMensage(APIView):
    # metodo post para el envio de mensajes
    def post(self, request, name_receptro):
        try:
            data = json.loads(request.body)
            author = None
            token = request.headers.get('Authorization')
            print(token)
            if not token:
                return JsonResponse({'error': 'Se requiere una token de autorización para acceder a esta función'}, status=401)
            
            db_collection = firestore.client()
            query = db_collection.collection('users').where('token', '==', token).get()
            for user in query:
                author = user.to_dict().get('user_name')
                image_user = user.to_dict().get('image_user')

            ref_chat = db.reference('chat')
            # Filtrar el chat por el autor
            query_chat = ref_chat.order_by_child('author'and 'receptor').equal_to(author and name_receptro).get()
            chat_id = None
            for key, chat in query_chat.items():
                chat_id = key
            # Agregar el mensaje enviado al chat filtrado
            ref_mensajes = ref_chat.child(chat_id).child('mensajes enviados')
            mensaje = {
                'mensaje_enviado': data.get('mensaje_enviado'),
                'fecha': datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            }
            ref_mensajes.push(mensaje)
            return JsonResponse({'message': 'Mensaje enviado exitosamente'}, status=201)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
        
    def get(self, request, name_receptro):
        try:
            author = None
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'error': 'Se requiere una token de autorización para acceder a esta función'}, status=401)

            db_collection = firestore.client()
            query = db_collection.collection('users').where('token', '==', token).get()
            for user in query:
                author = user.to_dict().get('user_name')
                image_user = user.to_dict().get('image_user')

            ref_chat = db.reference('chat')

            query_chat = ref_chat.order_by_child('author'and 'receptor').equal_to(author and name_receptro).get()

            # Obtener los mensajes enviados del chat
            chat_id = None
            mensajes_enviados = []
            for key, chat in query_chat.items():
                chat_id = key
                mensajes_enviados = chat.get('mensajes enviados', [])
                

            # Retornar los mensajes enviados como respuesta
            return JsonResponse({'mensajes_enviados': mensajes_enviados}, status=200)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
        
        #api para ver los chats con los que tiene informacion
class ListChat(APIView):
        def get(self, request):
            try:
                user_name = None
                token = request.headers.get('Authorization')
                if not token:
                    return JsonResponse({'error': 'Se requiere una token de autorización para acceder a esta función'}, status=401)

                db_collection = firestore.client()
                query = db_collection.collection('users').where('token', '==', token).get()
                for user in query:
                    user_name = user.to_dict().get('user_name')

                ref_chat = db.reference('chat')
                query_chat = ref_chat.order_by_child('author').equal_to(user_name).get()

                # Obtener la información de los chats en los que el usuario es receptor
                list_chats = []
                for key, chat in query_chat.items():
                    # chat_id = key
                    receptor = chat.get('receptor')
                    author = chat.get('author')
                    list_chats.append({
                        # 'chat_id': chat_id,
                        'image_receptor': author,
                        'receptor': receptor,
                    })

                # Retornar la información de los chats como respuesta
                return JsonResponse({'list_chats': list_chats}, status=200)

            except Exception as e:
                return JsonResponse({'error': str(e)}, status=500)
        