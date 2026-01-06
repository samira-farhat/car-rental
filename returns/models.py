from django.db import models
from rentals.models import Rental
from accounts.models import User

class CarReturn(models.Model):
    returnid = models.AutoField(db_column='ReturnID', primary_key=True)

    rental = models.OneToOneField(
        Rental,
        on_delete=models.CASCADE,
        db_column='RentalID'
    )

    returndatetime = models.DateTimeField(db_column='ReturnDateTime')
    mileage = models.IntegerField(db_column='Mileage')

    condition = models.CharField(
        db_column='car_condition',
        max_length=20,
        choices=[
            ('excellent', 'Excellent'),
            ('minor_damage', 'Minor Damage'),
            ('major_damage', 'Major Damage'),
        ],
    )

    comments = models.TextField(db_column='Comments', null=True, blank=True)

    approved = models.BooleanField(db_column='Approved', default=False)

    approvedby = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        db_column='ApprovedBy',
        related_name='approved_returns'
    )

    createdat = models.DateTimeField(db_column='CreatedAt')

    class Meta:
        managed = False
        db_table = 'car_return'