from django.db import models
from accounts.models import User

# ---------------- Notification ----------------
class Notification(models.Model):
    NotificationID = models.AutoField(
        primary_key=True,
        db_column='NotificationID'
    )

    Type = models.CharField(
        max_length=20,
        choices=[
            ('reservation', 'reservation'),
            ('rental', 'rental'),
            ('payment', 'payment'),
            ('general', 'general')
        ],
        db_column='Type'
    )

    Message = models.TextField(
        db_column='Message'
    )

    CreatedAt = models.DateTimeField(
        auto_now_add=True,
        db_column='CreatedAt'
    )

    class Meta:
        managed = False
        db_table = 'notification'

    def __str__(self):
        return f"{self.Type} | {self.NotificationID}"


# ---------------- Notification Recipient ----------------
class NotificationRecipient(models.Model):
    NotificationRecipientID = models.AutoField(
        primary_key=True,
        db_column='NotificationRecipientID'
    )

    NotificationID = models.ForeignKey(
        Notification,
        on_delete=models.CASCADE,
        db_column='NotificationID',
        related_name='recipients'
    )

    UserID = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        db_column='UserID',
        related_name='notification_recipients'
    )

    Channel = models.CharField(
        max_length=10,
        choices=[
            ('in_app', 'in_app'),
            ('email', 'email')
        ],
        db_column='Channel'
    )

    Status = models.CharField(
        max_length=10,
        choices=[
            ('unread', 'unread'),
            ('read', 'read'),
            ('sent', 'sent'),
            ('failed', 'failed')
        ],
        default='unread',
        db_column='Status'
    )

    SentAt = models.DateTimeField(
        null=True,
        blank=True,
        db_column='SentAt'
    )

    ReadAt = models.DateTimeField(
        null=True,
        blank=True,
        db_column='ReadAt'
    )

    class Meta:
        managed = False
        db_table = 'notification_recipient'
        unique_together = ('NotificationID', 'UserID', 'Channel')

    def __str__(self):
        return f"{self.UserID} | {self.Channel} | {self.Status}"
