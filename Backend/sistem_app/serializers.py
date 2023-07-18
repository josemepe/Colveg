from rest_framework import serializers
from .models import UserModel, FollowModel

class FollowSerializer(serializers.ModelSerializer):
    class Meta:
        model = FollowModel
        fields = {
            'seguidor',
            'siguiendo'
        }