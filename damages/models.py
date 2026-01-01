from django.db import models
from cars.models import Car
from rentals.models import Rental
from accounts.models import User  # Assuming HandledBy refers to a User

class Damage(models.Model):
    damageid = models.AutoField(db_column='DamageID', primary_key=True)
    car = models.ForeignKey(Car, db_column='CarID', on_delete=models.CASCADE)
    rental = models.ForeignKey(Rental, db_column='RentalID', on_delete=models.SET_NULL, null=True, blank=True)
    reportdate = models.DateField(db_column='ReportDate')
    description = models.TextField(db_column='Description')
    repaircost = models.DecimalField(db_column='RepairCost', max_digits=10, decimal_places=2, null=True, blank=True)
    image = models.CharField(db_column='Image', max_length=255, null=True, blank=True)
    status = models.CharField(
        db_column='Status',
        max_length=20,
        choices=[('reported','reported'), ('under_repair','under_repair'), ('resolved','resolved')],
        default='reported'
    )
    handledby = models.BigIntegerField(db_column='HandledBy', null=True, blank=True)

    class Meta:
        managed = False   # Django will not create or alter this table
        db_table = 'damage'

    def __str__(self):
        return f"Damage {self.damageid} - Car {self.car_id} - Status {self.status}"
