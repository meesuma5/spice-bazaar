from rest_framework import serializers
from .models import Recipes
from django.utils.duration import duration_string
from django.utils import timezone

class RecipeCatalogSerializer(serializers.ModelSerializer):
    
    tags = serializers.SerializerMethodField()
    time = serializers.SerializerMethodField()
    author = serializers.SerializerMethodField()
    
    class Meta:
        model = Recipes
        fields = ['recipe_id', 'title', 'description', 'tags', 'time', 'upload_date', 'author', 'image']
    
    def get_tags(self, obj):
    
        tags = []
        if obj.cuisine:
            tags.append(obj.cuisine)
        if obj.course:
            tags.append(obj.course)
        if obj.diet:
            tags.append(obj.diet)
        return tags
    
    def get_time(self, obj):
        total_minutes = 0
        
        if obj.prep_time:
            hours, minutes, seconds = obj.prep_time.hour, obj.prep_time.minute, obj.prep_time.second
            total_minutes += (hours * 60) + minutes
        
        # Add cook_time minutes if it exists
        if obj.cook_time:
            hours, minutes, seconds = obj.cook_time.hour, obj.cook_time.minute, obj.cook_time.second
            total_minutes += (hours * 60) + minutes
            
        return total_minutes
    
    def get_author(self, obj):
        return obj.user.username if obj.user else None
    
    
class RecipeViewSerializer(serializers.ModelSerializer):
    
    tags = serializers.SerializerMethodField()
    author = serializers.SerializerMethodField()
    
    class Meta:
        model = Recipes
        fields = ['recipe_id', 'title', 'description', 'ingredients', 'instructions', 'tags', 'prep_time', 'cook_time', 'upload_date',  'author', 'image', 'video_link']
    
    def get_tags(self, obj):
    
        tags = []
        if obj.cuisine:
            tags.append(obj.cuisine)
        if obj.course:
            tags.append(obj.course)
        if obj.diet:
            tags.append(obj.diet)
        return tags
    
    def get_author(self, obj):
        return obj.user.username if obj.user else None
    
    
class RecipeUploadSerializer(serializers.ModelSerializer):    
    class Meta:
        model = Recipes
        fields = ['recipe_id', 'title', 'description', 'ingredients', 'instructions', 'cuisine', 'course', 'diet', 'prep_time', 'cook_time', 'image', 'video_link']
        read_only_fields = ['recipe_id', 'user']  # user will be set in the view
        extra_kwargs = {
            'title': {'required': True},
            'description': {'required': True},
            'instructions': {'required': True},
            'ingredients': {'required': True},
            'prep_time': {'required': True},
            'cook_time': {'required': True},
            'image': {'required': True},
        }    
    
    def validate(self, data):
        # Check daily recipe limit
        user = self.context['request'].user
        today = timezone.now().date()
        recipes_today = Recipes.objects.filter(user=user, upload_date=today).count()
        
        if recipes_today >= 3:
            raise serializers.ValidationError(
                {"non_field_errors": "You can only upload up to 3 recipes per day. Please try again tomorrow."}
            )
            
        # Validate video link format if provided
        if data.get('video_link') and not (
            data['video_link'].startswith('http://') or 
            data['video_link'].startswith('https://')
        ):
            raise serializers.ValidationError(
                {"video_link": "Video link must be a valid URL starting with http:// or https://"}
            )
        return data
    
    def create(self, validated_data):
        # Get the user from the context
        user = self.context['request'].user
        # Create recipe with the user
        recipe = Recipes.objects.create(user=user, **validated_data)
        return recipe