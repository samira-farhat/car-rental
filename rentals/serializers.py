# rentals/serializers.py
from rest_framework import serializers
from .models import Rental

class RentalSerializer(serializers.ModelSerializer):
    car_id = serializers.IntegerField(source='car.carid', read_only=True)
    car_name = serializers.SerializerMethodField()
    car_image = serializers.SerializerMethodField()

    class Meta:
        model = Rental
        fields = ['rentalid', 'car_id', 'car_name', 'car_image', 'startdate', 'enddate', 'status']

    def get_car_name(self, obj):
        return f"{obj.car.brand} {obj.car.model} {obj.car.year}"

    def get_car_image(self, obj):
        if obj.car.image:
            return obj.car.image.url
        return None



# to get rental details
from rest_framework import serializers
from .models import Rental

class RentalDetailSerializer(serializers.ModelSerializer):
    car_name = serializers.SerializerMethodField()
    car_image = serializers.SerializerMethodField()

    class Meta:
        model = Rental
        fields = [
            'rentalid',
            'car_name',
            'car_image',
            'startdate',
            'enddate',
            'duration',
            'totalamount',
            'status',
        ]

    def get_car_name(self, obj):
        return f"{obj.car.brand} {obj.car.model} {obj.car.year}"

    def get_car_image(self, obj):
        if obj.car.image:
            return obj.car.image.url
        return None
