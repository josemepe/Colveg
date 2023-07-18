from django.contrib import admin
from .models import Produc, Comentario


# parametros requeridos para realizar un comentario
class Comment (admin.StackedInline):
    model = Comentario
    Extra = 0
#----------------------------------------------------------------------------------------------------------------------

# parametros requeridos para realizar una publicacion
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