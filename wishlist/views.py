from rest_framework import generics, permissions, status
from rest_framework.response import Response
from .models import Wishlist
from .serializers import WishlistSerializer
from cars.models import Car

# only logged in users can access their wishlist
class WishlistListCreateView(generics.ListCreateAPIView):
    serializer_class = WishlistSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # returns wishlist items for the logged-in user only
        return Wishlist.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        car_id = self.request.data.get('car_id')  # gets car id from frontend
        try:
            car = Car.objects.get(carid=car_id)
        except Car.DoesNotExist:
            return Response({"error": "car not found"}, status=status.HTTP_404_NOT_FOUND)
        
        # prevents duplicates
        if Wishlist.objects.filter(user=self.request.user, car=car).exists():
            return Response({"message": "already in wishlist"}, status=status.HTTP_200_OK)
        
        serializer.save(user=self.request.user, car=car)
