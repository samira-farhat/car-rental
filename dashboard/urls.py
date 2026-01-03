# dashboard/urls.py

from django.urls import path
from .views import AdminDashboardSummaryView

urlpatterns = [
    path('admin/dashboard/summary/', AdminDashboardSummaryView.as_view()),
]
