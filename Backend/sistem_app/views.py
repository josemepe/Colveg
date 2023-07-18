#se hace la importacion de librerias
from datetime import datetime
from io import BytesIO
import tempfile
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
from django.http import HttpResponse
from django.http import JsonResponse
import json
import firebase_admin
from firebase_admin import firestore
from rest_framework.views import APIView
from rest_framework import status
from rest_framework.response import Response

from .models import UserModel, FollowModel
from .serializers import FollowSerializer
import qrcode
from firebase_admin import storage
from pyfcm import FCMNotification
from firebase_admin import messaging
from firebase_admin import firestore, storage, db

# API get para los usuarios
class GetUser(APIView):
    def get(self, request, *args, **kwargs):
        try:
            # pasamos un token de autorizacion en el header
            token = request.headers.get('Authorization')

            if not token:
                return JsonResponse({'error': 'Se requiere un token de autorización para acceder a esta función'}, status=401)

            db = firestore.client()
           
            # comparamos el token del header con el de la coleccion de usuarios
            query = db.collection('users').where('token', '==', token).get()
            user_doc = None
            for user in query:
                user_doc = user

            if user_doc is None:
                return JsonResponse({'error': 'No se encontró el usuario correspondiente a este token'}, status=404)
            
            query = db.collection('users').document(user_doc.id).get()
            # agreamos los registros de la coleccion "users" en un arreglo llamado "follow_list"
            follow_list = [query.to_dict()]
            
            return JsonResponse({'usuario': follow_list}, status=201)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
# --------------------------------------------------------------------------------------------------------------------------

