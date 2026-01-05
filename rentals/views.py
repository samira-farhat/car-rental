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
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from django.db import transaction
from payments.models import Payment
from reservations.models import Reservation


def _is_manager(user):
    return user.role in ['manager', 'admin']


@api_view(['POST'])
@permission_classes([IsAuthenticated])
@transaction.atomic
def approve_rental_payment(request, rental_id):
    if not _is_manager(request.user):
        return Response(
            {"error": "Only managers can approve payments"},
            status=status.HTTP_403_FORBIDDEN
        )

    rental = get_object_or_404(Rental, rentalid=rental_id)

    if rental.status != 'pending_payment':
        return Response(
            {"error": f"Rental is not pending payment (current: {rental.status})"},
            status=status.HTTP_400_BAD_REQUEST
        )

    # get payment
    payment = Payment.objects.filter(RentalID=rental).order_by('-PaymentDate').first()
    if not payment:
        return Response(
            {"error": "No payment found for this rental"},
            status=status.HTTP_400_BAD_REQUEST
        )

    # update statuses
    rental.status = 'active'
    rental.approvedby = request.user
    rental.save()

    payment.Status = 'completed'
    payment.save()

    if rental.reservation:
        rental.reservation.status = 'completed'
        rental.reservation.save()

    return Response({
        "message": "Rental approved successfully",
        "rental_id": rental.rentalid,
        "rental_status": rental.status,
        "payment_status": payment.Status,
        "reservation_status": rental.reservation.status if rental.reservation else None
    }, status=status.HTTP_200_OK)

from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import api_view, permission_classes
from django.db.models import Q

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def pending_payment_rentals(request):
    if request.user.role not in ['manager', 'admin']:
        return Response({"error": "Unauthorized"}, status=403)

    rentals = Rental.objects.filter(status='pending_payment')
    data = []

    for r in rentals:
        data.append({
            "rental_id": r.rentalid,
            "customer": r.user.email,
            "car": r.car.name,
            "total_amount": str(r.totalamount),
            "reservation_id": r.reservation.reservationid if r.reservation else None,
            "created_at": r.createdat,
        })

    return Response(data, status=200)
