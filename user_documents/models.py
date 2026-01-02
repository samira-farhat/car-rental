from django.db import models

class Documentation(models.Model):
    documentid = models.AutoField(db_column='DocumentID', primary_key=True)
    userid = models.BigIntegerField(db_column='UserID')
    documenttype = models.CharField(db_column='DocumentType', max_length=50)
    documentimage = models.CharField(db_column='DocumentImage', max_length=255, blank=True, null=True)
    status = models.CharField(
        db_column='Status',
        max_length=10,
        choices=[
            ('pending', 'Pending'),
            ('verified', 'Verified'),
            ('rejected', 'Rejected')
        ],
        default='pending'
    )
    uploadedat = models.DateTimeField(db_column='UploadedAt')

    class Meta:
        managed = False   # 🔑 VERY IMPORTANT
        db_table = 'Documentation'
