from rest_framework import serializers
from .models import Car, Carcategory

class CarCategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Carcategory
        fields = ['categoryid', 'categoryname']


class CarSerializer(serializers.ModelSerializer):
    category = CarCategorySerializer(source='categoryid', read_only=True)
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = Car
        fields = [
            'carid',
            'vin',
            'brand',
            'model',
            'year',
            'rentalpriceperday',
            'availabilitystatus',
            'image_url',
            'category'
        ]

    def get_image_url(self, obj):
        request = self.context.get('request')
        if obj.image:
            return request.build_absolute_uri('/media/' + obj.image)
        return None
