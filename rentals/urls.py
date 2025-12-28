# rentals/urls.py
from django.urls import path
from .views import UserRentedCarsView

urlpatterns = [
    path('rented-cars/', UserRentedCarsView.as_view(), name='user-rented-cars'),
]
