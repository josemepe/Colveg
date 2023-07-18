from django.contrib import admin
from .models import RegisterUser
from django.contrib.auth.admin import UserAdmin
from .forms import CustomUserChageForm, CustomUserCreationForm

# datos necesarios para el registro de usuarios
class UserAdmin(admin.ModelAdmin):
    add_form = CustomUserCreationForm
    form = CustomUserChageForm
    model = RegisterUser
    list_display = (
        'id',
        'email', 
        'name', 
        'user_name',
        # 'number_phone',
        'is_superuser',
        'is_active',
    )
    
    
admin.site.register(RegisterUser, UserAdmin)