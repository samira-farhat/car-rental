from django.urls import path
from .views import MyDocumentsView

urlpatterns = [
    path('me/', MyDocumentsView.as_view(), name='my-documents'),
]
