from django.urls import path
from .views import GenerateReportView

# URL configuration for report-related endpoints
urlpatterns = [
    # Endpoint to generate reports (financial, rental, operational)
    path('generate/', GenerateReportView.as_view(), name='generate-report'),
]
