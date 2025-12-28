# reviews/views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from .serializers import ReviewSerializer

class SubmitReviewView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = ReviewSerializer(data=request.data)
        if serializer.is_valid():
            # The frontend now sends a car ID from the rentals API
            serializer.save(user=request.user)
            return Response({"message": "Review submitted successfully"}, status=201)
        return Response(serializer.errors, status=400)
