from __future__ import absolute_import, unicode_literals
import os
from celery import Celery

# Establecer la configuración de Django para que Celery pueda acceder a ella
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'Backend.settings')

app = Celery('Backend')

# Usar la configuración de Celery en settings.py
app.config_from_object('django.conf:settings', namespace='CELERY')

# Cargar tareas de tu aplicación
app.autodiscover_tasks()

# Esto se ejecutará antes de cada tarea
@app.task(bind=True)
def debug_task(self):
    print('Request: {0!r}'.format(self.request))

if __name__ == '__main__':
    app.start()