# API get para los seguidores
class FollowerUser(APIView):
    def get(self, request, userName):
        try:
            db = firestore.client()
            
            # Buscar el usuario por nombre de usuario
            query = db.collection('users').where('user_name', '==', userName).get()
            
            if len(query) == 0:
                return JsonResponse({'error': 'Usuario no encontrado'}, status=404)
            
            user_id = query[0].id
            
            # Obtener la lista de seguidores del usuario
            follower_list = []
            follower_query = db.collection('users').document(user_id).collection('seguidores').get()
            
            for follow_doc in follower_query:
                follower_list.append(follow_doc.to_dict())
            
            return JsonResponse({'follower_list': follower_list}, status=200)
        
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
#api para recibir un seguidor
class FollowUser(APIView):
    def get(self, request, *args, **kwargs):
        try:
            # pasamos un token de autorizacion en el header
            token = request.headers.get('Authorization')

            if not token:
                return JsonResponse({'error': 'Se requiere un token de autorización para acceder a esta función'}, status=401)

            db = firestore.client()
           
            # comparamos el token del header con el token del registro de usuarios
            query = db.collection('users').where('token', '==', token).get()
            user_doc = None
            for user in query:
                user_doc = user

            if user_doc is None:
                return JsonResponse({'error': 'No se encontró el usuario correspondiente a este token'}, status=404)
            
            follow_list = []
            query = db.collection('users').document(user_doc.id).collection('seguidos').get()
            # agregamos los registros de "seguidos" en un arreglo llamado "follow_list"
            for follow_doc in query:
                follow_list.append(follow_doc.to_dict())
            
            return JsonResponse({'follow_list': follow_list}, status=201)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
        
    def post(self, request):
        try:
            data = json.loads(request.body)
            token = request.headers.get('Authorization')

            if not token:
                return JsonResponse({'error': 'Se requiere un token de autorización para acceder a esta función'}, status=401)

            db = firestore.client()

            query = db.collection('users').where('token', '==', token).get()
            user_doc = None
            for user in query:
                author = user.to_dict().get('user_name')
                imageUser = user.to_dict().get('image_user')
                user_doc = user

            if user_doc is None:
                return JsonResponse({'error': 'No se encontró el usuario correspondiente a este token'}, status=404)

            follow_data = {
                'image_user': data.get('image_user'),
                'user_name': data.get('user_name'),
            }

            query = db.collection('users').document(user_doc.id).collection('seguidos').where('image_user', '==', follow_data['image_user']).where('user_name', '==', follow_data['user_name']).get()
            if query:
                return JsonResponse({'error': 'Ya sigues a este usuario'}, status=400)

            followed_user_id = db.collection('users').where('user_name', '==', follow_data['user_name']).get()[0].id
            followed_user_ref = db.collection('users').document(followed_user_id)

            # favorite = db.collection('users').document(user_doc.id).collection('favoritos')
            # add_favoritos = favorite.add(favorite_data)
            # produc_id = add_favoritos[1].id
            # favorite_data['id'] = produc_id
            # favorite.document(produc_id).set(favorite_data)

            seguido_collection = db.collection('users').document(user_doc.id).collection('seguidos')
            add_seguido = seguido_collection.add(follow_data)
            new_seguido_id = add_seguido[1].id
            follow_data['id'] = new_seguido_id
            seguido_collection.document(new_seguido_id).set(follow_data)

            seguidores_collection = followed_user_ref.collection('seguidores')
            new_seguidor_ref = seguidores_collection.document()
            new_seguidor_id = new_seguidor_ref.id
            new_seguidor_ref.set({'user_seguidor': author, 'image_seguidor': imageUser, 'id': new_seguidor_id})

            notificaciones_collection = followed_user_ref.collection('notificaciones')
            new_notificacion_ref = notificaciones_collection.document()
            new_notificacion_id = new_notificacion_ref.id
            new_notificacion_ref.set({'userName': author, 'image_seguidor': imageUser, 'id': new_notificacion_id})

            return JsonResponse({'message': 'Siguiendo al usuario '}, status=201)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    def delete(self, request):
        try:
            data = json.loads(request.body)
            token = request.headers.get('Authorization')

            if not token:
                return JsonResponse({'error': 'Se requiere un token de autorización para acceder a esta función'}, status=401)

            db = firestore.client()

            query = db.collection('users').where('token', '==', token).get()
            user_doc = None
            for user in query:
                author = user.to_dict().get('user_name')
                user_doc = user

            if user_doc is None:
                return JsonResponse({'error': 'No se encontró el usuario correspondiente a este token'}, status=404)

            follow_data = {
                'image_user': data.get('image_user'),
                'user_name': data.get('user_name'),
            }

            query = db.collection('users').document(user_doc.id).collection('seguidos').where('image_user', '==', follow_data['image_user']).where('user_name', '==', follow_data['user_name']).get()
            if not query:
                return JsonResponse({'error': 'No sigues a este usuario'}, status=400)

            # Obtener el documento de seguimiento y eliminarlo
            for follow_doc in query:
                db.collection('users').document(user_doc.id).collection('seguidos').document(follow_doc.id).delete()
                followed_user_id = db.collection('users').where('user_name', '==', follow_data['user_name']).get()[0].id
                print(followed_user_id)
                followed_user_id_seuidores = db.collection('users').document(followed_user_id).collection('seguidores').where('user_seguidor', '==', author).get()[0].id
                print(followed_user_id_seuidores)
                db.collection('users').document(followed_user_id).collection('seguidores').document(followed_user_id_seuidores).delete()
                # followed_user_ref.collection('seguidores').where('user_seguidor', '==', author).delete()

            return JsonResponse({'message': 'Dejaste de seguir al usuario '}, status=201)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

class FollowerUser(APIView):
    def get(self, request, *args, **kwargs):
        try:
            token = request.headers.get('Authorization')

            if not token:
                return JsonResponse({'error': 'Se requiere un token de autorización para acceder a esta función'}, status=401)

            db = firestore.client()
            
            query = db.collection('users').where('token', '==', token).get()
            user_doc = None
            for user in query:
                user_doc = user
            
            if user_doc is None:
                return JsonResponse({'error': 'No se encontró el usuario correspondiente a este token'}, status=404)
            
            follower_list = []
            query = db.collection('users').document(user_doc.id).collection('seguidores').get()

            for follow_doc in query:
                follower_list.append(follow_doc.to_dict())

            return JsonResponse({'follower_list': follower_list}, status=201)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
        
