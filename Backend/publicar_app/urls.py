from django.urls import path
from .import views
from .views import EditProductAPIView, CreateProduct, DeletePorduct, CommentCreate, ProductoList, RespcommentCreate
from django.contrib.auth.views import LoginView
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    # Url para los productos
    path('', CreateProduct.as_view(), name='produc'),
    # los siguientes 3 path son las Urls para el crud de los productos
    path('delete/<str:pk>/', DeletePorduct.as_view(), name='borrar'),
    path('edit/<str:pk>/', EditProductAPIView.as_view(), name='edit_product_api'),
    path('producto/', ProductoList.as_view(), name='product_detail'),
    # los siguientes 3 path son para los comentarios y la respuesta a comentarios
    path('comentario/<str:pk>/', CommentCreate.as_view(), name='comentario'),
    path('Respcomentario/<str:id_produc>/<str:pk>/', RespcommentCreate.as_view(), name='Respcomentario'),
]   

