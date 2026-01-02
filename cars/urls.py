from django.conf import settings
from django.urls import path
from .views import AdminCarManagementView, CarCategoryListView, CarListView
from django.conf.urls.static import static
urlpatterns = [
    path('cars/', CarListView.as_view(), name='car-list'),
    path('admin/cars/', AdminCarManagementView.as_view()),               # POST
    path('admin/cars/<int:car_id>/', AdminCarManagementView.as_view()),   # PUT, DELETE
    path('carcategories/', CarCategoryListView.as_view(), name='carcategory-list')
]

# During development only (DEBUG = True):
# This tells Django to serve uploaded media files (e.g. car images)
# directly from MEDIA_ROOT when accessed via MEDIA_URL.
#
# Example:
#   MEDIA_URL  = '/media/'
#   MEDIA_ROOT = BASE_DIR / 'media'
#
# Request:
#   http://localhost:8000/media/cars/bmw.jpg
# Will be resolved to:
#   <project_root>/media/cars/bmw.jpg
#
# IMPORTANT:
# - This is NOT suitable for production
# - In production, media should be served by Nginx, Apache, or a CDN
if settings.DEBUG:
    urlpatterns += static(
        settings.MEDIA_URL,        # URL prefix for media files
        document_root=settings.MEDIA_ROOT  # Physical directory where files are stored
    )