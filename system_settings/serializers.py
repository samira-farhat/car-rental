from rest_framework import serializers
from .models import SystemSetting

class SystemSettingSerializer(serializers.ModelSerializer):
    class Meta:
        model = SystemSetting
        fields = [
            'setting_id', 'key_name', 'category', 'value',
            'data_type', 'default_value', 'is_sensitive',
            'modified_by', 'modified_at'
        ]
        read_only_fields = ['modified_by', 'modified_at']
