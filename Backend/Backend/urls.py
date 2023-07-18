"""Backend URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from user import urls as user_urls
from publicar_app import urls as publicar_urls
from chat import urls as chat_urls
from sistem_app import urls as sistem_urls


urlpatterns = [
    path('admin/', admin.site.urls),
    path("chat/", include(chat_urls)),
    path('login/', include(user_urls)),
    path('produc/', include(publicar_urls)),
    path('sitem/', include(sistem_urls)),


     path("chat/", include("chat.urls")),
]
