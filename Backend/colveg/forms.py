from django import forms
from .models import Produc
from .models import Comentario


class ProducForm(forms.ModelForm):
    image = forms.ImageField(widget=forms.ClearableFileInput, required=True)
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


class ComentarioForm(forms.ModelForm):
    class Meta:
        model = Comentario
        fields = ('comentario', 'autor')
