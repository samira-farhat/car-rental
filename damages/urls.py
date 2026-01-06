from django.urls import path
from .views import AdminDamageManagementView, DamageListView

urlpatterns = [
    path('damages/', DamageListView.as_view(), name='damage-list'),
    path('admin/damages/', AdminDamageManagementView.as_view()),               # POST
    path('admin/damages/<int:damage_id>/', AdminDamageManagementView.as_view()),  # PUT, DELETE
]
