from django.urls import path
from .views import UploadDocumentView
from . import views

urlpatterns = [
    path('upload/', UploadDocumentView.as_view(), name='upload-document'),
    path('my/', views.my_documents, name='my-documents'),
]
