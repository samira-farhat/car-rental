from django.urls import path
from .views import (
    UserRentedCarsView,
    RentalDetailView,
    approve_rental_payment,
    pending_payment_rentals
)

urlpatterns = [
    path('rented-cars/', UserRentedCarsView.as_view(), name='user-rented-cars'),
    path('<int:rental_id>/', RentalDetailView.as_view(), name='rental-detail'),

    # 🧑‍💼 Manager actions
    path('<int:rental_id>/approve-payment/', approve_rental_payment),
    path('pending-payments/', pending_payment_rentals),
]
