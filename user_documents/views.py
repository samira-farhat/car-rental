from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.authentication import JWTAuthentication
from accounts.models import Documentation

class MyDocumentsView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request):
        documents = Documentation.objects.filter(user=request.user)

        data = []
        for doc in documents:
            data.append({
                "id": doc.id,
                "type": doc.document_type,
                "status": doc.status,
                "file": doc.document_image.url if doc.document_image else None,
                "uploaded_at": doc.uploaded_at,
            })

        return Response(data)
    
    
