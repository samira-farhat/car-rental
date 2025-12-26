# defines the API endpoints for accounts (registration, login, password reset)

from django.urls import path
from .views import register_user, LoginUserView, forgot_password

urlpatterns = [
    path('register/', register_user, name='register'),
    path('login/', LoginUserView.as_view(), name='login'),
    path('forgot-password/', forgot_password, name='forgot-password'),
]
