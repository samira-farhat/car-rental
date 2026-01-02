from .models import SystemSetting
import json

def get_setting(key_name, default=None):
    try:
        setting = SystemSetting.objects.get(key_name=key_name)
        value = setting.value
        if setting.data_type == 'boolean':
            return value.lower() == 'true'
        elif setting.data_type == 'integer':
            return int(value)
        elif setting.data_type == 'decimal':
            return float(value)
        elif setting.data_type == 'json':
            return json.loads(value)
        return value
    except SystemSetting.DoesNotExist:
        return default
