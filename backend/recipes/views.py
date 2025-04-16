from rest_framework import generics
from rest_framework.permissions import AllowAny, IsAuthenticated
from django.db.models import Exists, OuterRef

from .models import Recipes
from users.models import Bookmarks
from .serializers import RecipeCatalogSerializer, RecipeViewSerializer, RecipeUploadSerializer, RecipeEditSerializer, RecipeDeleteSerializer

class RecipeCatalogView(generics.ListAPIView):

    # queryset = Recipes.objects.all().order_by('-upload_date').select_related('user') 
    serializer_class = RecipeCatalogSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        
        # Create a subquery that checks if current recipe is bookmarked
        bookmark_exists = Exists(
            Bookmarks.objects.filter(
                user=user,
                recipe=OuterRef('pk')  # Reference to the current recipe being processed
            )
        )
        
        # Annotate the queryset with bookmark information
        return Recipes.objects.annotate(
            is_bookmarked=bookmark_exists
        ).order_by('-upload_date').select_related('user')

class UserRecipesView(generics.ListAPIView): # for getting a particular user's recipes, used to check your own uploaded recipes
    serializer_class = RecipeCatalogSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        
        bookmark_exists = Exists(
            Bookmarks.objects.filter(
                user=user,
                recipe=OuterRef('pk')
            )
        )
        
        return Recipes.objects.filter(user=user).annotate(
            is_bookmarked=bookmark_exists
        ).order_by('-upload_date').select_related('user')
    
class RecipeViewView(generics.RetrieveAPIView): # for viewing a recipie (any)
    serializer_class = RecipeViewSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = 'recipe_id'
    
    def get_queryset(self): # Optimizes database queries by prefetching related objects that will be used in the serializer.
        return Recipes.objects.all().select_related('user').prefetch_related('reviews__user')

class RecipeUploadView(generics.CreateAPIView):
    serializer_class = RecipeUploadSerializer
    permission_classes = [IsAuthenticated]
    
class RecipeEditView(generics.UpdateAPIView): # gives PUT request
    serializer_class = RecipeEditSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = 'recipe_id'
    queryset = Recipes.objects.all().select_related('user')
    
class RecipeDeleteView(generics.DestroyAPIView): # gives DELETE request
    serializer_class = RecipeDeleteSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = 'recipe_id'
    def get_queryset(self):
        # Only return recipes owned by the current user. This ensures users can only delete their own recipes
        return Recipes.objects.filter(user=self.request.user)