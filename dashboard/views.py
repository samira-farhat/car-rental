# dashboard/views.py

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAdminUser

from cars.models import Car
from reservations.models import Reservation
from rentals.models import Rental
from accounts.models import User

# for admin dashboard summary/ stats
class AdminDashboardSummaryView(APIView):

    permission_classes = [IsAdminUser]

    def get(self, request):
        data = {
            # Cars
            "total_cars": Car.objects.count(),
            "available_cars": Car.objects.filter(availabilitystatus='available').count(),
            "rented_cars": Car.objects.filter(availabilitystatus='rented').count(),

            # Reservations
            "pending_reservations": Reservation.objects.filter(status='pending').count(),
            "approved_reservations": Reservation.objects.filter(status='approved').count(),

            # Rentals
            "active_rentals": Rental.objects.filter(status='active').count(),
            "completed_rentals": Rental.objects.filter(status='completed').count(),

            # Users
            "total_customers": User.objects.filter(role='customer').count(),
        }

        return Response(data)
