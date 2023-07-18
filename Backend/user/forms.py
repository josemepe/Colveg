from django import forms
from django.contrib.auth.forms import UserCreationForm, PasswordChangeForm, UserChangeForm
from .models import ConfirmPsswordResetModel, LoginModel, RegisterUser, ResetPasswordModel, Verificar
from django.core.exceptions import ValidationError

#formulario para el registro de usuario
class CustomUserCreationForm(UserCreationForm):
    class Meta:
        model = RegisterUser
        fields = ('email', 'name', 'user_name','password1', 'password2')

class CustomUserChageForm(UserChangeForm):
    class Meta:
        model = RegisterUser
        fields = ('email', 'name', 'user_name')
#----------------------------------------------------------------------------------------------------------------------

#formulario para la verificaion de codigos de autenticacion
class VerificationCodeForm(forms.Form):
    class Meta:
        model = Verificar
        fields = ('code_email')
   
#----------------------------------------------------------------------------------------------------------------------

#formulario para el login
class LoginForm(forms.ModelForm):
    class Meta:
        model = LoginModel
        fields = ('email', 'password_login', 'tockenMensajes')
# ---------------------------------------------------------------------------------------------------------------------

# formulario para enviar link para restablecer contraseña
class ResetPassword(forms.ModelForm):
    class Meta:
        model = ResetPasswordModel
        fields = ('email', )
#----------------------------------------------------------------------------------------------------------------------

# formulario para el restablecimeinto de contraseña
class ResetPasswordConfirm(forms.Form):
    class Meta:
        model = ConfirmPsswordResetModel
        fields = ('password1', 'password2', 'user_id') 