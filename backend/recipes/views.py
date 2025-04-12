from rest_framework import generics
from rest_framework.permissions import AllowAny, IsAuthenticated

from .models import Recipes
from .serializers import RecipeCatalogSerializer, RecipeViewSerializer

class RecipeCatalogView(generics.ListAPIView):

    queryset = Recipes.objects.all().order_by('-upload_date').select_related('user') 
    serializer_class = RecipeCatalogSerializer
    permission_classes = [AllowAny]

class UserRecipesView(generics.ListAPIView): # for getting a particular user's recipes, used to check your own uploaded recipes
    serializer_class = RecipeCatalogSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        return Recipes.objects.filter(user=user).order_by('-upload_date').select_related('user')
    
class RecipeViewView(generics.RetrieveAPIView): # for viewing a recipie (any)
    serializer_class = RecipeViewSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = 'recipe_id'
    queryset = Recipes.objects.all().select_related('user')