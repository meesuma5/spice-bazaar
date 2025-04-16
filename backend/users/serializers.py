from rest_framework import serializers
from .models import Users
from .models import Bookmarks
from recipes.models import Recipes

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = Users
        fields = ('id', 'username', 'email', 'password', 'image_link')

    def create(self, validated_data):
        password = validated_data.pop('password')
        user = Users(**validated_data)
        user.set_password(password)
        user.save()
        return user


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        email = data.get('email')
        password = data.get('password')

        try:
            user = Users.objects.get(email=email)
        except Users.DoesNotExist:
            raise serializers.ValidationError("Incorrect email")

        if not user.check_password(password):  # uses AbstractBaseUser's built-in check
            raise serializers.ValidationError("Incorrect password")

        data['user'] = user
        return data


class UserUpdateSerializer(serializers.ModelSerializer):
    old_password = serializers.CharField(write_only=True, required=True)
    new_password = serializers.CharField(write_only=True, required=False)
    username = serializers.CharField(required=False)
    email = serializers.EmailField(required=False)

    class Meta:
        model = Users
        fields = ('username', 'email', 'old_password', 'new_password')

    def validate_old_password(self, value):
        user = self.instance
        if not user.check_password(value):
            raise serializers.ValidationError("Old password is incorrect.")
        return value

    def validate_email(self, value):
        user = self.instance
        if Users.objects.exclude(pk=user.pk).filter(email=value).exists():
            raise serializers.ValidationError("This email is already in use.")
        return value

    def validate_username(self, value):
        user = self.instance
        if Users.objects.exclude(pk=user.pk).filter(username=value).exists():
            raise serializers.ValidationError("This username is already taken.")
        return value

    def update(self, instance, validated_data):
        instance.username = validated_data.get('username', instance.username)
        instance.email = validated_data.get('email', instance.email)
        new_password = validated_data.get('new_password')
        if new_password:
            instance.set_password(new_password)
        instance.save()
        return instance


class BookmarkCreateSerializer(serializers.ModelSerializer):
    recipe_id = serializers.UUIDField(write_only=True, required=True)
    
    class Meta:
        model = Bookmarks
        fields = ['bookmark_id', 'recipe_id', 'bookmark_date']
        read_only_fields = ['bookmark_id', 'bookmark_date']
        
    def validate_recipe_id(self, value):
        try:
            recipe = Recipes.objects.get(recipe_id=value)
        except Recipes.DoesNotExist:
            raise serializers.ValidationError("Recipe does not exist.")
        return value
    
    def validate(self, data):
        user = self.context['request'].user
        recipe_id = data['recipe_id']
        
        if self.context['request'].method == 'POST' and Bookmarks.objects.filter(user=user, recipe_id=recipe_id).exists():
            raise serializers.ValidationError("You have already bookmarked this recipe")
            
        return data
    
    def create(self, validated_data):
        recipe_id = validated_data.pop('recipe_id')
        user = self.context['request'].user 
        
        bookmark = Bookmarks.objects.create(user=user, recipe_id=recipe_id)
        return bookmark
    
    
class BookmarkDeleteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Bookmarks