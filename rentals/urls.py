# rentals/urls.py
from django.urls import path
from .views import MyRentalsView, RentalByReservationView, UserRentedCarsView, RentalDetailView

urlpatterns = [
    path('rented-cars/', UserRentedCarsView.as_view(), name='user-rented-cars'),
    path('<int:rental_id>/', RentalDetailView.as_view(), name='rental-detail'),
    path('by_reservation/<int:reservation_id>/', RentalByReservationView.as_view(), name='rental_by_reservation'),
    path('me/', MyRentalsView.as_view(), name='my-rentals'),
]
