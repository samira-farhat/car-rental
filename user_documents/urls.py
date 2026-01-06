from django.urls import path
from .views import MyDocumentsView

urlpatterns = [
    path('my/', MyDocumentsView.as_view(), name='my-documents'),
]