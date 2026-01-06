# payments/models.py
from django.db import models
from accounts.models import User
from rentals.models import Rental

class Payment(models.Model):
    PAYMENT_METHODS = [
        ('WISH', 'WISH'),
        ('OMT', 'OMT'),
        ('CASH', 'CASH'),
    ]

    PAYMENT_STATUS = [
        ('pending', 'Pending'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
    ]

    paymentid = models.AutoField(db_column='PaymentID', primary_key=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, db_column='UserID')
    rental = models.ForeignKey(Rental, on_delete=models.CASCADE, db_column='RentalID')
    amount = models.DecimalField(max_digits=10, decimal_places=2, db_column='Amount')
    paymentdate = models.DateTimeField(auto_now_add=True, db_column='PaymentDate')
    method = models.CharField(max_length=10, choices=PAYMENT_METHODS, db_column='Method')
    status = models.CharField(max_length=20, choices=PAYMENT_STATUS, default='pending', db_column='Status')
    transactionref = models.CharField(max_length=100, blank=True, null=True, db_column='TransactionRef')

    class Meta:
        managed = False  # Table already exists
        db_table = 'Payment'

    def __str__(self):
        return f"Payment #{self.paymentid} - {self.status} - {self.amount}"
