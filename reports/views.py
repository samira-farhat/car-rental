from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAdminUser
from rest_framework import status

from datetime import datetime
from django.db.models import Sum, Count, Avg, F
from django.db.models.functions import TruncMonth

from payments.models import Payment
from rentals.models import Rental
from damages.models import Damage
from cars.models import Car
from reservations.models import Reservation


class GenerateReportView(APIView):
    """
    API endpoint for generating system reports.
    Supports:
    - Financial Reports
    - Operational Reports
    - Rental History Reports
    """

    permission_classes = [IsAdminUser]

    def get(self, request):
        # -------------------------------
        # Extract query parameters
        # -------------------------------
        report_type = request.query_params.get('type')
        start_date = request.query_params.get('start_date')
        end_date = request.query_params.get('end_date')
        export_format = request.query_params.get('export')

        # -------------------------------
        # Validation: Required Fields
        # -------------------------------
        if not report_type:
            return Response(
                {"error": "Report type is required"},
                status=status.HTTP_400_BAD_REQUEST
            )

        if not start_date or not end_date:
            return Response(
                {"error": "Start date and end date are required"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # -------------------------------
        # Validation: Date Format
        # -------------------------------
        try:
            start_date = datetime.strptime(start_date, "%Y-%m-%d").date()
            end_date = datetime.strptime(end_date, "%Y-%m-%d").date()
        except ValueError:
            return Response(
                {"error": "Invalid date format. Use YYYY-MM-DD"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # -------------------------------
        # Validation: Date Logic
        # -------------------------------
        if start_date > end_date:
            return Response(
                {"error": "Start date must be before end date"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # ==================================================
        # FINANCIAL REPORT
        # ==================================================
        if report_type == "financial":
            total_income = Payment.objects.filter(
                status='completed',
                paymentdate__date__range=(start_date, end_date)
            ).aggregate(total=Sum('amount'))['total'] or 0

            total_rentals = Rental.objects.filter(
                createdat__date__range=(start_date, end_date)
            ).count()

            open_claims = Damage.objects.filter(
                status__in=['reported', 'under_repair']
            ).count()

            monthly_income_qs = Payment.objects.filter(
                status='completed',
                paymentdate__date__range=(start_date, end_date)
            ).annotate(
                month=TruncMonth('paymentdate')
            ).values('month').annotate(
                total=Sum('amount')
            ).order_by('month')

            monthly_income = [
                {
                    "month": item["month"].strftime("%b %Y"),
                    "total": float(item["total"])
                }
                for item in monthly_income_qs
            ]

            return Response({
                "report_type": "financial",
                "date_range": {"start": start_date, "end": end_date},
                "summary": {
                    "total_income": float(total_income),
                    "total_rentals": total_rentals,
                    "open_claims": open_claims
                },
                "charts": {
                    "monthly_income": monthly_income
                },
                "export_format": export_format
            }, status=status.HTTP_200_OK)

        # ==================================================
        # OPERATIONAL REPORT
        # ==================================================
        if report_type == "operational":
            car_status_qs = Car.objects.values('availabilitystatus').annotate(
                count=Count('carid')
            )
            car_status_counts = {
                item['availabilitystatus']: item['count']
                for item in car_status_qs
            }

            total_cars = Car.objects.count()

            rentals_qs = Rental.objects.filter(
                startdate__gte=start_date,
                enddate__lte=end_date
            )

            total_rentals = rentals_qs.count()
            avg_rental_duration = rentals_qs.aggregate(
                avg_duration=Avg('duration')
            )['avg_duration'] or 0

            rentals_by_category_qs = rentals_qs.values(
                category_name=F('car__categoryid__categoryname')
            ).annotate(
                count=Count('rentalid')
            ).order_by('category_name')

            rentals_by_category = {
                item['category_name']: item['count']
                for item in rentals_by_category_qs
            }

            reservations_qs = Reservation.objects.filter(
                createdat__date__range=(start_date, end_date)
            )

            reservation_status_qs = reservations_qs.values('status').annotate(
                count=Count('reservationid')
            )

            reservation_status_counts = {
                item['status']: item['count']
                for item in reservation_status_qs
            }

            total_reservations = reservations_qs.count()

            damages_qs = Damage.objects.filter(
                reportdate__range=(start_date, end_date)
            )

            damage_status_qs = damages_qs.values('status').annotate(
                count=Count('damageid')
            )

            damage_status_counts = {
                item['status']: item['count']
                for item in damage_status_qs
            }

            total_damages = damages_qs.count()
            total_repair_cost = damages_qs.aggregate(
                total=Sum('repaircost')
            )['total'] or 0

            return Response({
                "report_type": "operational",
                "date_range": {"start": start_date, "end": end_date},
                "summary": {
                    "total_cars": total_cars,
                    "car_status_counts": car_status_counts,
                    "total_rentals": total_rentals,
                    "avg_rental_duration": float(avg_rental_duration),
                    "rentals_by_category": rentals_by_category,
                    "total_reservations": total_reservations,
                    "reservation_status_counts": reservation_status_counts,
                    "total_damages": total_damages,
                    "damage_status_counts": damage_status_counts,
                    "total_repair_cost": float(total_repair_cost)
                },
                "export_format": export_format
            }, status=status.HTTP_200_OK)

        # ==================================================
        # RENTAL HISTORY REPORT
        # ==================================================
        if report_type == "rental_history":
            rentals_qs = Rental.objects.filter(
                startdate__gte=start_date,
                enddate__lte=end_date
            )

            total_rentals = rentals_qs.count()

            total_revenue = rentals_qs.filter(
                status='completed'
            ).aggregate(
                total=Sum('totalamount')
            )['total'] or 0

            avg_duration = rentals_qs.aggregate(
                avg_duration=Avg('duration')
            )['avg_duration'] or 0

            monthly_rentals_qs = rentals_qs.annotate(
                month=TruncMonth('startdate')
            ).values('month').annotate(
                count=Count('rentalid')
            ).order_by('month')

            monthly_rentals = [
                {
                    "month": item['month'].strftime("%b %Y"),
                    "count": item['count']
                }
                for item in monthly_rentals_qs
            ]

            rentals_by_category_qs = rentals_qs.values(
                category_name=F('car__categoryid__categoryname')
            ).annotate(
                count=Count('rentalid')
            ).order_by('category_name')

            rentals_by_category = {
                item['category_name']: item['count']
                for item in rentals_by_category_qs
            }

            return Response({
                "report_type": "rental_history",
                "date_range": {"start": start_date, "end": end_date},
                "summary": {
                    "total_rentals": total_rentals,
                    "total_revenue": float(total_revenue),
                    "avg_duration": float(avg_duration),
                    "rentals_by_category": rentals_by_category
                },
                "charts": {
                    "monthly_rentals": monthly_rentals
                },
                "export_format": export_format
            }, status=status.HTTP_200_OK)

        # -------------------------------
        # Unsupported report type
        # -------------------------------
        return Response(
            {"error": "Unsupported report type"},
            status=status.HTTP_400_BAD_REQUEST
        )
