# payments/urls.py
from django.urls import path
from .views import ApprovedPaymentsView, CreatePaymentView, ApprovePaymentView, MyPaymentsView, PendingPaymentsView, RejectPaymentView, RejectedPaymentsView, PaymentByRentalView

urlpatterns = [
    path('create/', CreatePaymentView.as_view(), name='create_payment'),
    path('approve/<int:payment_id>/', ApprovePaymentView.as_view(), name='approve_payment'),
    path('my/', MyPaymentsView.as_view(), name='my_payments'),
    path('pending/', PendingPaymentsView.as_view(), name='pending_payments'),
    path('reject/<int:payment_id>/', RejectPaymentView.as_view(), name='reject_payment'),
    path('approved/', ApprovedPaymentsView.as_view(), name='approved_payments'),
    path('rejected/', RejectedPaymentsView.as_view(), name='rejected_payments'),
    path('by_rental/<int:rental_id>/', PaymentByRentalView.as_view(), name='payment-by-rental'),

]
