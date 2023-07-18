from django_cron import CronJobBase, Schedule
import datetime
from firebase_admin import firestore
from requests import Response

class MyCronJob(CronJobBase):
    RUN_EVERY_MINS = 1440 # se ejecuta cada 2 horas

    schedule = Schedule(run_every_mins=RUN_EVERY_MINS)
    code = 'sistem_app.cron.MyCronJob'    # un identificador único

    def do(self):
        # código que se ejecutará cada 2 horas
        db = firestore.client()
        db_ref = db.collection('produc')
        product_docs = db_ref.get()
        expiration_dates = []

        for doc in product_docs:

            # Obtener los datos del producto desde Firebase
            product_data = doc.to_dict()
            expiration_date = product_data.get('fecha')
            print(expiration_date)
            if expiration_date:
                expiration_dates.append(expiration_date)
                # Convertir la fecha de expiración a un objeto datetime
                expiration_datetime = datetime.strptime(expiration_date, '%Y-%m-%d')

                print(expiration_datetime)
                # Obtener la fecha actual
                current_datetime = datetime.now()

                print(current_datetime)
                # Verificar si la fecha de expiración es mayor a la fecha actual
                if expiration_datetime < current_datetime:
                    # La fecha de expiración es mayor, eliminar la publicación
                    # db_ref.delete()
                    return Response('Publicación eliminada.', status=202)
        else:
            return Response('La publicación no ha expirado.', status=200)
