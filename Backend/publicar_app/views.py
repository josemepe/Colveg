#se hace la importacion de librerias
import genericpath
import json
from django.http import HttpResponse
from .serializer import ProductoSerializer, ComentarioSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
import user
from rest_framework import status
from .models import Produc, Comentario
from .forms import ProducForm, ComentarioForm
from django.http import JsonResponse
from django.views.generic import ListView, DetailView, UpdateView, DeleteView
from .import models
from django.shortcuts import render, get_object_or_404, redirect
from .forms import ComentarioForm
from django.urls import reverse, reverse_lazy
import mimetypes
import json
from django.views.decorators.http import require_http_methods
from django.http import JsonResponse
from firebase_admin import firestore, storage
from rest_framework import generics
from django.contrib.auth.decorators import login_required
from django.views.decorators.csrf import csrf_exempt
from rest_framework.views import APIView
from rest_framework.response import Response

# API post para los productos
# @require_http_methods(['POST'])
class CreateProduct(APIView):
    def post(self, request):
        try:
            data = json.loads(request.body)
            author = None
            image_user = None
            
            # pasamos un token de autorización para validar los usuarios
            token = request.headers.get('Authorization')
            print(token)
            if not token:
                return JsonResponse({'error': 'Se requiere una token de autorización para acceder a esta función'}, status=401)
            
            # referenciamos la base de datos de firestore y comparamos los tokens entre el de la base de datos y el del header
            db = firestore.client()
            query = db.collection('users').where('token', '==', token).get()
            for user in query:
                author = user.to_dict().get('user_name')
                image_user = user.to_dict().get('image_user')
                id = user.to_dict().get('id')
                tockenMensajes = user.to_dict().get('tockenMensajes')

            # Damos cuerpo al Json que serializaremos para el frontend
            produc_data = {
                'author': author,
                'image_user': image_user,
                'id_author': id,
                'clasific': data.get('clasific'),
                'name': data.get('name'),
                'descrip': data.get('descrip'),
                'peso': data.get('peso'),
                'unidad_peso': data.get('unidad_peso'),
                'price': data.get('price'),
                'direccion': data.get('direccion'),
                'fecha': data.get('fecha'),
                'image': data.get('image'),
                'cordenadas': data.get('cordenadas'),
                'tockenMensajes': tockenMensajes
            }
            db = firestore.client()
            db_ref = db.collection('produc')
            
            # definimos un id para cada publicación 
            produc_ref = db_ref.add(produc_data)
            produc_id = produc_ref[1].id
            produc_data['id'] = produc_id
            db_ref.document(produc_id).set(produc_data)
            return JsonResponse({'message': 'Producto creado correctamente'}, status=201)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

#----------------------------------------------------------------------------------------------------------------------

# API get y put para los productos
class EditProductAPIView(APIView):
    def get(self, request, pk):
        db = firestore.client()
        db_ref = db.collection('produc').document(pk)
        # listamos los "id" que hay en la tabla "produc"
        product_data = db_ref.get().to_dict()

        # Obtener el nombre de usuario del autor de la publicación desde Firebase
        users_ref = db.collection('users')
        
        # comparamos el usuario que hay en la tabla "users" con el autor de la publicacion
        query = users_ref.where('user_name', '==', product_data['author']).get()
        author_name = None
        for user in query:
            author_name = user.to_dict().get('user_name')

        # Devolver los datos del producto y el nombre del autor en un diccionario
        response_data = {
            'clasific': product_data['clasific'],
            'name': product_data['name'],
            'descrip': product_data['descrip'],
            'image': product_data['image'],
            'image_user': product_data['image_user'],
            'peso': product_data['peso'],
            'unidad_peso': product_data['unidad_peso'],
            'price': product_data['price'],
            'direccion': product_data['direccion'],
            'fecha': product_data['fecha'],
            'cordenadas': product_data['cordenadas'],
            'author_name': author_name,
        }
        return Response(response_data, status=200)

    def put(self, request, pk):
        # referenciamos la tabla "produc" de la base de datos
        db = firestore.client()
        db_ref = db.collection('produc').document(pk)
        # listamos los "id" de la tabla "produc"
        product_data = db_ref.get().to_dict()

        # Obtener el nombre de usuario del autor de la publicación desde Firebase
        db = firestore.client()
        users_ref = db.collection('users')
        query = users_ref.where('user_name', '==', product_data['author']).get()
        author_name = None
        for user in query:
            author_name = user.to_dict().get('user_name')

        # pasamos un token en el header para validar el usuario
        auth_header = request.headers.get('Authorization')
        users_ref = db.collection('users')
        # query = users_ref.where('user_name', '==', product_data['author']).get()
        token = auth_header.split(' ')[1]
        query = users_ref.where('token', '==', token).get()
        author_name = None
        is_admin = False
        for user in query:
            author_name = user.to_dict().get('user_name')
            is_admin = user.to_dict().get('is_admin')

        if not auth_header:
            return Response('Se requiere un token de autorización para acceder a esta función', status=401)

        if ' ' not in auth_header:
            return Response('El token de autorización no tiene el formato correcto', status=401)

        
        author_user_login = None
        for user in query:
            author_user_login = user.to_dict().get('user_name')

        # Verificar si el usuario actual es el autor de la publicación o es un admin
        if is_admin == True:
            product_data = request.data
        else: 
            if author_user_login == author_name:
                product_data = request.data

            # Obtener los datos del producto desde el request en formato JSON
            

        # Actualizar los datos del producto en la base de datos
        db_ref.update(product_data)

        return Response(status=201)

