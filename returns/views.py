from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.db import transaction
from django.utils import timezone

from .models import CarReturn
from .serializers import CarReturnCreateSerializer, CarReturnSerializer
from rentals.models import Rental
from reservations.models import Reservation
from cars.models import Car
from django.shortcuts import get_object_or_404

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def request_return(request):
    serializer = CarReturnCreateSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    data = serializer.validated_data

    rental_id = data['rental_id']

    # 1) Rental must exist and belong to this user
    try:
        rental = Rental.objects.get(rentalid=rental_id, user=request.user)
    except Rental.DoesNotExist:
        return Response({"error": "Rental not found for this user"}, status=status.HTTP_404_NOT_FOUND)

    # 2) Rental must be active
    if rental.status != 'active':
        return Response({"error": "Only active rentals can be returned"}, status=status.HTTP_400_BAD_REQUEST)

    # 3) Prevent duplicate return request (OneToOne)
    existing = CarReturn.objects.filter(rental=rental).first()
    if existing:
        return Response(
            {"error": "Return request already submitted", "return_id": existing.returnid},
            status=status.HTTP_400_BAD_REQUEST
        )

    # 4) Create return request (approved = 0)
    car_return = CarReturn.objects.create(
        rental=rental,
        returndatetime=data['returndatetime'],
        mileage=data['mileage'],
        condition=data['condition'],
        comments=data.get('comments', ''),
        approved=False,
        approvedby=None,
        createdat=timezone.now(),
    )

    return Response({
        "message": "Return request submitted successfully",
        "return": CarReturnSerializer(car_return).data
    }, status=status.HTTP_201_CREATED)



def _is_manager(user):
    # ✅ adjust this depending on your project:
    # option 1: user.role == 'manager'
    return getattr(user, "role", None) == "manager"

@api_view(["POST"])
@permission_classes([IsAuthenticated])
def approve_return(request, return_id):
    user = request.user

    if not _is_manager(user):
        return Response({"error": "Only managers can approve returns"}, status=status.HTTP_403_FORBIDDEN)

    try:
        ret = CarReturn.objects.select_related("rental", "rental__car").get(pk=return_id)
    except CarReturn.DoesNotExist:
        return Response({"error": "Return request not found"}, status=status.HTTP_404_NOT_FOUND)

    if ret.approved:
        return Response({"error": "Return already approved"}, status=status.HTTP_400_BAD_REQUEST)

    rental = ret.rental
    if rental.status != "active":
        return Response({"error": "Only active rentals can be approved"}, status=status.HTTP_400_BAD_REQUEST)

    with transaction.atomic():
        # 1) approve return
        ret.approved = True
        ret.approvedby = user
        ret.save()

        # 2) complete rental
        rental.status = "completed"
        rental.save()

        # 3) make car available again
        car = rental.car
        car.availabilitystatus = "available"
        car.save()

    return Response({
        "message": "Return approved successfully",
        "return_id": ret.pk,
        "rental_id": rental.rentalid,
        "car_id": car.carid,
        "car_status": car.availabilitystatus,
        "rental_status": rental.status,
        "approved": ret.approved,
    }, status=status.HTTP_200_OK)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def pending_returns(request):
    if request.user.role != "manager":
        return Response(
            {"error": "Only managers can view pending returns"},
            status=403
        )

    returns = CarReturn.objects.filter(approved=False)
    serializer = CarReturnSerializer(returns, many=True)

    return Response(serializer.data, status=200)

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def my_returns(request):
    # Returns made by the logged-in user only
    returns = CarReturn.objects.filter(rental__user=request.user).order_by("-createdat")
    serializer = CarReturnSerializer(returns, many=True)
    return Response(serializer.data)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def return_detail(request, pk):
    """
    Customer: can view ONLY their own return
    Manager: can view ANY return
    """

    car_return = get_object_or_404(CarReturn, pk=pk)

    user = request.user

    # Manager can view all
    if user.role == "manager":
        serializer = CarReturnSerializer(car_return)
        return Response(serializer.data, status=200)

    # Customer: only their own rental
    if car_return.rental.user_id != user.id:
        return Response(
            {"error": "You are not allowed to view this return"},
            status=status.HTTP_403_FORBIDDEN
        )

    serializer = CarReturnSerializer(car_return)
    return Response(serializer.data, status=200)
