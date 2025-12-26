from rest_framework import serializers
from .models import Wishlist
from cars.serializers import CarSerializer

# converts wishlist objects to JSON, and includes car info
class WishlistSerializer(serializers.ModelSerializer):
    car = CarSerializer(read_only=True)  # embed car info
    user_id = serializers.IntegerField(source='user.id', read_only=True) # show user id

    class Meta:
        model = Wishlist
        fields = ['id', 'user_id', 'car', 'date_added']
