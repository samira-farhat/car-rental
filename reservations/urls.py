from django.conf import settings
from django.urls import path
from django.conf.urls.static import static

from .views import (
    AdminReservationListView,
    AdminReservationDetailView,
    ApproveReservationView,
    RejectReservationView, 
    CreateReservationView,
    CarReservedDatesView
)


urlpatterns = [
    path('admin/reservations/', AdminReservationListView.as_view()),
    path('admin/reservations/<int:pk>/', AdminReservationDetailView.as_view()),
    path('admin/reservations/<int:pk>/approve/', ApproveReservationView.as_view()),
    path('admin/reservations/<int:pk>/reject/', RejectReservationView.as_view()),
    path('reservations/', CreateReservationView.as_view()),
    path('reservations/car/<int:car_id>/dates/', CarReservedDatesView.as_view()),

]

if settings.DEBUG:
    urlpatterns += static(
        settings.MEDIA_URL,        # URL prefix for media files
        document_root=settings.MEDIA_ROOT  # Physical directory where files are stored
    )