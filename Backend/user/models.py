from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager


class CustomUserManager(BaseUserManager):
    def create_user(self, email, password=None):
        if not email:
            raise ValueError('Users must have an email address')
        
        user = self.model(
            email=self.normalize_email(email),
        )
        
        user.set_password(password)
        user.save(using=self._db)
        return user
#----------------------------------------------------------------------------------------------------------------------


# infromacion necesraia para register
class RegisterUser(AbstractBaseUser):
    id = models.AutoField(primary_key=True)
    email = models.EmailField(unique=True)
    name = models.CharField(max_length=50)
    user_name = models.CharField(max_length=50, unique=True)
    # number_phone = models.CharField(max_length=20, unique=True)
    is_superuser = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    is_admin = models.BooleanField(default=False)

    USERNAME_FIELD = 'email'

    objects = CustomUserManager()

    def __str__(self):
        return self.email

    class Meta:
        db_table = 'custom_user'
#----------------------------------------------------------------------------------------------------------------------

# modelo para verificacion de codigos
class Verificar(models.Model):
    code_email = models.IntegerField()
    # code_phone = models.IntegerField()

    def __str__(self):
        return self.__all__

# ---------------------------------------------------------------------------------------------------------------------

#  modelo para el login 
class LoginModel(models.Model):
    email = models.EmailField(unique=True)
    password_login = models.CharField(max_length=100)
    tockenMensajes = models.CharField(max_length=300)

    def __str__(self):
        return self.email

# ---------------------------------------------------------------------------------------------------------------------

#  modelo para restablecr contraseña
class ResetPasswordModel(models.Model):
    email = models.EmailField()
    
    def __str__(self):
        return self.email

# ---------------------------------------------------------------------------------------------------------------------

#  modelo para restablecr contraseña
class ConfirmPsswordResetModel(models.Model):
    password1 = models.CharField(max_length=50)
    password2 = models.CharField(max_length=50)
    user_id = None
    
    def __init__(self, *args, **kwargs):
        self.user_id = kwargs.pop('user_id', None)
        super().__init__(*args, **kwargs)