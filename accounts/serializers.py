# contains serializers for User registration, login, and password reset (to convert JSON data to python objects and validate data)

from rest_framework import serializers
from .models import User, Documentation

# registration serializer
class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)  # password should not be returned in API responses
    document_image = serializers.ImageField(write_only=True, required=True)  # now required

    class Meta:
        model = User
        # include all user fields + document_image
        fields = ['first_name', 'middle_name', 'last_name', 'age', 'address', 'phone', 'email', 'password', 'role', 'document_image']

    # uses UserManager to create user and hash password
    def create(self, validated_data):
        document_image = validated_data.pop('document_image')  # required, no default
        password = validated_data.pop('password')
        
        # create the user
        user = User.objects.create_user(password=password, **validated_data)
        
        # create a Documentation entry for the uploaded document
        Documentation.objects.create(
            user=user,
            document_type='Driver License',  # you can make this dynamic if needed
            document_image=document_image
        )
        return user


# login serializer
class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)


# password reset serializer
class PasswordResetSerializer(serializers.Serializer):
    email = serializers.EmailField()
