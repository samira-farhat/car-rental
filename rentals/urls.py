# rentals/urls.py
from django.urls import path
from .views import UserRentedCarsView, RentalDetailView

urlpatterns = [
    path('rented-cars/', UserRentedCarsView.as_view(), name='user-rented-cars'),
    path('<int:rental_id>/', RentalDetailView.as_view(), name='rental-detail'),
]
