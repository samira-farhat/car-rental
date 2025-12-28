from rest_framework import serializers
from .models import Wishlist
from cars.serializers import CarSerializer

class WishlistSerializer(serializers.ModelSerializer):
    car = CarSerializer(read_only=True)
    user_id = serializers.IntegerField(source='user.id', read_only=True)

    class Meta:
        model = Wishlist
        fields = ['wishlistid', 'user_id', 'car', 'date_added']
