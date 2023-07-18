from audioop import reverse
import json
import pdb
from pyexpat.errors import messages
from sched import scheduler
from rest_framework.response import Response
import sched
import time
import datetime
from django.http import HttpResponse, JsonResponse
from django.shortcuts import get_object_or_404, render, redirect
from django.contrib.auth import login, authenticate
from django.views.decorators.csrf import csrf_exempt
from django.conf import settings
from twilio.rest import Client
from .models import RegisterUser
from .forms import CustomUserChageForm, CustomUserCreationForm, LoginForm, ResetPassword, ResetPasswordConfirm, VerificationCodeForm
import random
from django.shortcuts import render
from django.core.mail import send_mail
import os
from mapboxgl.utils import create_color_stops, df_to_geojson
from mapboxgl.viz import CircleViz
import pandas as pd
from django.contrib.auth.views import LoginView
from django.urls import reverse_lazy
from django.contrib.auth.hashers import make_password
from firebase_admin import firestore, storage, db

'''def sms():
    account_sid = 'ACbffcb383ba2ce96f845057304eef3d4b'
    auth_token = '4675b3a545096b0981630ccdae8848fd'
    client = Client(account_sid, auth_token)

    message = client.messages.create(
    from_='+15075805467',
    body='Mensaje de prueba',
    to='+573228065656'
    )

    print(message.sid)'''
#----------------------------------------------------------------------

import firebase_admin
from firebase_admin import credentials, firestore
from firebase_admin import auth, exceptions
from django.contrib.auth.models import User 
import hashlib
from datetime import datetime, timedelta
import mimetypes
from firebase_admin import storage
from rest_framework.views import APIView

cred = credentials.Certificate("colveg-67dae-firebase-adminsdk-qxvof-ce6afb703b.json")
firebase_admin.initialize_app(cred, options={
    'databaseURL': 'https://colveg-67dae-default-rtdb.firebaseio.com/'
})

import jwt

#funcion para el registro de ususarios
# @csrf_exempt
class Register(APIView):
    def post(self, request):
        try:
            data = json.loads(request.body)
                
            # name = data.name
            # user_name = data.user_name
            # email = data.email
            # number_phone = user.number_phone
            password = data.get('password1')
            # Encriptar la contraseña
            encrip_password = hashlib.sha512(password.encode()).hexdigest()
            id = data.get('id')

            # Validación que los campos sean únicos en Firebase
            db = firestore.client()
            users_ref = db.collection('users')
            query = users_ref.where('email', '==', data.get('email')).where('user_name', '==', data.get('user_name')).get()

            # Si el usuario ya existe, envía un mensaje de error
            if len(query) > 0:
                error_message = 'Ya existe un usuario con el mismo correo electrónico, nombre de usuario y número de teléfono'
                return Response({'error_message': error_message}, status=400)

            # Guardar los datos del usuario en Firebase
            image_files = os.listdir('static/images/')
            image_file = random.choice(image_files)
            bucket_name = 'colveg-67dae.appspot.com'
            client = firebase_admin.storage.bucket(bucket_name)
            blob = client.blob(f'user_images/{image_file}')
            blob.upload_from_filename(f'static/images/{image_file}', predefined_acl='publicRead')
            url = blob.public_url

            user_data = {
                'name': data.get('name'),
                'user_name': data.get('user_name'),
                'email': data.get('email'),
                # 'number_phone': number_phone,
                'password': encrip_password,
                'image_user': url,
                'is_admin': False,
            }

            db = firestore.client()
            db_ref = db.collection('users')
            produc_ref = db_ref.add(user_data)
            produc_id = produc_ref[1].id
            user_data['id'] = produc_id
            db_ref.document(produc_id).set(user_data)
            # db.collection('users').document(id).set(user_data)

            # Enviar código a Gmail
            code = random.randint(100000, 999999)
            subject = 'Código de verificación'
            message = f'Su código de verificación es: {code}'
            from_email = settings.EMAIL_HOST_USER
            recipient_list = [data.get('email')]
            send_mail(subject, message, from_email, recipient_list, fail_silently=False)

            # Almacenar códigos temporales en Firebase
            code_temp = {
                'code_email': code,
                # 'code_phone': code_phone,
                'expiration': datetime.utcnow() + timedelta(minutes=5)
            }
            db.collection('code_temp').add(code_temp)

            print(f"Verification codes: {code}")

            return JsonResponse({'message': 'PUsuario creado'}, status=201)
        except Exception as e:
            return Response({'error': str(e)}, status=500)
#----------------------------------------------------------------------

