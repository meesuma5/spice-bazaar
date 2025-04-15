from rest_framework import serializers
from .models import Recipes
from django.utils.duration import duration_string
from django.utils import timezone
from reviews.models import Reviews
from users.models import Bookmarks

class RecipeCatalogSerializer(serializers.ModelSerializer):
    
    tags = serializers.SerializerMethodField()
    time = serializers.SerializerMethodField()
    author = serializers.SerializerMethodField()
    
    class Meta:
        model = Recipes
        # coming from the models
        fields = ['recipe_id', 'title', 'description', 'tags', 'time', 'upload_date', 'author', 'image']
    
    def get_tags(self, obj):
    
        tags = [] # making it as tags to be displayed easily on the catalog
        if obj.cuisine:
            tags.append(obj.cuisine)
        if obj.course:
            tags.append(obj.course)
        if obj.diet:
            tags.append(obj.diet)
        return tags
    
    def get_time(self, obj):
        total_minutes = 0
        # making it as tags to be displayed easily on the catalog
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


class ReviewBriefSerializer(serializers.ModelSerializer):
    username = serializers.SerializerMethodField()
    
    class Meta:
        model = Reviews
        fields = ['review_id', 'username', 'rating', 'comment', 'review_date']
    
    def get_username(self, obj):
        return obj.user.username


class RecipeViewSerializer(serializers.ModelSerializer):
    reviews = serializers.SerializerMethodField()
    is_bookmarked = serializers.SerializerMethodField()
    your_review = serializers.SerializerMethodField()
    is_owner = serializers.SerializerMethodField()
    tags = serializers.SerializerMethodField()
    author = serializers.SerializerMethodField()
    
    class Meta:
        model = Recipes
        fields = ['recipe_id', 'title', 'description', 'ingredients', 'instructions', 'tags', 'prep_time', 'cook_time', 'upload_date',  'author', 'image', 'video_link', 'your_review', 'reviews', 'is_owner', 'is_bookmarked'] 
    
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
    
    def get_your_review(self, obj): # Return the current user's review if it exists
        request = self.context.get('request')
        if request and hasattr(request, 'user') and request.user.is_authenticated:
            review = obj.reviews.filter(user=request.user).first()
            if review:
                return ReviewBriefSerializer(review).data
        return None
    
    def get_reviews(self, obj):
        request = self.context.get('request')
        # Using the related_name 'reviews' defined in the Reviews model
        reviews = obj.reviews.exclude(user=request.user).select_related('user').order_by('-review_date')
        return ReviewBriefSerializer(reviews, many=True).data

    def get_is_bookmarked(self, obj):
        request = self.context.get('request')
        if request and hasattr(request, 'user') and request.user.is_authenticated:
            return Bookmarks.objects.filter(user=request.user, recipe=obj).exists()
        return False
    
    def get_is_owner(self, obj):
        request = self.context.get('request')
        if request and hasattr(request, 'user') and request.user.is_authenticated:
            return obj.user == request.user
        return False


class RecipeUploadSerializer(serializers.ModelSerializer):    
    class Meta:
        model = Recipes
        fields = ['recipe_id', 'title', 'description', 'ingredients', 'instructions', 'cuisine', 'course', 'diet', 'prep_time', 'cook_time', 'image', 'video_link']
        read_only_fields = ['recipe_id', 'user']  # user will be set in the view
        extra_kwargs = { # making them as required since they are needed during upload (will give error if not provided)
            'title': {'required': True},
            'description': {'required': True},
            'instructions': {'required': True},
            'ingredients': {'required': True},
            'prep_time': {'required': True},
            'cook_time': {'required': True},
            'image': {'required': True},
        }    
    
    def validate(self, data):
        # Check daily recipe limit to 3
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
    
    
class RecipeEditSerializer(serializers.ModelSerializer):    
    class Meta:
        model = Recipes
        # we will be sending this as a response, or can be taken as a request
        fields = ['recipe_id', 'title', 'description', 'ingredients', 'instructions', 'cuisine', 'course', 'diet', 'prep_time', 'cook_time', 'image', 'video_link']
        read_only_fields = ['recipe_id', 'user']  # user will be set in the view
        extra_kwargs = { # marking as optional since not all of them will be needed during update
            'title': {'required': False},
            'description': {'required': False},
            'instructions': {'required': False},
            'ingredients': {'required': False},
            'prep_time': {'required': False},
            'cook_time': {'required': False},
            'image': {'required': False},
        }
        
    def validate(self, data):
        # Validate video link format if provided and changed
        if data.get('video_link') and not (
            data['video_link'].startswith('http://') or 
            data['video_link'].startswith('https://')
        ):
            raise serializers.ValidationError(
                {"video_link": "Video link must be a valid URL starting with http:// or https://"}
            )
        
        # Validate that recipe belongs to the user attempting to edit it
        recipe = self.instance
        user = self.context['request'].user
        if recipe.user != user:
            raise serializers.ValidationError(
                {"non_field_errors": "You can only edit your own recipes."}
            )
            
        return data
    
    def update(self, instance, validated_data):
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        
        instance.save()
        return instance
    
class RecipeDeleteSerializer(serializers.ModelSerializer):    
    class Meta:
        model = Recipes
        read_only_fields = ['user']