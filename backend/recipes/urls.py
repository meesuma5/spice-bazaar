from django.urls import path
from .views import RecipeCatalogView, UserRecipesView

urlpatterns = [
    path('catalog/', RecipeCatalogView.as_view(), name='catalog'),
    path('uploaded/', UserRecipesView.as_view(), name='uploaded-recipes'),
]