from django.db import models
from accounts.models import User  # importing the custom user
from cars.models import Car       # importing the car model

# links a user to the cars they have wishlisted
class Wishlist(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='wishlist_items')  # links to user
    car = models.ForeignKey(Car, on_delete=models.CASCADE, related_name='wishlisted_by')    # links to car
    date_added = models.DateTimeField(auto_now_add=True)  # timestamp when item was added

    class Meta:
        unique_together = ('user', 'car')  # prevent duplicate wishlist items
        ordering = ['-date_added']  # newest first

    def __str__(self):
        return f"{self.user.email} - {self.car.brand} {self.car.model}"
