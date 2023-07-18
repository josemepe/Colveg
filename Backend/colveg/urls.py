from django.urls import path
from .import views
from django.contrib.auth.views import LoginView
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('', views.create_product, name='produc'),
    path('producto/', views.product_detail, name='product_detail'),
    path('comentario/', views.CommentView.as_view(), name='comentario'),
]