# ----------------------------------------------------------------------------------------------------------------
#api para borrar el producto 
class DeletePorduct(APIView):
    def delete(self, request, pk):
        db = firestore.client()
        db_ref = db.collection('produc').document(pk)
        # product_data = db_ref.get().to_dict()

        # Obtener el nombre de usuario del autor de la publicación desde Firebase
        auth_header = request.headers.get('Authorization')
        users_ref = db.collection('users')
        # query = users_ref.where('user_name', '==', product_data['author']).get()
        token = auth_header.split(' ')[1]
        query = users_ref.where('token', '==', token).get()
        author_name = None
        for user in query:
            author_name = user.to_dict().get('user_name')
            is_admin = user.to_dict().get('is_admin')
        
        print(author_name)

        if not auth_header:
            return HttpResponse('Se requiere una token de autorización para acceder a esta función', status=401)        
        
        author_user_login = None
        for user in query:
            author_user_login = user.to_dict().get('user_name')
        print(author_user_login)
        # Verificar si el usuario actual es el autor de la publicación
        # Verificar si el usuario actual es el autor de la publicación o es un admin
        if is_admin == True:
            db_ref.delete()
            return Response('Publicación eliminada.', status=201)
        else: 
            if author_user_login == author_name:
                 db_ref.delete()
            return Response('Publicación eliminada.', status=201)
           
# ----------------------------------------------------------------------------------------------------------------
class ProductoList(APIView):
    def get(self, request, *args, **kwargs):
        try:
            # pasamos un token en el header para validar el usuario que inicio sesion
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'error': 'Se requiere un token de autorización para acceder a esta función'}, status=401)

            db = firestore.client()
           
            # comparamos el token del usuario registrado con el que inicio sesion
            query = db.collection('users').where('token', '==', token).get()
            user_doc = None
            for user in query:
                user_doc = user

            if user_doc is None:
                return JsonResponse({'error': 'No se encontró el usuario correspondiente a este token'}, status=404)

            # referenciamos la coleccion "produc" 
            query = db.collection('produc').get()
            follow_list = []
            # agregamos los productos al arreglo "follow_list"
            for doc in query:
                follow_list.append(doc.to_dict())
                response = JsonResponse({'produc': follow_list}, status=201)
                response['Access-Control-Allow-Origin'] = '*'  # Permitir todas las solicitudes de origen cruzado
                response['Access-Control-Allow-Methods'] = 'GET'  # Permitir solo solicitudes GET
                response['Access-Control-Allow-Headers'] = '*'  # Permitir solo encabezados Content-Type
    
            return response
        # JsonResponse({'produc':follow_list}, status=201)

        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

