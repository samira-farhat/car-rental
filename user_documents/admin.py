from django.contrib import admin
from accounts.models import Documentation


@admin.register(Documentation)
class DocumentationAdmin(admin.ModelAdmin):
    list_display = ('documentid', 'user', 'document_type', 'status', 'uploaded_at')
