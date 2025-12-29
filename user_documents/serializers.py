from rest_framework import serializers
from .models import Documentation

class DocumentationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Documentation
        fields = "__all__"
        read_only_fields = ("status", "uploaded_at", "user")
