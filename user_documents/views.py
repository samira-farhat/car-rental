from rest_framework import generics, permissions
from .models import Documentation
from .serializers import DocumentationSerializer

class UploadDocumentView(generics.CreateAPIView):
    serializer_class = DocumentationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class MyDocumentsView(generics.ListAPIView):
    serializer_class = DocumentationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Documentation.objects.filter(user=self.request.user)
