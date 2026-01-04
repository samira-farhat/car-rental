"""
Notification Service Layer

Responsibilities:
- Read notification-related system settings
- Create notification records
- Create per-user recipients
- Send email notifications
- Track delivery and read status

IMPORTANT:
- Uses existing database tables
- Models are unmanaged (managed = False)
"""

from django.utils import timezone
from django.core.mail import send_mail
from django.conf import settings
from django.db import transaction
from notifications.models import Notification, NotificationRecipient
from system_settings.models import SystemSetting
from accounts.models import User
def is_notification_enabled(setting_key: str) -> bool:
    """
    Check whether a notification feature is enabled.

    Reads from:
    system_setting table

    Rules:
    - Category must be 'notification'
    - Uses value first
    - Falls back to default_value
    - Missing setting = disabled (safe default)
    """

    try:
        setting = SystemSetting.objects.get(
            key_name=setting_key,
            category='notification'
        )

        # Prefer explicit value, fallback to default
        raw_value = setting.value or setting.default_value

        if raw_value is None:
            return False

        return raw_value.lower() == 'true'

    except SystemSetting.DoesNotExist:
        return False


def send_notification(
    users: list[User],
    message: str,
    notification_type: str,
    channels: tuple = ('in_app',),
    setting_key: str | None = None
):
    """
    Send notifications to one or more users.
    """

    # 1️⃣ Respect system settings
    if setting_key and not is_notification_enabled(setting_key):
        return {
            'success': False,
            'reason': 'Notification disabled by system setting'
        }

    # 2️⃣ Create notification
    notification = Notification.objects.create(
        Message=message,
        Type=notification_type,
    )

    recipients = []

    # 3️⃣ Create recipients
    for user in users:
        for channel in channels:
            recipient = NotificationRecipient.objects.create(
                NotificationID=notification,
                UserID=user,
                Channel=channel,
                Status='unread' if channel == 'in_app' else 'sent'
            )
            recipients.append(recipient)

    # 4️⃣ Send emails AFTER commit
    def send_emails():
        for recipient in recipients:
            if recipient.Channel == 'email':
                _send_email_notification(recipient, message)

    transaction.on_commit(send_emails)

    return {'success': True}


def _send_email_notification(recipient: NotificationRecipient, message: str):
    """
    Send email and update delivery status.
    Fail-safe.
    """
    try:
        send_mail(
            subject='New Notification',
            message=message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[recipient.UserID.email],
            fail_silently=False
        )
        recipient.Status = 'sent'

    except Exception:
        recipient.Status = 'failed'

    recipient.SentAt = timezone.now()
    recipient.save(update_fields=['Status', 'SentAt'])