from django.urls import path
from .views import RegisterView, LoginView, UserUpdateView
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('update/', UserUpdateView.as_view(), name='update-user'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]