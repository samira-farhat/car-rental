# contains serializers for User registration, login, and password reset (to convert JSON data to python objects and validate data)

from rest_framework import serializers
from .models import User

# registration serializer
class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['first_name', 'middle_name', 'last_name', 'age', 'address', 'phone', 'email', 'password', 'role']

    # uses UserManager to create user and hash password
    def create(self, validated_data):
        password = validated_data.pop('password')
        user = User.objects.create_user(password=password, **validated_data)
        return user


# login serializer
class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)


# password reset serializer
class PasswordResetSerializer(serializers.Serializer):
    email = serializers.EmailField()
