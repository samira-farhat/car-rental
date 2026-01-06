# defines the API endpoints for accounts (registration, login, password reset)

from django.urls import path
from .views import admin_customer_details, admin_list_customers, register_user, LoginUserView, forgot_password, resend_verification_code, reset_password, user_profile, verify_account, verify_documentation, verify_reset_code

urlpatterns = [
    path('register/', register_user, name='register'),
    path('login/', LoginUserView.as_view(), name='login'),
    path('forgot-password/', forgot_password, name='forgot-password'),
    path('send-verification-code/', resend_verification_code),
    path('verify-account/', verify_account),
    path('verify-reset-code/', verify_reset_code, name='verify-reset-code'),
    path('reset-password/', reset_password, name='reset-password'),
    path('profile/', user_profile, name='user-profile'),
    path('admin/customers/', admin_list_customers),
    path('admin/customers/<int:user_id>/', admin_customer_details),
    path('admin/verify-document/', verify_documentation),
]
