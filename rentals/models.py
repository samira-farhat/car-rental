# rentals/models.py
from django.db import models
from accounts.models import User
from cars.models import Car
from reservations.models import Reservation  # IMPORTANT

class Rental(models.Model):
    rentalid = models.AutoField(db_column='RentalID', primary_key=True)

    # Link rental to its reservation (CRITICAL)
    reservation = models.OneToOneField(
        Reservation,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        db_column='ReservationID'
    )

    user = models.ForeignKey(
        User,
        models.CASCADE,
        db_column='UserID'
    )

    car = models.ForeignKey(
        Car,
        models.CASCADE,
        db_column='CarID'
    )

    startdate = models.DateField(db_column='StartDate')
    enddate = models.DateField(db_column='EndDate')

    duration = models.IntegerField(db_column='Duration')

    totalamount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        db_column='TotalAmount'
    )

    status = models.CharField(
        max_length=20,  # FIXED
        db_column='Status',
        choices=[
            ('pending_payment', 'Pending Payment'),
            ('active', 'Active'),
            ('completed', 'Completed'),
            ('cancelled', 'Cancelled'),
        ],
        default='pending_payment'
    )

    comment = models.TextField(blank=True, null=True, db_column='Comment')

    approvedby = models.ForeignKey(
        User,
        models.SET_NULL,
        blank=True,
        null=True,
        related_name='approved_rentals',
        db_column='ApprovedBy'
    )

    createdat = models.DateTimeField(
        auto_now_add=True,
        db_column='CreatedAt'
    )

    class Meta:
        managed = False

        db_table = 'Rental'
