from rest_framework import serializers
from .models import Notification, NotificationRecipient

class NotificationRecipientSerializer(serializers.ModelSerializer):
    """Serialize recipient-specific info (status, read time, channel)."""
    user_id = serializers.IntegerField(source='UserID.id', read_only=True)

    class Meta:
        model = NotificationRecipient
        fields = [
            'user_id',
            'status',
            'channel',
            'ReadAt',
            'SentAt'
        ]


class NotificationSerializer(serializers.ModelSerializer):
    status = serializers.SerializerMethodField()
    sent_at = serializers.SerializerMethodField()  # can use NotificationRecipient.SentAt

    class Meta:
        model = Notification
        fields = ['NotificationID', 'Message', 'Type', 'CreatedAt', 'status', 'sent_at']

    def get_status(self, obj):
        """Return the recipient status for the current user"""
        user = self.context['request'].user
        recipient = obj.recipients.filter(UserID=user).first()
        return recipient.Status if recipient else None

    def get_sent_at(self, obj):
        """Return when this notification was sent to the current user"""
        user = self.context['request'].user
        recipient = obj.recipients.filter(UserID=user).first()
        return recipient.SentAt if recipient else None