#----------------------------------------------------------------------------------------------------------------------
# API CRUD de comentario
class CommentCreate(APIView):
    def get(self, request, pk, *args, **kwargs):
        try:
            # pasamos el token de autorizacion en el header
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'error': 'Se requiere un token de autorización para acceder a esta función'}, status=401)

            db = firestore.client()
            # referenciamos la coleccion de comentarios
            db_ref = db.collection('produc').document(pk).collection('comentarios')

            comment_data = db_ref.get()
            comment_list = []
            # agregamos los registros de la coleccion en un arreglo llamado "comment_list"
            for comment_doc in comment_data:
                comment_list.append(comment_doc.to_dict())

            return JsonResponse({'comment_list':comment_list}, status=201)
        
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    def post(self, request, pk):
        try:
            data = json.loads(request.body)
            # Validamos la información del usuario que comentará
            db = firestore.client()
            users_ref = db.collection('users')
            token = request.headers.get('Authorization')
            if not token:
                return HttpResponse('Se requiere un token de autorización', status=401)

            query = users_ref.where('token', '==', token).get()

            # usamos un for para llamar dos valores 
            author = None
            for user in query:
                author = user.to_dict().get('user_name')
                image_user = user.to_dict().get('image_user')
                id = user.to_dict().get('id')

            comment_col = db.collection('produc').document(pk).collection('comentarios')

            # damos cuerpo al Json que serializatremos 
            product_comment = {
                'author': author,
                'user_image': image_user,
                'id_autor': id,
                'comentario': data.get('comentario')
            }
            
            # le definimos un "id" a cada comentario
            de_ref = comment_col.add(product_comment)
            produc_id = de_ref[1].id
            product_comment['id'] = produc_id
            comment_col.document(produc_id).set(product_comment)

            print(product_comment)

            return JsonResponse({'message':'Se ha subido el comentario'}, status=201)
        
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
        
    def delete (self, request, pk):
        try:
            data = json.loads(request.body)
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'error':'Se requiere un token de autorizacion'})

            db = firestore.client()
            
            users_ref = db.collection('users')
            query = users_ref.where('token', '==', token).get()
            user_doc = None
            for user in query:
                user_doc = user

            if user_doc is None:
                return JsonResponse({'error': 'No se encontró el usuario correspondiente a esta token'}, status=404)

            query_comment = db.collection('produc').document(pk).collection('comentarios').document(pk)
            if not query_comment:
                return JsonResponse({'error': 'No se encuentra este comentario'}, status=400)
            
            author = None
            for user in query:
                author = user.to_dict().get('user_name')
                image_user = user.to_dict().get('image_user')

            # damos cuerpo al Json que se serializara
            comment_data ={
                'author': author,
                'user_image': image_user,
                'comentario': data.get('comentario')
            }

            query = db.collection('produc').document(pk).collection('comentarios').where('author', '==', comment_data['author']).where('comentario', '==', comment_data['comentario']).get()

            # usamos un for para buscar los comentarios que se desean borrar
            for comment_doc in query:
                db.collection('produc').document(pk).collection('comentarios').document(comment_doc.id).delete()

            return JsonResponse({'message':'Se ha eliminado el comentario'}, status=201)
        
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

#------------------------------------------------------------------------------------------------------------------------

