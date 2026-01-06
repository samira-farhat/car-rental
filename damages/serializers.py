from rest_framework import serializers
from .models import Damage
from cars.models import Car
from cars.serializers import CarSerializer

class AdminDamageSerializer(serializers.ModelSerializer):
    """
    Serializer for reading/displaying Damage data, includes car details.
    """
    car = CarSerializer(read_only=True)
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = Damage
        fields = [
            'damageid',
            'car',
            'rental',
            'reportdate',
            'description',
            'repaircost',
            'status',
            'handledby',
            'image_url',
        ]

    def get_image_url(self, obj):
        """
        Since `image` is a CharField storing the filename/path,
        we combine it with MEDIA_URL to generate the full URL.
        """
        request = self.context.get('request')
        if obj.image:
            return request.build_absolute_uri('/media/' + obj.image)
        return None


class AdminDamageWriteSerializer(serializers.ModelSerializer):
    """
    Serializer for creating/updating damage records.
    Handles image uploads.
    """
    car = serializers.PrimaryKeyRelatedField(queryset=Car.objects.all())
    # accept the uploaded file as bytes, we'll save it manually
    image = serializers.ImageField(required=False, allow_null=True)

    class Meta:
        model = Damage
        fields = [
            'car',
            'rental',
            'reportdate',
            'description',
            'repaircost',
            'status',
            'handledby',
            'image',
        ]

    def validate_description(self, value):
        if len(value) < 10:
            raise serializers.ValidationError("Description must be at least 10 characters.")
        return value

    def validate_repaircost(self, value):
        if value is not None and value < 0:
            raise serializers.ValidationError("Repair cost cannot be negative.")
        return value

    def create(self, validated_data):
        """
        Override to handle saving image filename manually
        since Damage.image is a CharField.
        """
        image_file = validated_data.pop('image', None)
        if image_file:
            filename = f"damages/{image_file.name}"
            with open(f"media/{filename}", "wb") as f:
                for chunk in image_file.chunks():
                    f.write(chunk)
            validated_data['image'] = filename
        return super().create(validated_data)

    def update(self, instance, validated_data):
        """
        Override to handle updating the image file if provided.
        """
        image_file = validated_data.pop('image', None)
        if image_file:
            # optional: delete old image file
            if instance.image:
                import os
                old_path = f"media/{instance.image}"
                if os.path.exists(old_path):
                    os.remove(old_path)
            filename = f"damages/{image_file.name}"
            with open(f"media/{filename}", "wb") as f:
                for chunk in image_file.chunks():
                    f.write(chunk)
            validated_data['image'] = filename
        return super().update(instance, validated_data)
