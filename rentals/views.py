# rentals/views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import permissions
from .models import Rental
from .serializers import RentalSerializer

class UserRentedCarsView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        rentals = Rental.objects.filter(user=request.user, status='active')
        serializer = RentalSerializer(rentals, many=True)
        return Response(serializer.data, status=200)
