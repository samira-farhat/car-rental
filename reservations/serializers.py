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
    Optimized for tables / cards (no heavy nested data).
    """

    # Read user's full name from the User model
    user_name = serializers.CharField(
        source='user.get_full_name',
        read_only=True
    )

    # Nested car information
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

class AdminReservationDetailSerializer(serializers.ModelSerializer):
    """
    Serializer for viewing FULL reservation details.
    Used when admin taps on a reservation.
    """

    user_name = serializers.CharField(
        source='user.get_full_name',
        read_only=True
    )

    user_phone = serializers.CharField(
        source='user.phone',
        read_only=True
    )

    car = AdminCarSerializer(read_only=True)

    class Meta:
        model = Reservation
        fields = '__all__'
