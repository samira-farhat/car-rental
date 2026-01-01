from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAdminUser
from rest_framework import status

from datetime import datetime

# Django ORM aggregation tools
from django.db.models import Sum, Count
from django.db.models.functions import TruncMonth

# Import existing models
from payments.models import Payment
from rentals.models import Rental
from damages.models import Damage


class GenerateReportView(APIView):
    """
    API endpoint for generating system reports.
    Currently supports Financial Reports (Step 2A).
    """

    # Restrict access to admin users only
    permission_classes = [IsAdminUser]

    def get(self, request):
        """
        Handles report generation requests.
        """

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
        # STEP 2A — FINANCIAL REPORT LOGIC
        # ==================================================
        if report_type == "financial":

            # -------------------------------
            # Total Income (Completed Payments)
            # -------------------------------
            total_income = Payment.objects.filter(
                status='completed',
                paymentdate__date__range=(start_date, end_date)
            ).aggregate(
                total=Sum('amount')
            )['total'] or 0

            # -------------------------------
            # Total Rentals in Date Range
            # -------------------------------
            total_rentals = Rental.objects.filter(
                createdat__date__range=(start_date, end_date)
            ).count()

            # -------------------------------
            # Open Damage Claims
            # -------------------------------
            open_claims = Damage.objects.filter(
                status__in=['reported', 'under_repair']
            ).count()

            # -------------------------------
            # Monthly Income (Chart Data)
            # -------------------------------
            monthly_income_qs = Payment.objects.filter(
                status='completed',
                paymentdate__date__range=(start_date, end_date)
            ).annotate(
                month=TruncMonth('paymentdate')
            ).values(
                'month'
            ).annotate(
                total=Sum('amount')
            ).order_by('month')

            # Convert queryset into chart-friendly format
            monthly_income = [
                {
                    "month": item["month"].strftime("%b %Y"),
                    "total": float(item["total"])
                }
                for item in monthly_income_qs
            ]

            # -------------------------------
            # Final Financial Report Response
            # -------------------------------
            return Response(
                {
                    "report_type": "financial",
                    "date_range": {
                        "start": start_date,
                        "end": end_date
                    },
                    "summary": {
                        "total_income": float(total_income),
                        "total_rentals": total_rentals,
                        "open_claims": open_claims
                    },
                    "charts": {
                        "monthly_income": monthly_income
                    },
                    "export_format": export_format
                },
                status=status.HTTP_200_OK
            )

        # -------------------------------
        # Unsupported Report Type (for now)
        # -------------------------------
        return Response(
            {"error": "Unsupported report type"},
            status=status.HTTP_400_BAD_REQUEST
        )
