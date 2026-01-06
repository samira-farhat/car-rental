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

# rentals/views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Rental
from .serializers import RentalDetailSerializer

class RentalByReservationView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, reservation_id):
        try:
            rental = Rental.objects.select_related('car').get(reservation_id=reservation_id)
        except Rental.DoesNotExist:
            return Response({'error': 'Rental not found'}, status=404)

        serializer = RentalDetailSerializer(rental)
        return Response(serializer.data)

class MyRentalsView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        qs = Rental.objects.filter(user=request.user)

        # optional filter: ?status=active or ?status=completed etc.
        st = request.query_params.get("status")
        if st:
            qs = qs.filter(status=st)

        qs = qs.order_by("-createdat")  # newest first
        serializer = RentalSerializer(qs, many=True)
        return Response(serializer.data, status=200)