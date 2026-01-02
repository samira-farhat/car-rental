from django.db import models
from django.conf import settings


class SystemSetting(models.Model):
    setting_id = models.AutoField(
        primary_key=True,
        db_column='SettingID'
    )

    key_name = models.CharField(
        max_length=100,
        unique=True,
        db_column='KeyName'
    )

    category = models.CharField(
        max_length=20,
        db_column='Category'
    )

    value = models.TextField(
        db_column='Value'
    )

    data_type = models.CharField(
        max_length=10,
        db_column='DataType'
    )

    default_value = models.TextField(
        null=True,
        blank=True,
        db_column='DefaultValue'
    )

    is_sensitive = models.BooleanField(
        default=False,
        db_column='IsSensitive'
    )

    modified_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        db_column='ModifiedBy',
        related_name='modified_settings'
    )

    modified_at = models.DateTimeField(
        auto_now=True,
        db_column='ModifiedAt'
    )

    class Meta:
        managed = False
        db_table = 'system_setting'
        ordering = ['category', 'key_name']


    def __str__(self):
        return f"{self.key_name} ({self.category})"

class SystemSettingLog(models.Model):
    log_id = models.AutoField(
        primary_key=True,
        db_column='LogID'
    )

    setting = models.ForeignKey(
        SystemSetting,
        on_delete=models.CASCADE,
        db_column='SettingID',
        related_name='logs'
    )

    old_value = models.TextField(
        null=True,
        blank=True,
        db_column='OldValue'
    )

    new_value = models.TextField(
        db_column='NewValue'
    )

    changed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        db_column='ChangedBy',
        related_name='settings_changes'
    )

    changed_at = models.DateTimeField(
        auto_now_add=True,
        db_column='ChangedAt'
    )

    class Meta:
        managed = False
        db_table = 'system_setting_log'
        ordering = ['-changed_at']


    def __str__(self):
        return f"Setting {self.setting_id} changed at {self.changed_at}"
