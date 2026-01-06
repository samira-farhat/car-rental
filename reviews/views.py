# reviews/views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from .serializers import ReviewSerializer
from django.contrib.auth import get_user_model
from notifications.services.notification_service import send_notification
from .serializers import ReviewSerializer, CarReviewListSerializer
from .models import Review
from rest_framework.permissions import IsAuthenticated

class SubmitReviewView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = ReviewSerializer(data=request.data)
        if serializer.is_valid():
            # The frontend now sends a car ID from the rentals API
            review = serializer.save(user=request.user)
            User = get_user_model()
            admins = User.objects.filter(role__in=['admin','manager'])
            message = f"{review.user.first_name} {review.user.last_name} submitted a review for {review.car.brand} {review.car.model}."
            send_notification(
            admins,
            message=message,
            notification_type='general',
            channels=('in_app', 'email')
        )
            return Response({"message": "Review submitted successfully"}, status=201)
        return Response(serializer.errors, status=400)


# GET view
class CarReviewsView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, car_id):
        reviews = Review.objects.filter(car_id=car_id).order_by('-reviewdate')
        serializer = CarReviewListSerializer(reviews, many=True)
        return Response(serializer.data, status=200)

class MyReviewsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        reviews = (
            Review.objects
            .filter(user=request.user)
            .select_related('car')
            .order_by('-reviewdate')
        )

        data = []
        for r in reviews:
            data.append({
                "id": r.reviewid,
                "rating": r.rating,
                "comment": r.description,
                "car": f"{r.car.brand} {r.car.model}",
                "date": r.reviewdate,
            })

        return Response(data, status=200)