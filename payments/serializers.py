from rest_framework import serializers
from .models import Payment

class PaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = [
            'PaymentID',
            'UserID',
            'RentalID',
            'Amount',
            'Method',
            'Status',
            'TransactionRef',
            'PaymentDate',
        ]
        read_only_fields = [
            'PaymentID',
            'UserID',
            'RentalID',
            'Amount',
            'Status',
            'TransactionRef',
            'PaymentDate',
        ]
