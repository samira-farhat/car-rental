# contains the API logic for user authentication: registration, login, and password reset

from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import authenticate
from .serializers import UserSerializer, LoginSerializer, PasswordResetSerializer
from .models import User

# user registration API
# handles new user registrations, expects JSON: first_name, last_name, email.. 
@api_view(['POST'])
def register_user(request):
    
    serializer = UserSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response({"message": "User registered successfully."}, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)



# user login API
# authenticates user and returns success or failure
@api_view(['POST'])
def login_user(request):
   
    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        email = serializer.validated_data['email']
        password = serializer.validated_data['password']
        user = authenticate(request, username=email, password=password)
        if user:
            return Response({"message": "Login successful", "role": user.role}, status=status.HTTP_200_OK)
        return Response({"error": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)



# forgot password API (simple)
# sends a password reset email (still didnt put any real email tho)
@api_view(['POST'])
def forgot_password(request):
    
    serializer = PasswordResetSerializer(data=request.data)
    if serializer.is_valid():
        email = serializer.validated_data['email']
        try:
            user = User.objects.get(email=email)
            # TODO: send email with reset link
            return Response({"message": f"Password reset instructions sent to {email}"}, status=status.HTTP_200_OK)
        except User.DoesNotExist:
            return Response({"error": "Email not found"}, status=status.HTTP_404_NOT_FOUND)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
