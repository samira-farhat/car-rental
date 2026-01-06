# payments/views.py
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from .models import Payment
from .serializers import PaymentSerializer, CreatePaymentSerializer
from rentals.models import Rental
from django.shortcuts import get_object_or_404

class CreatePaymentView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = CreatePaymentSerializer(data=request.data)
        if serializer.is_valid():
            payment = serializer.save()
            # Update rental status
            rental = payment.rental
            rental.status = 'pending_payment'  # just in case
            rental.save()
            return Response(PaymentSerializer(payment).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ApprovePaymentView(APIView):
    permission_classes = [permissions.IsAdminUser]

    def post(self, request, payment_id):
        payment = get_object_or_404(Payment, paymentid=payment_id)

        if payment.status == 'completed':
            return Response({'error': 'Payment already completed'}, status=400)

        # Approve payment
        payment.status = 'completed'
        payment.save()

        # Update rental
        rental = payment.rental
        rental.status = 'active'
        rental.save()

        # Update reservation
        reservation = rental.reservation
        if reservation:
            reservation.status = 'completed'
            reservation.save()

        # Optionally, free car later when rental ends
        # car = rental.car
        # car.availabilitystatus = 'rented' # already set on reservation approval

        return Response({'message': 'Payment approved, rental activated, reservation completed'}, status=200)

class MyPaymentsView(APIView):
    """
    Customer can see their payments
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        payments = Payment.objects.filter(user=request.user)
        serializer = PaymentSerializer(payments, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

class PendingPaymentsView(APIView):
    permission_classes = [permissions.IsAdminUser]

    def get(self, request):
        payments = Payment.objects.filter(status='pending')
        serializer = PaymentSerializer(payments, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

class RejectPaymentView(APIView):
    permission_classes = [permissions.IsAdminUser]

    def post(self, request, payment_id):
        payment = get_object_or_404(Payment, paymentid=payment_id)

        if payment.status != 'pending':
            return Response({'error': 'Only pending payments can be rejected'}, status=status.HTTP_400_BAD_REQUEST)

        payment.status = 'failed'
        payment.save()

        # Optionally update rental
        rental = payment.rental
        rental.status = 'cancelled'
        rental.save()
        
        reservation = payment.rental.reservationid
        reservation.status = 'completed'  # mark reservation as completed
        reservation.save()
        
        car = rental.car
        car.availabilitystatus = "available"  # assuming your Car model has this field
        car.save()
        return Response({'message': 'Payment rejected and rental updated'}, status=status.HTTP_200_OK)

class ApprovedPaymentsView(APIView):
    permission_classes = [permissions.IsAdminUser]

    def get(self, request):
        payments = Payment.objects.filter(status='completed')
        serializer = PaymentSerializer(payments, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


class RejectedPaymentsView(APIView):
    permission_classes = [permissions.IsAdminUser]

    def get(self, request):
        payments = Payment.objects.filter(status='failed')
        serializer = PaymentSerializer(payments, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Payment, Rental
from .serializers import PaymentSerializer
from rentals.serializers import RentalSerializer

class PaymentByRentalView(APIView):
    def get(self, request, rental_id):
        try:
            payment = Payment.objects.filter(rental_id=rental_id).first()
            if payment:
                serializer = PaymentSerializer(payment)
                return Response({
                    "payment_exists": True,
                    "payment": serializer.data
                })
            else:
                rental = Rental.objects.get(rentalid=rental_id)
                serializer = RentalSerializer(rental)
                return Response({
                    "payment_exists": False,
                    "rental": serializer.data
                })
        except Rental.DoesNotExist:
            return Response({"error": "Rental not found"}, status=status.HTTP_404_NOT_FOUND)
