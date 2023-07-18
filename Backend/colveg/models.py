from django.db import models
from django.contrib.auth.models import User
from django.conf import settings

# Create your models here.

#Modelo para publicaciones
class Produc(models.Model):
    Categoria = (
        ('Papa', 'Papa'),
        ('Aguacate', 'Aguacate')
    )

    PESO_CHOICES = (
        ('kg', 'Kilogramos'),
        ('lb', 'Libras')
    )

    id = models.AutoField(primary_key=True)
    clasific = models.CharField(max_length=30, blank=False, null=False, choices=Categoria)
    name = models.CharField(max_length=30, blank=False, null=False)
    image = models.ImageField(upload_to='images/', blank=False)
    descrip = models.CharField(max_length=30, blank=False, null=False) 
    peso = models.IntegerField( blank=False, null=False)
    unidad_peso = models.CharField(max_length=2, choices=PESO_CHOICES)
    price = models.IntegerField( blank=False, null=False)
    direccion = models.CharField(max_length=50, blank=False, null=False)
    fecha = models.DateTimeField()

    
    def __str__(self):
        return self.name


class Comentario(models.Model):
    Produc = models.ForeignKey(Produc, on_delete=models.CASCADE)
    comentario = models.CharField(max_length=140)
    autor = models.ForeignKey(User, on_delete=models.CASCADE)

    def __str__(self):
        return self.autor, self.comentario

    
