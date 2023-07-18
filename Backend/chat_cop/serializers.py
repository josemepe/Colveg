from rest_framework import serializers
from .models import Messages, UserProfile

#se hace la deserealizacion y serealizacion de el nombre en la clase de mensaje
class MessageSerializer(serializers.ModelSerializer):

    sender_name = serializers.SlugRelatedField(many=False, slug_field='username', queryset=UserProfile.objects.all())
    receiver_name = serializers.SlugRelatedField(many=False, slug_field='username', queryset=UserProfile.objects.all())

    class Meta:
        model = Messages
        fields = ['sender_name', 'receiver_name', 'description', 'time']

