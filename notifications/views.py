from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import NotificationRecipient
from .serializers import NotificationSerializer
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .models import NotificationRecipient

class UserNotificationsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        recipients = NotificationRecipient.objects.filter(UserID=request.user).order_by('-SentAt')
        notifications = [r.NotificationID for r in recipients]
        serializer = NotificationSerializer(notifications, many=True, context={'request': request})
        return Response(serializer.data)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def mark_notification_as_read(request, notification_id):
    try:
        recipient = NotificationRecipient.objects.get(
            NotificationID__NotificationID=notification_id,
            UserID=request.user
        )
        if recipient.Status != 'read':
            recipient.Status = 'read'
            from django.utils import timezone
            recipient.ReadAt = timezone.now()
            recipient.save()
        return Response({"message": "Notification marked as read"}, status=status.HTTP_200_OK)
    except NotificationRecipient.DoesNotExist:
        return Response({"error": "Notification not found for user"}, status=status.HTTP_404_NOT_FOUND)
