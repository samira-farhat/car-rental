# rentals/models.py
from django.db import models
from accounts.models import User
from cars.models import Car

class Rental(models.Model):
    rentalid = models.AutoField(db_column='RentalID', primary_key=True)
    user = models.ForeignKey(User, models.CASCADE, db_column='UserID')
    car = models.ForeignKey(Car, models.CASCADE, db_column='CarID')
    startdate = models.DateField(db_column='StartDate')
    enddate = models.DateField(db_column='EndDate')
    duration = models.IntegerField(db_column='Duration')
    totalamount = models.DecimalField(max_digits=10, decimal_places=2, db_column='TotalAmount')
    status = models.CharField(max_length=10, db_column='Status', blank=True, null=True)
    comment = models.TextField(blank=True, null=True, db_column='Comment')
    approvedby = models.ForeignKey(User, models.SET_NULL, blank=True, null=True, related_name='approved_rentals', db_column='ApprovedBy')
    createdat = models.DateTimeField(auto_now_add=True, db_column='CreatedAt')

    class Meta:
        managed = False  # existing table
        db_table = 'Rental'
