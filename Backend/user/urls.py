from .import views
from django.urls import path

from .views import Register, editProfile, LoginView
# from django.contrib.auth.views import PasswordResetConfirmView

urlpatterns = [
    path('register/', Register.as_view(), name='register'),
    # path('favoritos/', CreateFavorite.as_view(), name='produc'),
    path('verificar/', views.verify_code, name='verificar'),
    path('editar_profile/<str:id>/', editProfile.as_view(), name='editar_profile'),
    path('login/', LoginView.as_view(), name='login'),
    path('recuperar/', views.reset_password, name='recuperar'),
    path('password_reset_confirm/<str:user_id>/', views.restablecer_contraseña, name='password_reset_confirm')
    # path('mapa/', views.mapa, name='mapa'),
]       