from rest_framework import viewsets, permissions
from .models import SystemSetting, SystemSettingLog
from .serializers import SystemSettingSerializer

class IsAdmin(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_staff  # or is_superuser

from rest_framework.viewsets import ModelViewSet
from rest_framework.permissions import IsAdminUser
from rest_framework.response import Response
from .models import SystemSetting, SystemSettingLog
from .serializers import SystemSettingSerializer


class SystemSettingViewSet(ModelViewSet):
    queryset = SystemSetting.objects.all()
    serializer_class = SystemSettingSerializer
    permission_classes = [IsAdminUser]
    http_method_names = ['get', 'patch']

    def update(self, request, *args, **kwargs):
        instance = self.get_object()

        old_value = instance.value
        new_value = request.data.get('value')

        if new_value is None:
            return Response(
                {'error': 'Value is required'},
                status=400
            )

        # 🔒 Manual DB update (important for unmanaged tables)
        instance.value = str(new_value)
        instance.modified_by = request.user
        instance.save(update_fields=['value', 'modified_by'])

        # 📝 Log the change
        SystemSettingLog.objects.create(
            setting=instance,
            old_value=old_value,
            new_value=new_value,
            changed_by=request.user
        )

        serializer = self.get_serializer(instance)
        return Response(serializer.data)
