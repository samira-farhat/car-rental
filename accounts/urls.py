# defines the API endpoints for accounts (registration, login, password reset)

from django.urls import path
from .views import register_user, login_user, forgot_password

urlpatterns = [
    path('register/', register_user, name='register'),
    path('login/', login_user, name='login'),
    path('forgot-password/', forgot_password, name='forgot-password'),
]
