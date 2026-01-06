import os
import shutil
from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Documentation

# Backup path
BACKUP_PATH = r"C:\Users\User\Desktop\car_management_frontend\car-rental\media\documents"

@receiver(post_save, sender=Documentation)
def copy_document_to_backup(sender, instance, **kwargs):
    if instance.document_image:
        src_path = instance.document_image.path
        os.makedirs(BACKUP_PATH, exist_ok=True)
        dest_path = os.path.join(BACKUP_PATH, os.path.basename(src_path))
        try:
            shutil.copy2(src_path, dest_path)
            print(f"Document copied to backup: {dest_path}")
        except Exception as e:
            print(f"Failed to copy document: {e}")
