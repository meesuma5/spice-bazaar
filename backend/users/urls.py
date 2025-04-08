from django.urls import path
from .views import RegisterView, LoginView, UserUpdateView, UserDetailView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('update/', UserUpdateView.as_view(), name='update-user'),
    path('me/', UserDetailView.as_view(), name='current-user'),
]