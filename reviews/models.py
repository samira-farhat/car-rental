# reviews/models.py
from django.db import models
from accounts.models import User
from cars.models import Car

class Review(models.Model):
    reviewid = models.AutoField(db_column='ReviewID', primary_key=True)
    user = models.ForeignKey(User, models.CASCADE, db_column='UserID')
    car = models.ForeignKey(Car, models.CASCADE, db_column='CarID')
    rating = models.IntegerField()
    description = models.TextField(blank=True, null=True)
    reviewdate = models.DateTimeField(auto_now_add=True)

    class Meta:
        managed = False  # existing table
        db_table = 'Review'
