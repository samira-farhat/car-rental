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
            'description',
            'rentalpriceperday',
            'availabilitystatus',
            'image_url',
            'category'
        ]

    def get_image_url(self, obj):
        request = self.context.get('request')
        if obj.image:
            return request.build_absolute_uri(obj.image.url)
        return None



class AdminCarWriteSerializer(serializers.ModelSerializer):
    """
    Serializer used ONLY for admin create/update operations.
    Handles image file uploads.
    """

    categoryid = serializers.PrimaryKeyRelatedField(
        queryset=Carcategory.objects.all(),
        required=False,
        allow_null=True
    )

    image = serializers.ImageField(
        required=False,
        allow_null=True
    )

    class Meta:
        model = Car
        fields = [
            'vin',
            'brand',
            'model',
            'year',
            'description',
            'rentalpriceperday',
            'availabilitystatus',
            'image',
            'categoryid'
        ]

    def validate_year(self, value):
        """
        Ensures the car year is realistic.
        """
        if value < 1886:
            raise serializers.ValidationError("Car year must be 1886 or later.")
        return value