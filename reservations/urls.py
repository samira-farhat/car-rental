from django.urls import path
from .views import (
    AdminReservationListView,
    AdminReservationDetailView,
    ApproveReservationView,
    RejectReservationView
)

urlpatterns = [
    path('admin/reservations/', AdminReservationListView.as_view()),
    path('admin/reservations/<int:pk>/', AdminReservationDetailView.as_view()),
    path('admin/reservations/<int:pk>/approve/', ApproveReservationView.as_view()),
    path('admin/reservations/<int:pk>/reject/', RejectReservationView.as_view()),
]
