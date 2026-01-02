# reviews/urls.py
from django.urls import path
from .views import SubmitReviewView, CarReviewsView

urlpatterns = [
    path('submit/', SubmitReviewView.as_view(), name='submit-review'),
    path('car/<int:car_id>/', CarReviewsView.as_view(), name='car-reviews'),
]
