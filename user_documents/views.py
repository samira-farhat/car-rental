from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.authentication import JWTAuthentication

from .models import Documentation


class MyDocumentsView(APIView):
    authentication_classes = [JWTAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user_id = request.user.id

        documents = Documentation.objects.filter(userid=user_id)

        data = []
        for doc in documents:
            data.append({
                "id": doc.documentid,
                "title": doc.documenttype,
                "status": doc.status,
                "image": doc.documentimage,
                "uploaded_at": doc.uploadedat,
            })

        return Response(data)