class CreateFavorite(APIView):
    def get(self, request):
        try:
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'error': 'Se requiere una token de autorización para acceder a esta función'}, status=401)

            db = firestore.client()
            query = db.collection('users').where('token', '==', token).get()
            print(token)
            user_doc = None
            for user in query:
                user_doc = user

            if user_doc is None:
                return JsonResponse({'error': 'No se encontró el usuario correspondiente a esta token'}, status=404)

            # Obtener todas las publicaciones favoritas del usuario correspondiente
            favorites_query = db.collection('users').document(user_doc.id).collection('favoritos').get()
            favorites = []
            for favorite in favorites_query:
                favorites.append(favorite.to_dict())

            return JsonResponse({'favorites': favorites}, status=200)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
        
    def post(self, request):
        try:
            data = json.loads(request.body)
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'error': 'Se requiere una token de autorización para acceder a esta función'}, status=401)
            
            db = firestore.client()
            query = db.collection('users').where('token', '==', token).get()
            user_doc = None
            for user in query:
                user_doc = user

            if user_doc is None:
                return JsonResponse({'error': 'No se encontró el usuario correspondiente a esta token'}, status=404)
            
            # Crear un documento para la publicación favorita en la subcolección 'favoritos' del usuario correspondiente
            favorite_data = {
                'image_user': data.get('image_user'),
                'name': data.get('name'),
                'author': data.get('author'),
                'pk': data.get('pk')
            }
            favorites_query = db.collection('users').document(user_doc.id).collection('favoritos').where('name', '==', favorite_data['name']).where('author', '==', favorite_data['author']).where('pk', '==', favorite_data['pk']).get()
            if favorites_query:
                return JsonResponse({'error': 'Esta publicación ya está guardada como favorita'}, status=400)
            
            favorite = db.collection('users').document(user_doc.id).collection('favoritos')
            add_favoritos = favorite.add(favorite_data)
            produc_id = add_favoritos[1].id
            favorite_data['id'] = produc_id
            favorite.document(produc_id).set(favorite_data)
            print(produc_id)

            return JsonResponse({'message': 'Publicación guardada como favorita correctamente'}, status=201)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
        
    def delete(self, request, id):
        try:
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'error': 'Se requiere una token de autorización para acceder a esta función'}, status=401)

            db = firestore.client()
            query = db.collection('users').where('token', '==', token).get()
            user_doc = None
            for user in query:
                user_doc = user

            if user_doc is None:
                return JsonResponse({'error': 'No se encontró el usuario correspondiente a esta token'}, status=404)

            # Eliminar la publicación favorita con el id especificado de la subcolección 'favoritos' del usuario correspondiente
            favorite_doc = db.collection('users').document(user_doc.id).collection('favoritos').document(id)
            if not favorite_doc.get().exists:
                return JsonResponse({'error': 'No se encontró la publicación favorita correspondiente'}, status=404)
            
            favorite_doc.delete()

            return JsonResponse({'message': 'Publicación eliminada de favoritos correctamente'}, status=200)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

#api para borrar una publicacion de favoritos
class DeleteAllFavorites(APIView):
    def delete(self, request):
        try:
            token = request.headers.get('Authorization')
            if not token:
                return Response({'error': 'Se requiere una token de autorización para acceder a esta función'}, status=401)

            db = firestore.client()
            query = db.collection('users').where('token', '==', token).get()
            user_doc = None
            for user in query:
                user_doc = user

            if user_doc is None:
                return Response({'error': 'No se encontró el usuario correspondiente a esta token'}, status=404)
            
            favorites_query = db.collection('users').document(user_doc.id).collection('favoritos').get()
            for favorite in favorites_query:
                favorite.reference.delete()

            return Response({'message': 'Todos los favoritos del usuario han sido eliminados correctamente'}, status=200)

        except Exception as e:
            return Response({'error': str(e)}, status=500)
        
