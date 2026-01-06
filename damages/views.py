import os
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAdminUser, AllowAny
from django.shortcuts import get_object_or_404
from django.db import transaction
from rest_framework.parsers import MultiPartParser, FormParser
from .models import Damage
from .serializers import AdminDamageSerializer, AdminDamageWriteSerializer

class DamageListView(APIView):
    """
    Public view to list all damage records.
    """
    permission_classes = [AllowAny]

    def get(self, request):
        damages = Damage.objects.all()
        serializer = AdminDamageSerializer(damages, many=True, context={'request': request})
        return Response(serializer.data)


class AdminDamageManagementView(APIView):
    """
    Admin-only view for managing damage records.
    Supports add, update, delete with image handling.
    """
    permission_classes = [IsAdminUser]
    parser_classes = [MultiPartParser, FormParser]

    @transaction.atomic
    def post(self, request):
        """
        Add new damage record.
        Handles image upload manually since `image` is a CharField.
        """
        serializer = AdminDamageWriteSerializer(data=request.data)
        if serializer.is_valid():
            damage = serializer.save()
            # Handle image file upload
            image_file = request.FILES.get('image')
            if image_file:
                filename = f"damages/{image_file.name}"
                with open(os.path.join(settings.MEDIA_ROOT, filename), "wb") as f:
                    for chunk in image_file.chunks():
                        f.write(chunk)
                damage.image = filename
                damage.save()
            return Response(
                {
                    "message": "Damage report added successfully.",
                    "damage": AdminDamageSerializer(damage, context={'request': request}).data
                },
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @transaction.atomic
    def put(self, request, damage_id):
        """
        Update an existing damage record, including replacing image if provided.
        """
        damage = get_object_or_404(Damage, damageid=damage_id)
        serializer = AdminDamageWriteSerializer(damage, data=request.data, partial=True)
        if serializer.is_valid():
            damage = serializer.save()

            # Handle image replacement
            image_file = request.FILES.get('image')
            if image_file:
                # Delete old image file if exists
                if damage.image:
                    old_path = os.path.join(settings.MEDIA_ROOT, damage.image)
                    if os.path.exists(old_path):
                        os.remove(old_path)
                # Save new image
                filename = f"damages/{image_file.name}"
                with open(os.path.join(settings.MEDIA_ROOT, filename), "wb") as f:
                    for chunk in image_file.chunks():
                        f.write(chunk)
                damage.image = filename
                damage.save()

            return Response(
                {
                    "message": "Damage report updated successfully.",
                    "damage": AdminDamageSerializer(damage, context={'request': request}).data
                },
                status=status.HTTP_200_OK
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @transaction.atomic
    def delete(self, request, damage_id):
        """
        Delete a damage record and its associated image manually.
        """
        damage = get_object_or_404(Damage, damageid=damage_id)
        if damage.image:
            img_path = os.path.join(settings.MEDIA_ROOT, damage.image)
            if os.path.exists(img_path):
                os.remove(img_path)
        damage.delete()
        return Response({"message": "Damage report deleted successfully."}, status=status.HTTP_204_NO_CONTENT)
