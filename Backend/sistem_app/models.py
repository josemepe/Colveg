from django.db import models
from user.models import RegisterUser


class UserModel (models.Model):
    user = models.OneToOneField(RegisterUser, on_delete=models.CASCADE)
    
# Modelo para los seguidos y seguidores
class FollowModel(models.Model):
    seguidor = models.ForeignKey(UserModel, related_name='seguidores', on_delete=models.CASCADE)
    siguiendo = models.ForeignKey(UserModel, related_name='siguiendo', on_delete=models.CASCADE)
    fecha_creacion = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = (('seguidor', 'siguiendo'),)