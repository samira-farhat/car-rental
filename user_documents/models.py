from django.db import models
from django.conf import settings

class Documentation(models.Model):
    DOCUMENT_TYPES = [
        ('DL', 'Driving License'),
        ('ID', 'National ID'),
        ('PP', 'Passport'),
    ]

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE
    )
    document_type = models.CharField(max_length=50)
    document_image = models.ImageField(upload_to='documents/')
    status = models.CharField(
        max_length=10,
        choices=[
            ('pending', 'Pending'),
            ('verified', 'Verified'),
            ('rejected', 'Rejected'),
        ],
        default='pending'
    )
    uploaded_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'Documentation'

    def __str__(self):
        return f"{self.user} - {self.document_type}"
