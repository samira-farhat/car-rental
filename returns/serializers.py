from rest_framework import serializers
from .models import CarReturn

class CarReturnCreateSerializer(serializers.Serializer):
    rental_id = serializers.IntegerField()
    returndatetime = serializers.DateTimeField()
    mileage = serializers.IntegerField()
    condition = serializers.ChoiceField(choices=['excellent', 'minor_damage', 'major_damage'])
    comments = serializers.CharField(required=False, allow_blank=True)

class CarReturnSerializer(serializers.ModelSerializer):
    class Meta:
        model = CarReturn
        fields = "__all__"
