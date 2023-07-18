from django.contrib import admin

from .models import Produc, Comentario

# Register your models here.
class Comment (admin.StackedInline):
    model = Comentario
    extra = 0

class ProducAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'clasific', 
        'name', 
        'image', 
        'descrip', 
        'peso', 
        'unidad_peso', 
        'price', 
        'direccion',
        'fecha',
    )
    inlines = [
        Comment,
    ]
admin.site.register(Produc, ProducAdmin)
admin.site.register(Comentario)