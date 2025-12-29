from django.db import models
from accounts.models import User
from cars.models import Car

class Wishlist(models.Model):
    wishlistid = models.AutoField(db_column='WishlistID', primary_key=True)  # matches WishlistID
    user = models.ForeignKey(User, on_delete=models.CASCADE, db_column='UserID', related_name='wishlist_items')
    car = models.ForeignKey(Car, on_delete=models.CASCADE, db_column='CarID', related_name='wishlisted_by')
    date_added = models.DateTimeField(auto_now_add=True, db_column='DateAdded')

    class Meta:
        db_table = 'wishlist'  # matches your existing table name
        unique_together = ('user', 'car')
        ordering = ['-date_added']

    def __str__(self):
        return f"User {self.user_id} - Car {self.car_id}"
