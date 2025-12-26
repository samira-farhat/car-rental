from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from .models import Car
from .serializers import CarSerializer

class CarListView(APIView):

    permission_classes = [AllowAny]
    
    def get(self, request):
        cars = Car.objects.all()
        serializer = CarSerializer(
            cars,
            many=True,
            context={'request': request}
        )
        return Response(serializer.data)
