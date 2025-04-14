from django.urls import path
from .views import RecipeCatalogView, UserRecipesView, RecipeViewView, RecipeUploadView, RecipeEditView, RecipeDeleteView

urlpatterns = [
    path('catalog/', RecipeCatalogView.as_view(), name='catalog'),
    path('uploaded/', UserRecipesView.as_view(), name='uploaded-recipes'),
    path('view/<uuid:recipe_id>/', RecipeViewView.as_view(), name='view-recipe'),
    path('upload/', RecipeUploadView.as_view(), name='upload-recipe'),
    path('edit/<uuid:recipe_id>/', RecipeEditView.as_view(), name='edit-recipe'),
    path('delete/<uuid:recipe_id>/', RecipeDeleteView.as_view(), name='delete-recipe'),
]