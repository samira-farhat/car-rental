from rest_framework import generics, permissions
from accounts.models import Documentation

from .serializers import DocumentationSerializer

from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from accounts.models import Documentation
from .serializers import DocumentationSerializer

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def my_documents(request):
    docs = Documentation.objects.filter(user=request.user).order_by("-uploaded_at")
    return Response(DocumentationSerializer(docs, many=True).data)


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

