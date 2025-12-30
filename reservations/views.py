# reservations/views.py

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAdminUser
from rest_framework import status

from django.db import transaction
from django.db.models import Q

from .models import Reservation
from rentals.models import Rental
from cars.models import Car

from .serializers import (
    AdminReservationListSerializer,
    AdminReservationDetailSerializer
)

from rest_framework.permissions import IsAuthenticated
from .serializers import CreateReservationSerializer


class AdminReservationListView(APIView):
    """
    Returns a list of reservations for admin users.
    Supports filtering by reservation status.
    """

    # Only staff/superusers can access
    permission_classes = [IsAdminUser]

    def get(self, request):
        # Optional query param: ?status=pending
        status_filter = request.GET.get('status')

        # Base queryset with joins for performance
        reservations = (
            Reservation.objects
            .select_related('user', 'car')
            .order_by('-createdat')
        )

        # Apply status filter if provided
        if status_filter:
            reservations = reservations.filter(status=status_filter)

        # Convert queryset to JSON
        serializer = AdminReservationListSerializer(reservations, many=True)
        return Response(serializer.data)

class AdminReservationDetailView(APIView):
    """
    Returns full details of a single reservation.
    Used when admin opens reservation details screen.
    """

    permission_classes = [IsAdminUser]

    def get(self, request, pk):
        try:
            reservation = Reservation.objects.select_related(
                'user', 'car'
            ).get(pk=pk)
        except Reservation.DoesNotExist:
            return Response(
                {'error': 'Reservation not found'},
                status=status.HTTP_404_NOT_FOUND
            )

        serializer = AdminReservationDetailSerializer(reservation)
        return Response(serializer.data)

class ApproveReservationView(APIView):
    """
    Admin action:
    - Approves a reservation
    - Creates a rental
    - Updates car availability
    ALL inside a database transaction
    """

    permission_classes = [IsAdminUser]

    @transaction.atomic
    def post(self, request, pk):
        """
        POST is used because this endpoint changes system state.
        """

        try:
            # Lock the reservation row to prevent race conditions
            reservation = Reservation.objects.select_for_update().get(pk=pk)
        except Reservation.DoesNotExist:
            return Response(
                {'error': 'Reservation not found'},
                status=status.HTTP_404_NOT_FOUND
            )

        # Prevent double-processing
        if reservation.status != 'pending':
            return Response(
                {'error': 'Reservation already processed'},
                status=status.HTTP_400_BAD_REQUEST
            )

        car = reservation.car

        # Safety check: car must be available
        if car.availabilitystatus != 'available':
            return Response(
                {'error': 'Car is not available'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Conflict detection:
        # Check if this car has overlapping approved/active rentals
        conflict_exists = Rental.objects.filter(
            car=car,
            status__in=['pending_payment', 'active'],
        ).filter(
            Q(startdate__lte=reservation.enddate) &
            Q(enddate__gte=reservation.startdate)
        ).exists()

        if conflict_exists:
            return Response(
                {'error': 'Car already booked in this period'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Calculate rental duration (inclusive)
        duration = (reservation.enddate - reservation.startdate).days + 1

        # Calculate total amount
        total_amount = duration * car.rentalpriceperday

        # Update reservation
        reservation.status = 'approved'
        reservation.approvedby = request.user
        reservation.save()

        # Create rental record
        rental = Rental.objects.create(
            reservation=reservation,
            user=reservation.user,
            car=car,
            startdate=reservation.startdate,
            enddate=reservation.enddate,
            duration=duration,
            totalamount=total_amount,
            approvedby=request.user
        )

        # Mark car as rented
        car.availabilitystatus = 'rented'
        car.save()

        return Response(
            {
                'message': 'Reservation approved successfully',
                'rental_id': rental.rentalid
            },
            status=status.HTTP_200_OK
        )

class RejectReservationView(APIView):
    """
    Admin action:
    Rejects a reservation and stores rejection reason.
    """

    permission_classes = [IsAdminUser]

    def post(self, request, pk):
        reason = request.data.get('reason')

        # Rejection must have a reason
        if not reason:
            return Response(
                {'error': 'Rejection reason is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            reservation = Reservation.objects.get(pk=pk)
        except Reservation.DoesNotExist:
            return Response(
                {'error': 'Reservation not found'},
                status=status.HTTP_404_NOT_FOUND
            )

        # Prevent double-processing
        if reservation.status != 'pending':
            return Response(
                {'error': 'Reservation already processed'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Update reservation
        reservation.status = 'rejected'
        reservation.rejectionreason = reason
        reservation.approvedby = request.user
        reservation.save()

        return Response(
            {'message': 'Reservation rejected successfully'},
            status=status.HTTP_200_OK
        )



from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q

from .models import Reservation
from .serializers import CreateReservationSerializer


# customer endpoint
# creates a reservation request (sets status = pending)
class CreateReservationView(APIView):

    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = CreateReservationSerializer(data=request.data)

        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )

        car = serializer.validated_data['car']
        startdate = serializer.validated_data['startdate']
        enddate = serializer.validated_data['enddate']

        # ensure car is available
        if car.availabilitystatus != 'available':
            return Response(
                {'error': 'Car is not available'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # check for duplicate / overlapping reservation
        conflict = Reservation.objects.filter(
            car=car,
            startdate__lte=enddate,
            enddate__gte=startdate
        ).exclude(
            status__in=['rejected', 'cancelled']
        ).exists()

        if conflict:
            return Response(
                {'error': 'You already have a reservation for this car during these dates.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # create reservation
        reservation = serializer.save(
            user=request.user,
            status='pending'
        )

        return Response(
            {
                'message': 'Reservation created successfully',
                'reservation_id': reservation.reservationid,
                'status': reservation.status
            },
            status=status.HTTP_201_CREATED
        )


# to get reserved dates of a car
class CarReservedDatesView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, car_id):
        reservations = Reservation.objects.filter(
            car_id=car_id,
            status__in=['pending', 'approved']
        ).values('startdate', 'enddate')

        return Response(reservations, status=status.HTTP_200_OK)
