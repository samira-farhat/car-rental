from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAdminUser
from rest_framework import status
from datetime import datetime

class GenerateReportView(APIView):
    """
    API endpoint for generating system reports.
    Access is restricted to admin users only.
    """
    
    # Ensure only admin users can access this endpoint
    permission_classes = [IsAdminUser]

    def get(self, request):
        """
        Handles report generation requests.
        This is Step 1: validation and structure only.
        """

        # Retrieve query parameters from the request
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

        # -------------------------------
        # Temporary Response (Step 1)
        # -------------------------------
        # This confirms that:
        # - Endpoint works
        # - Authentication works
        # - Validation works
        # Real report logic comes in Step 2
        return Response(
            {
                "message": "Report request validated successfully",
                "report_type": report_type,
                "date_range": {
                    "start": start_date,
                    "end": end_date
                },
                "export_format": export_format,
                "status": "ready_for_generation"
            },
            status=status.HTTP_200_OK
        )
