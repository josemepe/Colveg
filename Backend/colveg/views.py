#se hace la importacion de librerias
from django.shortcuts import render, redirect
from django.http import HttpResponse
from .models import Produc
from .forms import ProducForm, ComentarioForm
from django.http import JsonResponse
from .import models
from django.views.generic import DetailView
from django.shortcuts import render, get_object_or_404, redirect
from .forms import ComentarioForm
from django.urls import reverse, reverse_lazy

# api para subir el producto
def create_product(request):
    #en esta se hace un metodo post la cual  trae al home la publicacion con todos los campos llenos 
    if request.method == 'POST':
        form = ProducForm(request.POST, request.FILES)
        if form.is_valid():
            product = form.save()
            response_data = {
                'message': 'Producto subido con éxito',
                'product_id': product.pk,
            }
            return JsonResponse(response_data, status=201)
        else:
            for field in form:
                if field.errors:
                    return HttpResponse('Por favor, complete todos los campos.')
    else:
        form = ProducForm()
    return render(request, 'publicar.html', {'form': form})

def product_detail(request):
    product = Produc.objects.all
    return render(request, 'publicacion.html', {'product': product})

class CommentPubli(DetailView):
    model=Produc
    template_name = "publicacion.html"
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["form"] = ComentarioForm 
        return context


#se hace la api donde puedes comentar una publicacion 
class CommentPost(ComentarioForm):
    model = Produc
    from_class = ComentarioForm
    template_name = "publicacion.html"

    def post(self, request, *args, **kwargs):
        self.object = self.get_object()
        return super().post(request, *args, **kwargs)
    
    def valid (self, form):
        comment = form.save
        comment.product = self.object
        comment.save()
        return super().valid(form)
    
    def get_succes_url(self):
        comentario = self.get_object()
        return reverse("publicacion", kwargs={"pk": comentario.pk})

class CommentView(DetailView):
    def get(self, request, *args, **kwargs):
        view=CommentPubli.as_view()
        return view('GET request!')

    def post(self, request, *args, **kwargs):
        view=CommentPost.as_view()
        return view('POST request!')

'''def agregar_comentario(request, pk):
    Producto = get_object_or_404(Produc, pk=pk)
    if request.method == 'POST':
        form = ComentarioForm(request.POST)
        if form.is_valid():
            comentario = form.save(commit=False)
            comentario.publicacion = Producto
            comentario.autor = request.user
            comentario.save()
            return redirect('publicacion', pk=Produc.pk)
    else:
        form = ComentarioForm()
    return render(request, 'comentario.html', {'form': form})'''
