# defines the API endpoints for accounts (registration, login, password reset)

from django.urls import path
from .views import register_user, LoginUserView, forgot_password, resend_verification_code, reset_password, verify_account, verify_reset_code

urlpatterns = [
    path('register/', register_user, name='register'),
    path('login/', LoginUserView.as_view(), name='login'),
    path('forgot-password/', forgot_password, name='forgot-password'),
    path('send-verification-code/', resend_verification_code),
    path('verify-account/', verify_account),
    path('verify-reset-code/', verify_reset_code, name='verify-reset-code'),
    path('reset-password/', reset_password, name='reset-password'),
]
