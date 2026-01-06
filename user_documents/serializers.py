from rest_framework import serializers
from accounts.models import Documentation

class DocumentationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Documentation
        fields = ['id', 'document_type', 'document_image', 'status', 'uploaded_at']
        read_only_fields = ['documentid', 'status', 'uploaded_at']