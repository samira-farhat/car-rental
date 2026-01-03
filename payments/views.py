from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from datetime import timedelta

from reservations.models import Reservation
from rentals.models import Rental
from payments.models import Payment


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def make_payment(request):
    user = request.user
    reservation_id = request.data.get('reservation')
    method = request.data.get('method')

    if not reservation_id or not method:
        return Response(
            {"error": "reservation and method are required"},
            status=status.HTTP_400_BAD_REQUEST
        )

    # 1️⃣ Get approved reservation
    try:
        reservation = Reservation.objects.get(
            reservationid=reservation_id,
            user=user,
            status='approved'
        )
    except Reservation.DoesNotExist:
        return Response(
            {"error": "Approved reservation not found"},
            status=status.HTTP_404_NOT_FOUND
        )

    # 2️⃣ Calculate duration (CORRECT WAY)
    duration = (reservation.enddate - reservation.startdate).days
    if duration <= 0:
        return Response(
            {"error": "Invalid reservation dates"},
            status=status.HTTP_400_BAD_REQUEST
        )

    # 3️⃣ Calculate total amount (CORRECT FIELD)
    price_per_day = reservation.car.rentalpriceperday
    total_amount = price_per_day * duration

    # 4️⃣ Create rental
    rental = Rental.objects.create(
        user=user,
        reservation=reservation,
        car=reservation.car,
        startdate=reservation.startdate,
        enddate=reservation.enddate,
        duration=duration,
        totalamount=total_amount,
        status='active'
    )

    # 5️⃣ Create payment (FIELD NAMES MUST MATCH MODEL)
    payment = Payment.objects.create(
        UserID=user,
        RentalID=rental,
        Amount=total_amount,
        Method=method,
        Status='completed' if method == 'card' else 'pending'
    )

    # 6️⃣ Update reservation
    reservation.status = 'completed'
    reservation.save()

    return Response({
    "message": "Payment successful",
    "payment_id": payment.PaymentID,
    "rental_id": rental.rentalid,
    "total_amount": str(total_amount),
    "payment_status": payment.Status   # ✅ ADD THIS LINE
}, status=status.HTTP_201_CREATED)

