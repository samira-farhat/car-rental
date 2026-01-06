from django.urls import path
from . import views
from .views import pending_returns
from .views import my_returns

urlpatterns = [
    path("request/", views.request_return, name="request_return"),
    path("approve/<int:return_id>/", views.approve_return, name="approve_return"),
    path("pending/", pending_returns),
    path("my/", my_returns, name="my-returns"),
      path('<int:pk>/', views.return_detail),
]