class editProfile(APIView):
    def post(self, request, id):
        try:
            db = firestore.client()
            data = json.loads(request.body)
            name = data.get('name')
            user_name = data.get('user_name')
            email = data.get('email')
            image_user = data.get('image_user')

            # user_data = {}

            if name is not None:
                # user_data['name'] = name
                db.collection('users').document(id).update({'user_name': name})

            if image_user is not None:
                
                query = db.collection('produc').where('id_author', '==', id)

                docs = query.stream()
                for doc in docs:
                    doc.reference.update({'image_user': image_user})
                # user_data['image_user'] = image_user
                db.collection('users').document(id).update({'image_user': image_user})

            if user_name is not None:
                # Verificar si el nombre de usuario ya está en uso
                existing_user = db.collection('users').where('id', '==', id).get()
                exist = db.collection('users').where('user_name', '==', user_name).get()
                if existing_user:
                    return Response({'error': 'se cambio'}, status=201)
                # user_data['user_name'] = user_name
                db.collection('users').document(id).update({'user_name': user_name})

                # Actualizar nombre de usuario en las publicaciones
                query = db.collection('produc').where('id_author', '==', id)
                docs = query.stream()
                for doc in docs:
                    doc.reference.update({'author': user_name})
                else: 
                    if exist:
                        return Response({'error': 'El nombre de usuario ya está en uso'}, status=400)
                

            if email is not None:
                # user_data['email'] = email
                db.collection('users').document(id).update({'user_name': email})

            return HttpResponse(status=201)
            
        except Exception as e:
            return Response({'error': str(e)}, status=500)


    
def edit_user(request, id):
    user = firestore.client().collection('users').document(id).get().to_dict()
    if request.method == 'POST':
        form = CustomUserChageForm(request.POST)
        if form.is_valid():
            name = form.cleaned_data.get('name')
            user_name = form.cleaned_data.get('user_name')
            email = form.cleaned_data.get('email')
            # number_phone = form.cleaned_data.get('number_phone')

            # Actualizar los datos del usuario en Firebase
            db = firestore.client()
            user_data = {
                'name': name,
                'user_name': user_name,
                'email': email,
                # 'number_phone': number_phone,
            }
            db.collection('users').document(id).update(user_data)

            return HttpResponse(status = 201)
    else:
        user_data = firestore.client().collection('users').document(id).get().to_dict()
        initial_data = {
            'name': user_data['name'],
            'user_name': user_data['user_name'],
            'email': user_data['email'],
            # 'number_phone': user_data['number_phone']
        }
    form = CustomUserChageForm(initial=initial_data)
    return render(request, 'user.html', {'form': form})



# ----------------------------------------------------------------------------------------------------------------

scheduler = sched.scheduler(timefunc=time.time, delayfunc=time.sleep)

# Función para eliminar los códigos expirados
# def delete_expired_codes():
#     db = firestore.client()
#     expired_codes = db.collection('code_temp').where('expiration', '<=', datetime.utcnow()+ timedelta(minutes=5)).get()
#     for code in expired_codes:
#         db.collection('code_temp').document(code.id).delete()
# # Programar la eliminación de los códigos expirados
#     scheduler.every(5).minutes.do(delete_expired_codes)

# # Bucle principal del programa
#     while True:
#         scheduler.run_pending()
#         time.sleep(1)
# ---------------------------------------------------------------------
#funcion para autenticacion de usuarios 
@csrf_exempt
def verify_code(request):
    if request.method == 'POST':
        print(request.POST)
        form = VerificationCodeForm(request.POST)
        if form.is_valid():
            code_email = request.POST.get('code_email')
            # code_phone = request.POST.get('code_phone')
            # print(code_email,code_phone)
            
            db = firestore.client()
            code_temp_ref = db.collection('code_temp')
            query = code_temp_ref.order_by('expiration', direction=firestore.Query.DESCENDING).limit(1)
            snapshot = query.get()
            for doc in snapshot:
                verific_email = doc.get('code_email')
                # verific_phone = doc.get('code_phone')

                # print(verific_email,verific_phone)

                if int(code_email) == verific_email: 
                # and int(code_phone) == verific_phone:
                    return HttpResponse(status=201)
                else:
                    error_message = 'Codigos'
                    return render(request, 'verificacion.html', {'error_message': error_message})
    else:
        form = VerificationCodeForm()
    return render(request, 'verificacion.html', {'form': form})
#----------------------------------------------------------------------

''''
# generador yocken con un tiempo maximo de 1 dia
def create_jwt(user):
    payload = {
        'user_id': user.id,
        'username': user.user_name,
        'exp': datetime.datetime.utcnow() + datetime.timedelta(days=1)
    }
    token = jwt.encode(payload, 'your-secret-key', algorithm='HS256')
    return token.decode('utf-8')
'''

# ---------------------------------------------------------------------------------
#funcion para logueo de usuarios

