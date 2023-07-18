from django.urls import path
from .import views
from .views import CreateFavorite, FollowUser, DeleteAllFavorites, GetUser, LikesAppi, FollowerUser, Search, ReportPublic, NotificSeguidores, NotoficDelete, QRCodeAPIView, SearchUbication, Mensage
from django.contrib.auth.views import LoginView
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [

    path('favoritos/', CreateFavorite.as_view(), name='produc'),
    path('favoritos/<str:id>/', CreateFavorite.as_view(), name='produc'),
    path('delete_favoritos/', DeleteAllFavorites.as_view(), name='delete _favoritos'),
    path('seguidos/', FollowUser.as_view(), name='follow'),
    path('seguidore/', FollowerUser.as_view(), name='follower'),
    # path('search/', Search.as_view(), name = 'buscar')
    path('usuario/', GetUser.as_view(), name='usuario'),
    # path('usuario/', GetUser.as_view(), name='usuario'),
    path('likes/<str:pk>/', LikesAppi.as_view(), name='likes'),
    path('seguidores/<str:userName>/', FollowerUser.as_view(), name='seguidores'),
    path('search/<str:dataProduc>/', Search.as_view(), name = 'buscar'),
    path('searchUbicacion/<str:dataProduc>/', SearchUbication.as_view(), name = 'Ubicacion'),
    path('reportes/', ReportPublic.as_view(), name = 'reportes'),
    path('notificaciones/', NotificSeguidores.as_view(), name = 'notificaciones'),
    # urls de la api de prueba para eliminar los productos cuando vencen
    path('delete/', NotoficDelete.as_view(), name='borrar'),
    path('generate_qr_code/', QRCodeAPIView.as_view(), name='generate_qr_code'),
    path('enviar-notificacion/<str:nameReceptor>/', Mensage.as_view(), name = 'enviar-notificacion')
    
]   
