from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken

from .models import Users, Bookmarks
from recipes.models import Recipes
from .serializers import RegisterSerializer, LoginSerializer, UserUpdateSerializer, BookmarkCreateSerializer, BookmarkDeleteSerializer


class RegisterView(generics.CreateAPIView):
    queryset = Users.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]


class LoginView(generics.GenericAPIView):
    serializer_class = LoginSerializer
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']

        refresh = RefreshToken.for_user(user)

        recipe_count = Recipes.objects.filter(user=user).count()
        bookmark_count = Bookmarks.objects.filter(user=user).count()

        return Response({
            'refresh': str(refresh),
            'access': str(refresh.access_token),
            'username': user.username,
            'email': user.email,
            'reg_date': user.reg_date,
            'image_link': user.image_link,
            'recipe_count': recipe_count,
            'bookmark_count': bookmark_count
        })


class UserUpdateView(generics.UpdateAPIView):
    serializer_class = UserUpdateSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user


class BookmarkCreateView(generics.CreateAPIView):
    serializer_class = BookmarkCreateSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save()
        
        
class BookmarkDeleteView(generics.DestroyAPIView):
    serializer_class = BookmarkDeleteSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = 'recipe_id'
    
    def get_queryset(self): # allow only the user who created the bookmark to delete it
        return Bookmarks.objects.filter(user=self.request.user)
    
    def destroy(self, request, *args, **kwargs):
        try:
            instance = self.get_object()
            self.perform_destroy(instance)
            return Response({"message": "Bookmark deleted successfully."}, status=status.HTTP_200_OK)
        except:
            return Response({"error": "Bookmark not found."}, status=status.HTTP_404_NOT_FOUND)