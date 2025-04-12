from django.urls import path
from .views import RecipeCatalogView, UserRecipesView, RecipeViewView, RecipeUploadView

urlpatterns = [
    path('catalog/', RecipeCatalogView.as_view(), name='catalog'),
    path('uploaded/', UserRecipesView.as_view(), name='uploaded-recipes'),
    path('view/<uuid:recipe_id>/', RecipeViewView.as_view(), name='view-recipe'),
    path('upload/', RecipeUploadView.as_view(), name='upload-recipe'),
]