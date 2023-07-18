from django.db import models
from django.contrib.auth.models import User
from django.conf import settings
from django.urls import reverse
from django.db import models

import user


#Modelo para realizar publicaciones
class Produc(models.Model):
    PESO_CHOICES = (
        ('kilos', 'Kilos'),
        ('libras', 'libras'),
        ('unidad', 'unidad'),
        ('gramos', 'gramos'),
        ('onzas', 'onzas'),
        ('Litros','Litros'),
        ('mililitros', 'mililitros')
    )

    id = models.AutoField(primary_key=True)
    clasific = models.CharField(max_length=30, blank=False, null=False)
    name = models.CharField(max_length=30, blank=False, null=False)
    image = models.CharField(max_length=250, blank=False)
    descrip = models.CharField(max_length=30, blank=False, null=False) 
    peso = models.IntegerField( blank=False, null=False)
    unidad_peso = models.CharField(max_length=10, choices=PESO_CHOICES)
    price = models.IntegerField( blank=False, null=False)
    direccion = models.CharField(max_length=50, blank=False, null=False)
    fecha = models.DateTimeField()

    
    def __str__(self):
        return self.name
#----------------------------------------------------------------------------------------------------------------------

#modelo para realizar comentarios
class Comentario(models.Model):
    Produc = models.ForeignKey(Produc, on_delete=models.CASCADE)
    comentario = models.CharField(max_length=140)

    def __str__(self):
        return self.comentario
    
    
    
# ----------------------------------------------------------------------------------------------------------------------
    
