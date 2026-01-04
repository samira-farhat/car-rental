from django.conf import settings
from rest_framework.decorators import api_view, parser_classes, permission_classes
from rest_framework.response import Response
from rest_framework import status
from rest_framework.parsers import MultiPartParser, FormParser
from django.contrib.auth import authenticate
from .serializers import UserSerializer, LoginSerializer, PasswordResetSerializer
from .models import EmailVerificationCode, User
from rest_framework.permissions import AllowAny
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from django.core.mail import send_mail
from django.utils import timezone
import random
from datetime import timedelta
from django.contrib.auth import get_user_model
from notifications.services.notification_service import send_notification
# ------------------------
# HELPER FUNCTION
# ------------------------
def generate_and_send_code(user, purpose, subject, message_prefix):
    EmailVerificationCode.objects.filter(
        user=user, purpose=purpose, is_used=False
    ).update(is_used=True)

    code = str(random.randint(100000, 999999))

    EmailVerificationCode.objects.create(
        user=user,
        code=code,
        purpose=purpose,
        expires_at=timezone.now() + timedelta(minutes=10)
    )

    send_mail(
        subject=subject,
        message=f"{message_prefix} {code}",
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[user.email],
    )



# ------------------------
# REGISTRATION
# ------------------------
@api_view(['POST'])
@parser_classes([MultiPartParser, FormParser])
@permission_classes([AllowAny])
def register_user(request):
    serializer = UserSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save(is_active=True, is_verified=False)

        generate_and_send_code(
            user=user,
            purpose='verify',
            subject='Verify your account',
            message_prefix='Your verification code is:'
        )

        UserModel = get_user_model()
        admins = UserModel.objects.filter(role__in=['admin', 'manager'])

        message = f"New user {user.first_name} {user.last_name} has registered."
        send_notification(
            admins,
            message=message,
            notification_type='general',
            channels=('in_app', 'email')
        )

        return Response(
            {"message": "User registered successfully. Verification code sent to email."},
            status=status.HTTP_201_CREATED
        )

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ------------------------
# LOGIN
# ------------------------
class LoginUserView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            password = serializer.validated_data['password']
            user = authenticate(request, username=email, password=password)

            if user:
                if not user.is_verified:
                    return Response(
                        {"error": "Please verify your account first"},
                        status=status.HTTP_403_FORBIDDEN
                    )

                # Generate JWT tokens
                refresh = RefreshToken.for_user(user)
                return Response({
                    "refresh": str(refresh),
                    "access": str(refresh.access_token),
                    "role": "admin" if user.is_staff else "customer",
                    "is_staff": user.is_staff,
                    "message": "Login successful"
                }, status=status.HTTP_200_OK)

            return Response({"error": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# ------------------------
# FORGOT PASSWORD
# ------------------------
@api_view(['POST'])
@permission_classes([AllowAny])
def forgot_password(request):
    email = request.data.get('email')

    if not email:
        return Response({"error": "Email is required"}, status=400)

    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        return Response({"error": "Email not found"}, status=404)

    generate_and_send_code(
        user,
        purpose='reset',
        subject='Password Reset Code',
        message_prefix='Your password reset code is:'
    )

    return Response(
        {"message": "Reset code sent to your email"},
        status=200
    )


# ------------------------
# RESEND VERIFICATION CODE
# ------------------------
@api_view(['POST'])
@permission_classes([AllowAny])
def resend_verification_code(request):
    email = request.data.get('email')

    if not email:
        return Response({"error": "Email is required"}, status=400)

    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        return Response({"error": "User not found"}, status=404)

    if user.is_verified:
        return Response({"message": "User already verified"}, status=200)

    generate_and_send_code(
        user=user,
        purpose='verify',
        subject='Verify your account',
        message_prefix='Your verification code is:'
    )

    return Response({"message": "Verification code sent"}, status=200)


# ------------------------
# VERIFY ACCOUNT
# ------------------------
@api_view(['POST'])
@permission_classes([AllowAny])
def verify_account(request):
    """
    Verify a user by code.
    """
    email = request.data.get('email')
    code = request.data.get('code')

    if not email or not code:
        return Response({"error": "Email and code are required"}, status=status.HTTP_400_BAD_REQUEST)

    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

    try:
        verification = EmailVerificationCode.objects.get(user=user, code=code, is_used=False)
    except EmailVerificationCode.DoesNotExist:
        return Response({"error": "Invalid code"}, status=status.HTTP_400_BAD_REQUEST)

    if verification.expires_at < timezone.now():
        return Response({"error": "Code expired"}, status=status.HTTP_400_BAD_REQUEST)

    # Mark user as verified
    user.is_verified = True
    user.save()

    # Mark code as used
    verification.is_used = True
    verification.save()

    return Response({"message": "Account verified successfully"}, status=status.HTTP_200_OK)

@api_view(['POST'])
@permission_classes([AllowAny])
def verify_reset_code(request):
    email = request.data.get('email')
    code = request.data.get('code')

    if not email or not code:
        return Response({"error": "Email and code required"}, status=400)

    try:
        user = User.objects.get(email=email)
        verification = EmailVerificationCode.objects.get(
            user=user,
            code=code,
            purpose='reset',
            is_used=False
        )
    except (User.DoesNotExist, EmailVerificationCode.DoesNotExist):
        return Response({"error": "Invalid code"}, status=400)

    if verification.expires_at < timezone.now():
        return Response({"error": "Code expired"}, status=400)

    verification.is_used = True
    verification.save()

    return Response(
        {"message": "Code verified"},
        status=200
    )

@api_view(['POST'])
@permission_classes([AllowAny])
def reset_password(request):
    email = request.data.get('email')
    password = request.data.get('password')

    if not email or not password:
        return Response({"error": "Missing fields"}, status=400)

    try:
        user = User.objects.get(email=email)
    except User.DoesNotExist:
        return Response({"error": "User not found"}, status=404)

    user.set_password(password)
    user.save()

    return Response(
        {"message": "Password reset successful"},
        status=200
    )
