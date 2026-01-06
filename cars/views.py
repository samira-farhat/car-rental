from django.shortcuts import get_object_or_404
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from .models import Car
from .serializers import AdminCarWriteSerializer, CarSerializer
from rest_framework.permissions import IsAdminUser
from rest_framework import status
from django.shortcuts import get_object_or_404
from django.db import transaction
from rest_framework.parsers import MultiPartParser, FormParser
from .models import Carcategory
from .serializers import CarCategorySerializer
from notifications.services.notification_service import send_notification
from django.contrib.auth import get_user_model

class CarCategoryListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        categories = Carcategory.objects.all()
        serializer = CarCategorySerializer(categories, many=True)
        return Response(serializer.data)
    
class CarListView(APIView):

    permission_classes = [AllowAny]
    
    def get(self, request):
        cars = Car.objects.all()
        serializer = CarSerializer(
            cars,
            many=True,
            context={'request': request}
        )
        return Response(serializer.data)


class AdminCarManagementView(APIView):
    """
    Admin-only API for managing cars.
    Supports image uploads.
    """

    permission_classes = [IsAdminUser]

    # Required to handle file uploads
    parser_classes = [MultiPartParser, FormParser]

    @transaction.atomic
    def post(self, request):
        """
        ADD a new car with image upload.
        Also sends a notification to all customers.
        """
        serializer = AdminCarWriteSerializer(data=request.data)

        if serializer.is_valid():
            car = serializer.save()

            # -------------------------------
            # SEND NOTIFICATION TO CUSTOMERS
            # -------------------------------
            User = get_user_model()
            customers = User.objects.filter(role='customer')  # all customers
            message = f"A new car {car.brand} {car.model} is now available!"
            send_notification(
            customers,
            message=message,
            notification_type='general',
            channels=('in_app', 'email')
        )

            return Response(
                {
                    "message": "Car added successfully.",
                    "car": CarSerializer(
                        car,
                        context={'request': request}
                    ).data
                },
                status=status.HTTP_201_CREATED
            )

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @transaction.atomic
    def put(self, request, car_id):
        """
        UPDATE an existing car.
        Allows updating image or other fields.
        """
        car = get_object_or_404(Car, carid=car_id)

        serializer = AdminCarWriteSerializer(
            car,
            data=request.data,
            partial=True
        )

        if serializer.is_valid():
            car = serializer.save()

            return Response(
                {
                    "message": "Car updated successfully.",
                    "car": CarSerializer(
                        car,
                        context={'request': request}
                    ).data
                },
                status=status.HTTP_200_OK
            )

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @transaction.atomic
    def delete(self, request, car_id):
        """
        DELETE a car and its image.
        """
        car = get_object_or_404(Car, carid=car_id)

        # Remove image file from storage if it exists
        if car.image:
            car.image.delete(save=False)

        car.delete()

        return Response(
            {"message": "Car deleted successfully."},
            status=status.HTTP_204_NO_CONTENT
        )
