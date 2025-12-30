# reservations/serializers.py

from rest_framework import serializers
from .models import Reservation
from cars.models import Car


class AdminCarSerializer(serializers.ModelSerializer):
    """
    Lightweight serializer for Car data used inside reservation responses.
    This avoids sending unnecessary fields to the admin UI.
    """

    # Combine brand + model + year into a single readable string
    car_name = serializers.SerializerMethodField()

    class Meta:
        model = Car
        fields = [
            'carid',
            'vin',
            'car_name',
            'image',
            'rentalpriceperday',
            'availabilitystatus'
        ]

    def get_car_name(self, obj):
        # Returns: "Toyota Yaris 2021"
        return f"{obj.brand} {obj.model} {obj.year}"


class AdminReservationListSerializer(serializers.ModelSerializer):
    """
    Serializer used for the admin reservation LIST screen.
    """

    user_name = serializers.SerializerMethodField()
    car = AdminCarSerializer(read_only=True)

    class Meta:
        model = Reservation
        fields = [
            'reservationid',
            'user_name',
            'car',
            'startdate',
            'enddate',
            'status',
            'createdat'
        ]

    def get_user_name(self, obj):
        user = obj.user
        if not user:
            return "Unknown User"

        # Works whether or not get_full_name exists
        first = getattr(user, 'first_name', '')
        last = getattr(user, 'last_name', '')
        full_name = f"{first} {last}".strip()

        return full_name if full_name else user.email

class AdminReservationDetailSerializer(serializers.ModelSerializer):
    """
    Serializer for viewing FULL reservation details.
    Used when admin taps on a reservation.
    """

    user_name = serializers.SerializerMethodField()
    user_phone = serializers.CharField(
        source='user.phone',
        read_only=True
    )
    user_email = serializers.CharField(
        source='user.email',
        read_only=True
    )
    car = AdminCarSerializer(read_only=True)
    
    duration = serializers.SerializerMethodField()
    total_amount = serializers.SerializerMethodField()
    
    def get_user_name(self, obj):
        user = obj.user
        if not user:
            return "Unknown User"

        # Works whether or not get_full_name exists
        first = getattr(user, 'first_name', '')
        last = getattr(user, 'last_name', '')
        full_name = f"{first} {last}".strip()

        return full_name if full_name else user.email
    
    def get_duration(self, obj):
        # Inclusive days
        return (obj.enddate - obj.startdate).days + 1

    def get_total_amount(self, obj):
        duration = (obj.enddate - obj.startdate).days + 1
        return duration * obj.car.rentalpriceperday
    
    class Meta:
        model = Reservation
        fields = '__all__'