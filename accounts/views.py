from datetime import timedelta
import random

from django.conf import settings
from django.contrib.auth import authenticate, get_user_model
from django.core.mail import send_mail
from django.utils import timezone

from rest_framework.decorators import api_view, permission_classes, parser_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.views import APIView

from rest_framework_simplejwt.tokens import RefreshToken

from .models import Documentation, EmailVerificationCode, User
from .serializers import UserSerializer, LoginSerializer
from notifications.services.notification_service import send_notification


# -------------------------------------------------
# HELPER: GENERATE & SEND CODE
# -------------------------------------------------
def generate_and_send_code(user, purpose, subject, message_prefix):
    EmailVerificationCode.objects.filter(
        user=user,
        purpose=purpose,
        is_used=False
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
        fail_silently=False,
    )


# -------------------------------------------------
# REGISTER
# -------------------------------------------------
@api_view(['POST'])
@parser_classes([MultiPartParser, FormParser])
@permission_classes([AllowAny])
def register_user(request):
    serializer = UserSerializer(data=request.data)

    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    user = serializer.save(is_active=False, is_verified=False)

    generate_and_send_code(
        user=user,
        purpose='verify',
        subject='Verify your account',
        message_prefix='Your verification code is:'
    )

    UserModel = get_user_model()
    admins = UserModel.objects.filter(
        role__in=['admin', 'manager'],
        is_active=True
    )

    send_notification(
        users=list(admins),
        message=f"New user {user.first_name} {user.last_name} has registered.",
        notification_type='general',
        channels=('in_app',)
    )

    return Response(
        {"message": "Registration successful. Verification code sent."},
        status=status.HTTP_201_CREATED
    )


# -------------------------------------------------
# LOGIN
# -------------------------------------------------
class LoginUserView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)

        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        email = serializer.validated_data['email']
        password = serializer.validated_data['password']

        user = authenticate(request, username=email, password=password)

        if not user:
            return Response({"error": "Invalid credentials"}, status=401)

        if not user.is_verified:
            return Response(
                {"error": "Please verify your account first"},
                status=403
            )

        refresh = RefreshToken.for_user(user)

        return Response({
            "refresh": str(refresh),
            "access": str(refresh.access_token),
            "role": user.role,
            "is_staff": user.is_staff,
            "message": "Login successful"
        }, status=200)


# -------------------------------------------------
# FORGOT PASSWORD
# -------------------------------------------------
@api_view(['POST'])
@permission_classes([AllowAny])
def forgot_password(request):
    email = request.data.get('email')

    if not email:
        return Response({"error": "Email is required"}, status=400)

    try:
        user = User.objects.get(email=email, is_active=True)
    except User.DoesNotExist:
        return Response({"error": "Email not found"}, status=404)

    generate_and_send_code(
        user=user,
        purpose='reset',
        subject='Password Reset Code',
        message_prefix='Your password reset code is:'
    )

    return Response({"message": "Reset code sent"}, status=200)


# -------------------------------------------------
# RESEND VERIFICATION CODE
# -------------------------------------------------
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

    return Response({"message": "Verification code resent"}, status=200)


# -------------------------------------------------
# VERIFY ACCOUNT
# -------------------------------------------------
@api_view(['POST'])
@permission_classes([AllowAny])
def verify_account(request):
    email = request.data.get('email')
    code = request.data.get('code')

    if not email or not code:
        return Response({"error": "Email and code required"}, status=400)

    try:
        user = User.objects.get(email=email)
        verification = EmailVerificationCode.objects.get(
            user=user,
            code=code,
            purpose='verify',
            is_used=False
        )
    except (User.DoesNotExist, EmailVerificationCode.DoesNotExist):
        return Response({"error": "Invalid verification code"}, status=400)

    if verification.expires_at < timezone.now():
        return Response({"error": "Code expired"}, status=400)

    user.is_verified = True
    user.is_active = True
    user.save(update_fields=['is_verified', 'is_active'])

    verification.is_used = True
    verification.save(update_fields=['is_used'])

    return Response({"message": "Account verified successfully"}, status=200)


# -------------------------------------------------
# VERIFY RESET CODE
# -------------------------------------------------
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
    verification.save(update_fields=['is_used'])

    return Response({"message": "Code verified"}, status=200)


# -------------------------------------------------
# RESET PASSWORD
# -------------------------------------------------
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
    user.save(update_fields=['password'])

    return Response({"message": "Password reset successful"}, status=200)


# -------------------------------------------------
# USER PROFILE
# -------------------------------------------------
@api_view(['GET', 'PUT'])
@permission_classes([IsAuthenticated])
def user_profile(request):
    user = request.user

    if request.method == 'GET':
        return Response({
            'first_name': user.first_name,
            'middle_name': user.middle_name,
            'last_name': user.last_name,
            'email': user.email,
            'phone': user.phone,
            'address': user.address,
        })

    user.first_name = request.data.get('first_name', user.first_name)
    user.middle_name = request.data.get('middle_name', user.middle_name)
    user.last_name = request.data.get('last_name', user.last_name)
    user.phone = request.data.get('phone', user.phone)
    user.address = request.data.get('address', user.address)
    user.save()

    return Response({"message": "Profile updated successfully"}, status=200)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def verify_documentation(request):
    if request.user.role not in ['admin', 'manager']:
        return Response({"error": "Permission denied"}, status=403)

    document_id = request.data.get('document_id')
    action = request.data.get('action')  # verified | rejected

    if not document_id or action not in ['verified', 'rejected']:
        return Response({"error": "Invalid data"}, status=400)

    try:
        document = Documentation.objects.select_related('user').get(id=document_id)
    except Documentation.DoesNotExist:
        return Response({"error": "Document not found"}, status=404)

    document.status = action
    document.save(update_fields=['status'])

    send_notification(
        users=[document.user],
        message=f"Your {document.document_type} has been {action}.",
        notification_type='general',
        channels=('in_app', 'email')
    )

    return Response({
        "message": f"Document {action}",
        "document_id": document.id,
        "status": document.status
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def admin_list_customers(request):
    if request.user.role not in ['admin', 'manager']:
        return Response({"error": "Permission denied"}, status=403)

    users = (
        User.objects
        .filter(role='customer', documents__isnull=False)
        .distinct()
        .prefetch_related('documents')
    )

    data = []
    for user in users:
        data.append({
            "id": user.id,
            "full_name": f"{user.first_name} {user.last_name}",
            "email": user.email,
            "phone": user.phone,
            "documents_count": user.documents.count()
        })

    return Response(data)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def admin_customer_details(request, user_id):
    if request.user.role not in ['admin', 'manager']:
        return Response({"error": "Permission denied"}, status=403)

    try:
        user = User.objects.prefetch_related('documents').get(
            id=user_id, role='customer'
        )
    except User.DoesNotExist:
        return Response({"error": "Customer not found"}, status=404)

    documents = []
    for doc in user.documents.all():
        documents.append({
            "id": doc.id,
            "type": doc.document_type,
            "status": doc.status,
            "image": doc.document_image.url,
            "uploaded_at": doc.uploaded_at
        })

    return Response({
        "id": user.id,
        "full_name": f"{user.first_name} {user.last_name}",
        "first_name": user.first_name,
        "middle_name": user.middle_name,
        "last_name": user.last_name,
        "email": user.email,
        "phone": user.phone,
        "address": user.address,
        "documents": documents
    })
