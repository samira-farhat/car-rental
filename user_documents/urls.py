from django.urls import path
from .views import UploadDocumentView, MyDocumentsView

urlpatterns = [
    path("upload/", UploadDocumentView.as_view(), name="upload-document"),
    path("my/", MyDocumentsView.as_view(), name="my-documents"),
]
