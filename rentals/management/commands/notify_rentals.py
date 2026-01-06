# rentals/management/commands/notify_rentals.py
from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import timedelta
from rentals.models import Rental
from notifications.services.notification_service import send_notification

class Command(BaseCommand):
    help = "Notify users about upcoming rental start/end dates"

    def handle(self, *args, **kwargs):
        today = timezone.now().date()
        
        # Rentals starting tomorrow
        starting_soon = Rental.objects.filter(
            startdate=today + timedelta(days=1),
            status='active'
        )
        for rental in starting_soon:
            message = f"Reminder: Your rental for {rental.car.brand} {rental.car.model} starts tomorrow."
            send_notification(
                users=[rental.user],
                message=message,
                notification_type='rental',
                channels=('in_app', 'email')
            )

        # Rentals ending tomorrow
        ending_soon = Rental.objects.filter(
            enddate=today + timedelta(days=1),
            status='active'
        )
        for rental in ending_soon:
            message = f"Reminder: Your rental for {rental.car.brand} {rental.car.model} ends tomorrow."
            send_notification([rental.user], message, notification_type='rental')

        self.stdout.write(self.style.SUCCESS("Rental notifications sent successfully."))