#api para darle like a una publicacion         
class LikesAppi(APIView):
    def get(self, request, pk):
        try:
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'error': 'Se requiere una token de autorización para acceder a esta función'}, status=401)

            db = firestore.client()
            query = db.collection('users').where('token', '==', token).get()
            print(token)
            user_doc = None
            for user in query:
                user_doc = user

            if user_doc is None:
                return JsonResponse({'error': 'No se encontró el usuario correspondiente a esta token'}, status=404)

            # Obtener todas las publicaciones favoritas del usuario correspondiente
            likes_query = db.collection('produc').document(pk).collection('likes').get()
            lisLikes = []
            for likes in likes_query:
                lisLikes.append(likes.to_dict())

            return JsonResponse({'Likes': lisLikes}, status=200)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
    def post(self, request, pk):
        try: 
            token = request.headers.get('Authorization')
            db = firestore.client()
            users_ref = db.collection('users')

            query = users_ref.where('token', '==', token).get()
            if not token:
                return Response({'error': 'Se requiere una token de autorización para acceder a esta función'}, status=401)
            
            user_id = None
            for user in query:
                user_id = user.to_dict().get('id')
            print(user_id)

            db_ref = db.collection('produc').document(pk).collection('likes')
            likes = {
                'id_user_like': user_id,
            }
            db_ref.add(likes)
            print(likes)
            return JsonResponse({'message': 'se a dado like'}, status=201)
        except Exception as e:
            return Response({'error': str(e)}, status=500)
        
    def delete(self, request, pk):
            try:
                token = request.headers.get('Authorization')
                if not token:
                    return JsonResponse({'error': 'Se requiere una token de autorización para acceder a esta función'}, status=401)

                db = firestore.client()
                query = db.collection('users').where('token', '==', token).get()
                user_doc = None
                for user in query:
                    user_doc = user

                if user_doc is None:
                    return JsonResponse({'error': 'No se encontró el usuario correspondiente a esta token'}, status=404)

                # Eliminar el like del usuario correspondiente
                like_query = db.collection('produc').document(pk).collection('likes').where('id_user_like', '==', user_doc.to_dict()['id']).get()
                like_doc = None
                for like in like_query:
                    like_doc = like

                if like_doc is None:
                    return JsonResponse({'error': 'No se encontró el like correspondiente al usuario'}, status=404)

                like_doc.reference.delete()

                return JsonResponse({'message': 'El like se ha eliminado correctamente'}, status=200)

            except Exception as e:
                return JsonResponse({'error': str(e)}, status=500)

#api para buscar un producto 
class Search (APIView):
    def get (self, request, dataProduc):
        try:
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'error': 'Se requiere una token de autorización para acceder a esta función'}, status=401)
            
            db = firestore.client()

            query_user = db.collection('users').where('token', '==', token).get()
            user_doc = None
            for user in query_user:
                user_doc = user

            if user_doc is None:
                return Response({'error': 'No se encontró el usuario correspondiente a esta token'}, status=404)

            search_list = []
            clasific_query = db.collection('produc').where('clasific', '==', dataProduc).get()
            if len(clasific_query) > 0:
                for i in clasific_query:
                    search_list.append(i.to_dict())
            else:
                name_query = db.collection('produc').where('name', '==',dataProduc).get()
                if len(name_query) > 0:
                    for i in name_query:
                        search_list.append(i.to_dict())
                else:
                    author_query = db.collection('produc').where('author', '==', dataProduc).get()
                    for i in author_query:
                        search_list.append(i.to_dict())

            return JsonResponse ({'search': search_list}, status = 200)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status = 500)

#api para buscar un producto por la ubicacion
class SearchUbication(APIView):
    def get(self, request, dataProduc):
        try:
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'error': 'Se requiere una token de autorización para acceder a esta función'}, status=401)

            db = firestore.client()

            query_user = db.collection('users').where('token', '==', token).get()
            user_doc = None
            for user in query_user:
                user_doc = user

            if user_doc is None:
                return Response({'error': 'No se encontró el usuario correspondiente a esta token'}, status=404)

            search_list = []
            clasific_query = db.collection('produc').where('clasific', '==', dataProduc).get()
            if len(clasific_query) > 0:
                for i in clasific_query:
                    search_list.append(i.to_dict())
                search_list = [{'coordinates': item.get('cordenadas'), 'id': item.get('id'), 'clasific': item.get('clasific')} for item in search_list]
                print(search_list)
            else:
                name_query = db.collection('produc').where('name', '==', dataProduc).get()
                if len(name_query) > 0:
                    for i in name_query:
                        search_list.append(i.to_dict())
                    search_list = [{'coordinates': item.get('cordenadas'), 'id': item.get('id'), 'clasific': item.get('clasific')} for item in search_list]
                    print(search_list)
                else:
                    author_query = db.collection('produc').where('author', '==', dataProduc).get()
                    for i in author_query:
                        search_list.append(i.to_dict())
                    search_list = [{'coordinates': item.get('cordenadas'), 'id': item.get('id'), 'clasific': item.get('clasific')} for item in search_list]
                    print(search_list)

            return JsonResponse({'search': search_list}, status=200)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

