# rentals/views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions, status
from django.shortcuts import get_object_or_404
from .models import Rental
from .serializers import RentalSerializer, RentalDetailSerializer


class UserRentedCarsView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        rentals = Rental.objects.filter(user=request.user, status='active')
        serializer = RentalSerializer(rentals, many=True)
        return Response(serializer.data, status=200)


class RentalDetailView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, rental_id):
        rental = get_object_or_404(
            Rental,
            rentalid=rental_id,
            user=request.user
        )
        serializer = RentalDetailSerializer(rental)
        return Response(serializer.data, status=200)
