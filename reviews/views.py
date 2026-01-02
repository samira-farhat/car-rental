# reviews/views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from .serializers import ReviewSerializer, CarReviewListSerializer
from .models import Review

class SubmitReviewView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = ReviewSerializer(data=request.data)
        if serializer.is_valid():
            # The frontend now sends a car ID from the rentals API
            serializer.save(user=request.user)
            return Response({"message": "Review submitted successfully"}, status=201)
        return Response(serializer.errors, status=400)



class CarReviewsView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, car_id):
        reviews = Review.objects.filter(car_id=car_id).order_by('-reviewdate')
        serializer = CarReviewListSerializer(reviews, many=True)
        return Response(serializer.data, status=200)