#api para reportar una publicacion 
class ReportPublic (APIView):
    def get(self, request):
        try:
            db = firestore.client()
            token = request.headers.get('Authorization')

            # Verificar si el usuario es un administrador
            query_user = db.collection('users').where('token', '==', token).get()
            is_admin = False
            adminId = False
            for user in query_user:
                is_admin = user.to_dict().get('is_admin')
                adminId = user.to_dict().get('id')

            if is_admin:
                # Obtener los reportes solo si es un administrador
                db_refence = db.collection('users').document(adminId).collection('reportes').get()
                lisLikes = []
                for likes in db_refence:
                    lisLikes.append(likes.to_dict())
                return JsonResponse({'reportes': lisLikes}, status=200)
            else:
                return JsonResponse({'message': 'No tienes permiso para acceder a esta función'}, status=403)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
        
    def post(self, request):
        try:
            data = json.loads(request.body)
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'error': 'Se requiere una token de autorización para acceder a esta función'}, status=401)
            
            db = firestore.client()

            query_user = db.collection('users').where('token', '==', token).get()
            userId = None
            for user in query_user:
                userId = user.to_dict().get('id')
                userName = user.to_dict().get('user_name')

            db_refence = db.collection('users').where('is_admin', '==', True).get()
            adminId = None
            for admin in db_refence:
                adminId = admin.to_dict().get('id')

            db_references = db.collection('users').document(adminId).collection('reportes')
            reportBody = {
                'userId': userId,
                'userName': userName,
                'idPublic': data.get('idPublic'),
                'nameAutho': data.get('nameAutho'),
                'namePublic': data.get('namePublic'),
                'reporte': data.get('reporte')
            }
            db_references.add(reportBody)
            return JsonResponse({'message': 'Se a echo el reporte con exito'}, status=200)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status = 500)
        
#api para que lleguen las notificaciones        
class NotificSeguidores (APIView):
    def get(self, request):
        try:
            db = firestore.client()
            token = request.headers.get('Authorization')

            # Verificar si el usuario es un administrador
            query_user = db.collection('users').where('token', '==', token).get()
            userId = False
            for user in query_user:
                userId = user.to_dict().get('id')

            
                db_refence = db.collection('users').document(userId).collection('notificaciones').get()
                notificaciones = []
                for notificacion in db_refence:
                    notificaciones.append(notificacion.to_dict())
                return JsonResponse({'notificaciones': notificaciones}, status=200)
            else:
                return JsonResponse({'message': 'No tienes permiso para acceder a esta función'}, status=403)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

# api para prubas de eliminacion de los productos cuando vence
class NotoficDelete(APIView):
    def delete(self, request):
        db = firestore.client()
        db_ref = db.collection('produc')
        product_docs = db_ref.get()
        expiration_dates = []

        for doc in product_docs:

            # Obtener los datos del producto desde Firebase
            product_data = doc.to_dict()
            expiration_date = product_data.get('fecha')
            print(expiration_date)
            if expiration_date:
                expiration_dates.append(expiration_date)
                # Convertir la fecha de expiración a un objeto datetime
                expiration_datetime = datetime.strptime(expiration_date, '%Y-%m-%d')

                print(expiration_datetime)
                # Obtener la fecha actual
                current_datetime = datetime.now()

                print(current_datetime)
                # Verificar si la fecha de expiración es mayor a la fecha actual
                if expiration_datetime < current_datetime:
                    # La fecha de expiración es mayor, eliminar la publicación
                    # db_ref.delete()
                    return Response('Publicación eliminada.', status=202)
        else:
            return Response('La publicación no ha expirado.', status=200)
    
