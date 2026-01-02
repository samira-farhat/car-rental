from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.utils import timezone
import uuid

from .models import Payment
from rentals.models import Rental


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def make_payment(request):
    user = request.user

    rental_id = request.data.get('rental_id')
    payment_method = request.data.get('payment_method')
    amount = request.data.get('amount')

    # 1️⃣ Validate rental
    try:
        rental = Rental.objects.get(RentalID=rental_id, UserID=user)
    except Rental.DoesNotExist:
        return Response(
            {"error": "Rental not found"},
            status=status.HTTP_404_NOT_FOUND
        )

    if rental.Status != 'pending_payment':
        return Response(
            {"error": "Payment already processed"},
            status=status.HTTP_400_BAD_REQUEST
        )

    if float(amount) != float(rental.TotalAmount):
        return Response(
            {"error": "Invalid payment amount"},
            status=status.HTTP_400_BAD_REQUEST
        )

    # 2️⃣ Create payment record
    payment = Payment.objects.create(
        UserID=user,
        RentalID=rental,
        Amount=amount,
        Method=payment_method,
        Status='pending',
        PaymentDate=timezone.now()
    )

    # 3️⃣ Process payment (simulated)
    if payment_method == 'card':
        payment.Status = 'completed'
        rental.Status = 'active'
    elif payment_method == 'cash':
        payment.Status = 'pending'
        rental.Status = 'pending_payment'
    else:
        payment.Status = 'failed'

    payment.TransactionRef = f"PAY-{uuid.uuid4().hex[:10].upper()}"

    payment.save()
    rental.save()

    return Response({
        "message": "Payment processed successfully",
        "payment_status": payment.Status,
        "transaction_ref": payment.TransactionRef
    })
