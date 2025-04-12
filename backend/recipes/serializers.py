from rest_framework import serializers
from .models import Recipes
from django.utils.duration import duration_string

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