#api para generar un codigo qr    
class QRCodeAPIView(APIView):
    def post(self, request):
        data = json.loads(request.body)
        
        token = request.headers.get('Authorization')
        if not token:
            return JsonResponse({'error': 'Se requiere una token de autorización para acceder a esta función'}, status=401)
        
        db = firestore.client()

        query_user = db.collection('users').where('token', '==', token).get()
        userId = None
        for user in query_user:
            userId = user.to_dict().get('id')

        pedidosQr ={
            'clasific': data.get('clasific'),
            'author': data.get('author'),
            'cantidad': data.get('cantidad'),
            'image': data.get('image'),
            'id': data.get('id'),
            'valor': data.get('total'),
            'autor': data.get('autor'),
            'fecha': data.get('fecha'),
            'ubicacion': data.get('ubicacion')
            # autor: '', 
            #   fecha: '', 
            #   ubicacion: '', 
            #   valor: '',
        }

        # Crear el código QR
        pedidosQr_json = json.dumps(pedidosQr)  # Convertir el diccionario a formato JSON
        qr = qrcode.QRCode(version=1, error_correction=qrcode.constants.ERROR_CORRECT_H, box_size=10, border=4)
        qr.add_data(pedidosQr_json)  # Pasar el JSON como datos del código QR
        qr.make(fit=True)
        qr_image = qr.make_image(fill_color="black", back_color="white")
        # qr = qrcode.QRCode(version=1, error_correction=qrcode.constants.ERROR_CORRECT_H, box_size=10, border=4)
        # qr.add_data(pedidosQr)
        # qr.make(fit=True)
        # qr_image = qr.make_image(fill_color="black", back_color="white")

        # Convertir la imagen a bytes
        qr_bytes = BytesIO()
        qr_image.save(qr_bytes, format='PNG')
        qr_bytes.seek(0)

        # Subir los bytes del código QR a Firebase Storage
        bucket_name = 'colveg-67dae.appspot.com'
        client = firebase_admin.storage.bucket(bucket_name)
        blob = client.blob(f'qr/{qr_image}.png')

        with tempfile.SpooledTemporaryFile() as temp_file:
            temp_file.write(qr_bytes.read())
            temp_file.seek(0)
            blob.upload_from_file(temp_file, content_type='image/png', predefined_acl='publicRead')

        # Obtener la URL del archivo en Firebase Storage
        image_url = blob.public_url
        # Obtener la DocumentReference correspondiente al usuario
        user_ref = db.collection('users').document(userId)

        # Agregar el código QR a la colección 'pedidos' dentro de la colección 'notificaciones'

        notificaciones_collection = user_ref.collection('pedidos')
        new_notificacion_ref = notificaciones_collection.document()
        new_notificacion_id = new_notificacion_ref.id
        new_notificacion_ref.set({'imageQr': image_url, 'userName': data.get('clasific'), 'imagenProduc': data.get('image'), 'id': new_notificacion_id, 'author': data.get('author')})


        # Devolver la URL del código QR generado en la respuesta JSON
        return JsonResponse({'qr_code_path': image_url}, status = 201)
    def get(self, request):
        try:
            db = firestore.client()
            token = request.headers.get('Authorization')

            # Verificar si el usuario es un administrador
            query_user = db.collection('users').where('token', '==', token).get()
            userId = False
            for user in query_user:
                userId = user.to_dict().get('id')

            
                db_refence = db.collection('users').document(userId).collection('pedidos').get()
                pedidos = []
                for pedidosQr in db_refence:
                    pedidos.append(pedidosQr.to_dict())
                return JsonResponse({'pedidos': pedidos}, status=200)
            else:
                return JsonResponse({'message': 'No tienes permiso para acceder a esta función'}, status=403)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

# api para enviara notificaciones 
class Mensage(APIView):
    def post(self, request, nameReceptor):
        data = json.loads(request.body)
        dbReference = firestore.client()
        token = request.headers.get('Authorization')

        # Verificar si el usuario es un administrador
        query_user = dbReference.collection('users').where('token', '==', token).get()
        userName = False
        for user in query_user:
            userName = user.to_dict().get('user_name')

        mensaje = data.get('mensaje')

        ref_chat = db.reference('chat')
        query_chat = ref_chat.order_by_child('author'and 'receptor').equal_to(userName and nameReceptor).get()

        for chat_id, chat_data in query_chat.items():
            idMensajesChat = chat_data.get('tockenMnesajes')


        fcm = FCMNotification(api_key='AAAAoh0jA4A:APA91bF9iuZrmqjRTCnYAo48nLTnuLUQ5qdqufy_2Ws9GwD88cEIPYDXQiwwrdUUsV9bF3nqM_ktr4vGnWcv_NfGmKXpLCYmbFgHIjDoDkKGfCcM--GKg20tJwEZXP32SqfC3F092aCr')

        response = fcm.notify_single_device(registration_id=idMensajesChat, message_body=mensaje, message_title=userName, sound='/static/notificacionChat.mp3', message_icon='/static/logo1.jpg', click_action='http://localhost:61260/#/')
        print('Notificación enviada:', response)
        return JsonResponse({'Notificación enviada:': response}, status=200)