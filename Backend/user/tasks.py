import datetime
from celery import shared_task
from firebase_admin import firestore

@shared_task
def delete_expired_codes():
    db = firestore.client()
    expired_codes = db.collection('code_temp').where('expiration', '<=', datetime.utcnow()+ datetime.timedelta(minutes=5)).get()
    for code in expired_codes:
        db.collection('code_temp').document(code.id).delete()
