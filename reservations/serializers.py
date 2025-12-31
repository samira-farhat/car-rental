# reservations/serializers.py

from rest_framework import serializers
from .models import Reservation
from cars.models import Car
from accounts.models import Documentation


class AdminCarSerializer(serializers.ModelSerializer):
    car_name = serializers.SerializerMethodField()
    image_url = serializers.SerializerMethodField()  # new field

    class Meta:
        model = Car
        fields = [
            'carid',
            'vin',
            'car_name',
            'image_url',  # use this instead of 'image'
            'rentalpriceperday',
            'availabilitystatus'
        ]

    def get_car_name(self, obj):
        return f"{obj.brand} {obj.model} {obj.year}"

    def get_image_url(self, obj):
        if obj.image:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.image.url)
            return obj.image.url  # fallback to relative path
        return None


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
    license = serializers.SerializerMethodField()
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
    
    def get_license(self, obj):
        license_doc = obj.user.documents.filter(
            document_type__iexact='driver license'
        ).first()

        if not license_doc:
            return None

        return UserLicenseSerializer(
            license_doc,
            context=self.context
        ).data
    class Meta:
        model = Reservation
        fields = '__all__'




# Serializer used by customers to create a reservation.
class CreateReservationSerializer(serializers.ModelSerializer):
   

    class Meta:
        model = Reservation
        fields = [
            'car',
            'startdate',
            'enddate',
        ]

    def validate(self, data):
        start = data['startdate']
        end = data['enddate']

        if start >= end:
            raise serializers.ValidationError(
                "End date must be after start date."
            )

        return data

        
class UserLicenseSerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = Documentation
        fields = ['document_type', 'status', 'image_url']

    def get_image_url(self, obj):
        request = self.context.get('request')
        if obj.document_image:
            if request:
                return request.build_absolute_uri(obj.document_image.url)
            return obj.document_image.url
        return None

# Serializer used by customers to create a reservation.
class CreateReservationSerializer(serializers.ModelSerializer):
   

    class Meta:
        model = Reservation
        fields = [
            'car',
            'startdate',
            'enddate',
        ]

    def validate(self, data):
        start = data['startdate']
        end = data['enddate']

        if start >= end:
            raise serializers.ValidationError(
                "End date must be after start date."
            )

        return data