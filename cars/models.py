from django.db import models

class Carcategory(models.Model):
    categoryid = models.AutoField(db_column='CategoryID', primary_key=True)
    categoryname = models.CharField(db_column='CategoryName', unique=True, max_length=50)

    class Meta:
        managed = False
        db_table = 'carcategory'


class Car(models.Model):
    carid = models.AutoField(db_column='CarID', primary_key=True)
    categoryid = models.ForeignKey('Carcategory', models.DO_NOTHING, db_column='CategoryID', blank=True, null=True)
    vin = models.CharField(db_column='VIN', unique=True, max_length=50)
    brand = models.CharField(db_column='Brand', max_length=50)
    model = models.CharField(db_column='Model', max_length=50)
    year = models.IntegerField(db_column='Year')
    description = models.TextField(blank=True, null=True) 
    rentalpriceperday = models.DecimalField(db_column='RentalPricePerDay', max_digits=10, decimal_places=2)
    availabilitystatus = models.CharField(
        db_column='AvailabilityStatus',
        max_length=11,
        choices=[
            ('available', 'Available'),
            ('rented', 'Rented'),
            ('maintenance', 'Maintenance')
        ],
        blank=True,
        null=True
    )
    image = models.ImageField(
        upload_to='cars/',      # saves images to media/cars/
        blank=True,
        null=True
    )
    createdat = models.DateTimeField(db_column='CreatedAt', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'car'
