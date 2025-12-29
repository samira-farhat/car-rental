from django.contrib import admin
from .models import Documentation

@admin.register(Documentation)
class DocumentationAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "document_type", "status", "uploaded_at")
    list_filter = ("status", "document_type")
    search_fields = ("user__username", "document_type")
