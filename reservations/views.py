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
        serializer = AdminReservationListSerializer(
            reservations,
            many=True,
            context={'request': request}
            )
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
            

        serializer = AdminReservationDetailSerializer(
            reservation,
            context={'request': request}
        )

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
