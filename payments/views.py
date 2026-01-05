from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.db import transaction

from reservations.models import Reservation
from rentals.models import Rental
from payments.models import Payment


@api_view(['POST'])
@permission_classes([IsAuthenticated])
@transaction.atomic
def make_payment(request):
    user = request.user
    reservation_id = request.data.get('reservation')
    method = request.data.get('method')

    if not reservation_id or not method:
        return Response(
            {"error": "reservation and method are required"},
            status=status.HTTP_400_BAD_REQUEST
        )

    # ✅ Get approved reservation for this user
    try:
        reservation = Reservation.objects.select_for_update().get(
            reservationid=reservation_id,
            user=user,
            status='approved'
        )
    except Reservation.DoesNotExist:
        return Response(
            {"error": "Approved reservation not found"},
            status=status.HTTP_404_NOT_FOUND
        )

    # ✅ duration (match your approval logic: inclusive)
    duration = (reservation.enddate - reservation.startdate).days + 1
    if duration <= 0:
        return Response({"error": "Invalid reservation dates"}, status=400)

    total_amount = reservation.car.rentalpriceperday * duration

    # ✅ get or create rental linked to reservation
    rental, created = Rental.objects.get_or_create(
        reservation=reservation,
        defaults={
            "user": user,
            "car": reservation.car,
            "startdate": reservation.startdate,
            "enddate": reservation.enddate,
            "duration": duration,
            "totalamount": total_amount,
            "status": "active",  # ✅ until payment confirmed
        }
    )

    # ✅ prevent double payment
    existing_payment = Payment.objects.filter(RentalID=rental, UserID=user).first()
    if existing_payment:
        return Response({
            "message": "Payment already submitted",
            "payment_id": existing_payment.PaymentID,
            "rental_id": rental.rentalid,
            "total_amount": str(rental.totalamount),
            "payment_status": existing_payment.Status,
        }, status=status.HTTP_200_OK)

    # ✅ create payment
    payment = Payment.objects.create(
        UserID=user,
        RentalID=rental,
        Amount=total_amount,
        Method=method,
        Status='pending' if method == 'cash' else 'completed'
    )

    # ✅ after payment request:
    rental.status = 'active'
    rental.save()

    reservation.status = 'active'
    reservation.save()


    return Response({
        "message": "Payment successful",
        "payment_id": payment.PaymentID,
        "rental_id": rental.rentalid,
        "total_amount": str(total_amount),
        "payment_status": payment.Status,
    }, status=status.HTTP_201_CREATED)
