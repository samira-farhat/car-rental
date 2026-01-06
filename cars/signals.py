import os
import shutil
from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Car  # adjust if your app name is different

@receiver(post_save, sender=Car)
def copy_car_image(sender, instance, **kwargs):
    """
    After saving a Car instance, copy its image to the extra path.
    """
    if instance.image:
        # Default path where Django stores the image
        original_path = instance.image.path

        # Extra folder where you want the copy
        extra_path = r"C:\Users\User\Desktop\car_management_frontend\car-rental\media\cars"

        # Ensure the folder exists
        if not os.path.exists(extra_path):
            os.makedirs(extra_path)

        # Destination path (same filename)
        filename = os.path.basename(original_path)
        destination_path = os.path.join(extra_path, filename)

        # Copy the file
        shutil.copy2(original_path, destination_path)
