# payments/serializers.py
from rest_framework import serializers
from .models import Payment
from rentals.models import Rental

class PaymentSerializer(serializers.ModelSerializer):
    user_name = serializers.SerializerMethodField()
    user_email = serializers.EmailField(source='user.email', read_only=True)

    car_name = serializers.SerializerMethodField()
    startdate = serializers.DateField(source='rental.startdate', read_only=True)
    enddate = serializers.DateField(source='rental.enddate', read_only=True)
    duration = serializers.SerializerMethodField()
    reservationid = serializers.SerializerMethodField()  # NEW

    class Meta:
        model = Payment
        fields = [
            'paymentid',
            'amount',
            'method',
            'status',
            'paymentdate',
            'rental',
            'user_name',
            'user_email',
            'car_name',
            'startdate',
            'enddate',
            'duration',
            'reservationid',  # NEW
        ]

    def get_car_name(self, obj):
        car = obj.rental.car
        return f"{car.brand} {car.model}"
    
    def get_user_name(self, obj):
        user = obj.user
        if not user:
            return ""
        names = [user.first_name, getattr(user, 'middle_name', ''), user.last_name]
        return ' '.join([n for n in names if n])
    
    def get_duration(self, obj):
        start = obj.rental.startdate
        end = obj.rental.enddate
        if start and end:
            delta = (end - start).days + 1  # Include both start and end
            return f"{delta} day{'s' if delta > 1 else ''}"
        return ""

    def get_reservationid(self, obj):
        rental = obj.rental
        if rental and getattr(rental, 'reservation', None):
            return rental.reservation_id
        return None




class CreatePaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = ['rental', 'method', 'amount']
        extra_kwargs = {
            'amount': {'read_only': True}  # we calculate this from rental
        }

    def validate(self, data):
        rental = data['rental']

        if rental.status != 'pending_payment':
            raise serializers.ValidationError("This rental is not pending payment.")

        return data

    def create(self, validated_data):
        rental = validated_data['rental']
        user = rental.user
        validated_data['user'] = user
        validated_data['amount'] = rental.totalamount
        payment = Payment.objects.create(**validated_data)
        return payment
