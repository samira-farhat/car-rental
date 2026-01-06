from django.urls import path
from .views import UserNotificationsView, mark_notification_as_read

urlpatterns = [
    path('notifications/user/', UserNotificationsView.as_view(), name='user_notifications'),
    path('notifications/mark-read/<int:notification_id>/', mark_notification_as_read, name='mark_notification_read'),
]