#api para responder a los comentarios que ya estan hechos 
class RespcommentCreate(APIView):
    def get(self, request, pk, id_produc, *args, **kwargs):
        try:
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'error': 'Se requiere un token de autorización para acceder a esta función'}, status=401)

            db = firestore.client()
            # referencaimos la coleccion para las respuestas de comentarios
            db_ref = db.collection('produc').document(id_produc).collection('comentarios').document(pk).collection('respComentarios')

            comment_data = db_ref.get()
            
            comment_list = []
            # for para agregar los comentarios respuesta en un arreglo llamado "comment_list"
            for comment_doc in comment_data:
                comment_list.append(comment_doc.to_dict())

            return JsonResponse({'comment_list':comment_list}, status=201)
        
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    def post(self, request, pk, id_produc):
        try:
            data = json.loads(request.body)

            # Validamos la información del usuario que comentará
            db = firestore.client()
            users_ref = db.collection('users')

            token = request.headers.get('Authorization')
            if not token:
                return HttpResponse('Se requiere un token de autorización', status=401)

            query = users_ref.where('token', '==', token).get()

            
            author = None
            for user in query:
                author = user.to_dict().get('user_name')
                image_user = user.to_dict().get('image_user')

            comment_col = db.collection('produc').document(id_produc).collection('comentarios').document(pk).collection('respComentarios')

            # damos cuerpo al Json que vamos a serializar para los comentarios
            product_comment = {
                'author': author,
                'user_image': image_user,
                'comentario': data.get('comentario')
            }

            comment_col.add(product_comment)

            print(product_comment)

            return JsonResponse({'message':'Se ha subido el comentario'}, status=201)
        
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
        
    def delete (self, request, pk, id_produc):
        try:
            data = json.loads(request.body)
            # pasamos un token de autorización para validar los usuarios
            token = request.headers.get('Authorization')
            if not token:
                return JsonResponse({'error':'Se requiere un token de autorizacion'})

            db = firestore.client()
            # comparamos el token del usuario con el del header
            users_ref = db.collection('users')
            query = users_ref.where('token', '==', token).get()
            user_doc = None
            for user in query:
                user_doc = user

            if user_doc is None:
                return JsonResponse({'error': 'No se encontró el usuario correspondiente a esta token'}, status=404)
            # buscamos los comentarios
            query_comment = db.collection('produc').document(id_produc).collection('comentarios').document(pk).collection('respComentarios')
            if not query_comment:
                return JsonResponse({'error': 'No se encuentra este comentario'}, status=400)
            
            author = None
            for user in query:
                author = user.to_dict().get('user_name')
                image_user = user.to_dict().get('image_user')

            # damos cuerpo al Json que se serializara hacia en frontend
            comment_data ={
                'author': author,
                'user_image': image_user,
                'comentario': data.get('comentario')
            }

            query = db.collection('produc').document(id_produc).collection('comentarios').document(pk).collection('respComentarios').where('author', '==', comment_data['author']).where('comentario', '==', comment_data['comentario']).get()
            # Obtener el documento de seguimiento y eliminarlo
            for comment_doc in query:
                db.collection('produc').document(id_produc).collection('comentarios').document(pk).collection('respComentarios').document(comment_doc.id).delete()

            return JsonResponse({'message':'Se ha eliminado el comentario'}, status=201)
        
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)



# -----------------------------------------------------------------------------------------------------------------------
# API get para los comentarios
class Comment(APIView):
    def get(self, request, pk):
        # referenciamos la coleccion de comentarios en la base de datos de firestore
        db = firestore.Client()
        db_ref = db.collection('produc').document(pk).collection('comentarios')
        comments = []

        # usamos un for para agregar los comentarios en un arreglo llamado "comments"
        for i in db_ref.get():
            comment_data = i.to_dict()
            comments.append({
                'pk': i.id,
                'comentario': comment_data['comentario']
            })

        return Response({'comments': comments})

class CommentList(generics.ListAPIView):
    queryset = Comentario.objects.all()
    serializer_class = ComentarioSerializer

#----------------------------------------------------------------------------------------------------------------------



'''class CommentPost(ComentarioForm):
    model = Produc
    from_class = ComentarioForm
    template_name = "publicacion.html"

    def post(self, request, *args, **kwargs):
        self.object = self.get_object()
        return super().post(request, *args, **kwargs)
    
    def valid (self, form):
        comment = form.save
        comment.product = self.object
        comment.save()
        return super().valid(form)
    
    def get_succes_url(self):
        comentario = self.get_object()
        return reverse("publicacion", kwargs={"pk": comentario.pk})
#----------------------------------------------------------------------------------------------------------------------

# Vista para ver un comentario
class CommentView(DetailView):
    def get(self, request, *args, **kwargs):
        view=CommentPubli.as_view()
        return view('GET request!')

    def post(self, request, *args, **kwargs):
        view=CommentPost.as_view()
        return view('POST request!')'''

'''def agregar_comentario(request, pk):
     Producto = get_object_or_404(Produc, pk=pk)
    if request.method == 'POST':
        form = ComentarioForm(request.POST)
        if form.is_valid():
            comentario = form.save(commit=False)
            comentario.publicacion = Producto
            comentario.autor = request.user
            comentario.save()
            return redirect('publicacion', pk=Produc.pk)
    else:
        form = ComentarioForm()
    return render(request, 'comentario.html', {'form': form})'''