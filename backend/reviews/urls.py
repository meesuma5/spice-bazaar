from django.urls import path
from .views import ReviewUploadView, ReviewEditView, ReviewDeleteView

urlpatterns = [
    path('upload/', ReviewUploadView.as_view(), name='review-upload'),
    path('edit/<uuid:review_id>/', ReviewEditView.as_view(), name='review-edit'),
    path('delete/<uuid:review_id>/', ReviewDeleteView.as_view(), name='review-delete'),
]