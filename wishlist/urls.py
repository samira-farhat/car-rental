from django.urls import path
from .views import WishlistListCreateView, WishlistDeleteView

urlpatterns = [
    path('', WishlistListCreateView.as_view(), name='wishlist-list-create'),  # list and add wishlist items
    path('<int:car_id>/', WishlistDeleteView.as_view()),
]
