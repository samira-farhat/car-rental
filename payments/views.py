from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from reservations.models import Reservation
from rentals.models import Rental
from payments.models import Payment


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def make_payment(request):
    user = request.user
    reservation_id = request.data.get('reservation')
    method = request.data.get('method')

    # 1️⃣ Validate input
    if not reservation_id or not method:
        return Response(
            {"error": "reservation and method are required"},
            status=status.HTTP_400_BAD_REQUEST
        )

    # 2️⃣ Get approved reservation
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

    # 3️⃣ Calculate duration
    duration = (reservation.enddate - reservation.startdate).days
    if duration <= 0:
        return Response(
            {"error": "Invalid reservation dates"},
            status=status.HTTP_400_BAD_REQUEST
        )

    # 4️⃣ Calculate total amount
    total_amount = reservation.car.rentalpriceperday * duration

    # 5️⃣ Get or create rental (CRITICAL FIX)
    rental, created = Rental.objects.get_or_create(
        reservation=reservation,
        defaults={
            "user": user,
            "car": reservation.car,
            "startdate": reservation.startdate,
            "enddate": reservation.enddate,
            "duration": duration,
            "totalamount": total_amount,
            "status": "active",
        }
    )

    # 6️⃣ Create payment
    payment = Payment.objects.create(
        UserID=user,
        RentalID=rental,
        Amount=total_amount,
        Method=method,
        Status='completed' if method == 'card' else 'pending'
    )

    # 7️⃣ Update reservation status safely
    if reservation.status != 'completed':
        reservation.status = 'completed' if method == 'card' else 'approved'
        reservation.save()

    # 8️⃣ Response
    return Response({
        "message": "Payment successful",
        "payment_id": payment.PaymentID,
        "rental_id": rental.rentalid,
        "total_amount": str(total_amount),
        "payment_status": payment.Status,
    }, status=status.HTTP_201_CREATED)
