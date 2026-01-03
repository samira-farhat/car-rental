# reservations/models.py

from django.db import models
from accounts.models import User      # custom user model
from cars.models import Car            # existing Car model

class Reservation(models.Model):
    """
    This model represents a reservation request made by a user.
    It is created BEFORE a rental exists.
    
    Admins approve or reject reservations.
    If approved, a Rental record is created from this reservation.
    """

    # Primary key mapped to ReservationID column in DB
    reservationid = models.AutoField(
        db_column='ReservationID',
        primary_key=True
    )

    # The user who made the reservation
    # ON DELETE CASCADE: if user is deleted, reservations are deleted
    user = models.ForeignKey(
        User,
        models.CASCADE,
        db_column='UserID'
    )

    # The car being reserved
    # If the car is deleted, the reservation should also be deleted
    car = models.ForeignKey(
        Car,
        models.CASCADE,
        db_column='CarID'
    )

    # Rental start date requested by user
    startdate = models.DateField(
        db_column='StartDate'
    )

    # Rental end date requested by user
    enddate = models.DateField(
        db_column='EndDate'
    )

    # Reservation lifecycle status
    # Matches ENUM in DB exactly
    status = models.CharField(
        max_length=20,
        db_column='Status',
        choices=[
            ('pending', 'Pending'),        # waiting for admin action
            ('approved', 'Approved'),      # admin approved
            ('rejected', 'Rejected'),      # admin rejected
            ('cancelled', 'Cancelled'),    # user/admin cancelled
            ('completed', 'Completed'),    # rental completed
        ],
        default='pending'
    )

    # Reason provided by admin when rejecting a reservation
    # NULL for all other cases
    rejectionreason = models.TextField(
        db_column='RejectionReason',
        blank=True,
        null=True
    )

    # Admin user who approved or rejected the reservation
    # SET NULL allows history preservation if admin is deleted
    approvedby = models.ForeignKey(
        User,
        models.SET_NULL,
        null=True,
        blank=True,
        related_name='approved_reservations',
        db_column='ApprovedBy'
    )

    # Timestamp when reservation was created
    # auto_now_add=True ensures it is set once on insert
    createdat = models.DateTimeField(
        auto_now_add=True,
        db_column='CreatedAt'
    )

    class Meta:
        # This table already exists in the database
        # Django will NOT attempt to create, alter, or delete it
        managed = False
        db_table = 'Reservation'

    def __str__(self):
        # Human-readable representation (useful in Django admin & logs)
        return f"Reservation #{self.reservationid} - {self.user}"
