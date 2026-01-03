# reviews/serializers.py
from rest_framework import serializers
from .models import Review

class ReviewSerializer(serializers.ModelSerializer):
    car_name = serializers.SerializerMethodField()
    car_image = serializers.SerializerMethodField()

    class Meta:
        model = Review
        fields = ['reviewid', 'user', 'car', 'car_name', 'car_image', 'rating', 'description', 'reviewdate']
        read_only_fields = ['reviewid', 'reviewdate', 'user']

    def get_car_name(self, obj):
        return f"{obj.car.brand} {obj.car.model} {obj.car.year}"

    def get_car_image(self, obj):
        return obj.car.image



# to read reviews on a certain car
class CarReviewListSerializer(serializers.ModelSerializer):
    user_name = serializers.SerializerMethodField()

    class Meta:
        model = Review
        fields = [
            'reviewid',
            'user_name',
            'rating',
            'description',
            'reviewdate',
        ]

    def get_user_name(self, obj):
        return obj.user.first_name
