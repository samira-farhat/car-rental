from django.db import models
from django.conf import settings
from rentals.models import Rental


class Payment(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
    ]

    METHOD_CHOICES = [
        ('card', 'Card'),
        ('cash', 'Cash'),
    ]

    PaymentID = models.AutoField(primary_key=True)
    UserID = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        db_column='UserID'
    )
    RentalID = models.ForeignKey(
        Rental,
        on_delete=models.CASCADE,
        db_column='RentalID'
    )
    Amount = models.DecimalField(max_digits=10, decimal_places=2)
    PaymentDate = models.DateTimeField(auto_now_add=True)
    Method = models.CharField(max_length=50, choices=METHOD_CHOICES)
    Status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending'
    )
    TransactionRef = models.CharField(max_length=100, null=True, blank=True)

    class Meta:
        managed=False
        db_table = 'Payment'
