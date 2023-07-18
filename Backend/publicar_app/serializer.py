from rest_framework import serializers
from .models import Produc, Comentario

# Serializer para el json de los productos 
class ProductoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Produc
        fields = (
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
# ----------------------------------------------------------------------------------------------------------------------

# serializer para el json de los comentarios
class ComentarioSerializer(serializers.ModelSerializer):
    class Meta:
        model = Comentario
        fields = (
            'comentario'
        )
# ----------------------------------------------------------------------------------------------------------------------