class LoginView(APIView):
    def post(self, request):
        data = json.loads(request.body)
        email = data.get('email')
        password_login = data.get('password_login')
        tockenMensajes = data.get('mensajes')

        # Realizar consulta a la colección de usuarios
        dbCollection = firestore.client()
        users_ref = dbCollection.collection('users')
        query = users_ref.where('email', '==', email).get()

        if not query:
            error_message = 'El correo electrónico no está registrado'
            return JsonResponse({'error': 'El correo electrónico no está registrado'}, status=401)

        # Verificar si el usuario existe y si la contraseña es correcta
        for user in query:
            user_dict = user.to_dict()
            hashed_password = hashlib.sha512(password_login.encode()).hexdigest()

            if hashed_password != user_dict.get('password'):
                return JsonResponse({'error': 'El correo electrónico no está registrado'}, status=500)
            else:
                try:
                    username = user_dict.get('user_name')
                    hashed_password == user_dict.get('password')

                    # Crear o recuperar usuario de Django
                    try:
                        django_user = User.objects.get(username=username)
                    except User.DoesNotExist:
                        django_user = User(username=username, email=email)
                        django_user.set_unusable_password()
                        django_user.save()

                    login(request, django_user)
                    user_id = user.id
                    print(user_id)
                    payload = {
                        'user_id': user_id,
                        # 'username': user.username,
                    }
                    token = jwt.encode(payload, settings.SECRET_KEY, algorithm='HS256')
                    token_online = token.encode().decode()
                    print(email)
                    dbCollection = firestore.client()
                    dbCollection.collection('users').document(user_id).update({
                        'en_linea': True,
                        'token': token_online,
                        'tockenMensajes': tockenMensajes
                    })

                    response_data = {
                        'token': token_online,
                        'mensajes': tockenMensajes
                    }
                    
                    # Actualizar campo 'mensajes' en la colección 'publicaciones'
                    publicaciones_ref = dbCollection.collection('produc').where('id_author', '==', user_id).get()
                    for publicacion in publicaciones_ref:
                        publicacion_id = publicacion.id
                        dbCollection.collection('produc').document(publicacion_id).update({
                            'tockenMnesajes': tockenMensajes
                        })

                    # Actualizar campo 'mensajes' en el chat de la base de datos en tiempo real ref_chat.order_by_child('author' and 'receptor').equal_to(createChatAuthot and author).get()
                    ref_chat = db.reference('chat')
                    chat_ref = ref_chat.order_by_child('receptor').equal_to(username).get()

                    for chat_id in chat_ref.items():
                        ref_chat.child(chat_id[0]).update({
                            'tockenMnesajes': tockenMensajes
                        })

                    return JsonResponse(response_data, status=201)
                except exceptions.FirebaseError as error:
                    # Si el usuario no existe o la contraseña es incorrecta, mostrar mensaje de error
                    error_message = 'Correo electrónico o contraseña incorrectos'
                    return JsonResponse({'error': error_message}, status=400)
#----------------------------------------------------------------------

#funcion para recuperar contraseña en logueo de usarios
@csrf_exempt
def reset_password(request):
    if request.method == 'POST':
        form = ResetPassword(request.POST)
        print(request.POST)
        if form.is_valid():
            email = form.cleaned_data.get('email')

            # Buscar al usuario en Firebase
            db = firestore.client()
            users_ref = db.collection('users')
            query = users_ref.where('email', '==', email).get()

            # Si se encuentra al usuario envia un correo electrónico con un enlace para restablecer la contraseña
            if len(query) > 0:
                user = query[0]
                user_id = user.id
                reset_password_link = f'{request.scheme}://{request.get_host()}/login/password_reset_confirm/{user_id}/'
                subject = 'Restablecer contraseña'
                message = f'Haga clic en el siguiente enlace para restablecer su contraseña:\n\n{reset_password_link}'
                from_email = settings.EMAIL_HOST_USER
                recipient_list = [email]
                send_mail(subject, message, from_email, recipient_list, fail_silently=False)
                return HttpResponse(status=201)
            # Si no se encuentra al usuario, mostrar un mensaje de error
            else:
                error_message = 'No existe un usuario con esa dirección de correo electrónico.'
                return render(request, 'recuperar.html', {'form': form, 'error_message': error_message})
    else:
        return render(request, 'recuperar.html')
#----------------------------------------------------------------------

#funcion para confirmar nueva contraseña
@csrf_exempt
def restablecer_contraseña(request, user_id):
    if request.method == 'POST':
        form = ResetPasswordConfirm(request.POST, initial={'user_id': user_id})
        print(request.POST)
        if form.is_valid():
            password1 = request.POST.get('password1')
            password2 = request.POST.get('password2')
            print(password1, password2)
            if password1 != password2:
                error_message = 'Las contraseñas no coinciden.'
                return render(request, 'restablecer.html', {'error_message': error_message})    
            else:
                encrip_reset_password = hashlib.sha512(password1.encode()).hexdigest()
                db = firestore.client()
                doc_ref = db.collection('users').document(user_id)
                doc_ref.update({'password': encrip_reset_password})
                print(password1)
                return HttpResponse(status=201)
            
        else:
            error_message = 'Error en el formulario'
            return render(request, 'restablecer.html', {'form': form}, {'error_message': error_message})
    else:
        return render(request, 'restablecer.html')

#----------------------------------------------------------------------