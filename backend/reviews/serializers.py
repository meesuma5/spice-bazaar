from rest_framework import serializers
from .models import Reviews

class ReviewUploadSerializer(serializers.ModelSerializer):
    class Meta:
        model = Reviews
        fields = ['review_id', 'recipe', 'rating', 'comment', 'review_date']
        read_only_fields = ['review_id', 'user', 'review_date'] 
        
    def validate_rating(self, value):
        if value < 1 or value > 5:
            raise serializers.ValidationError("Rating must be between 1 and 5")
        return value
    
    def validate_comment(self, value):
        if not value.strip():
            raise serializers.ValidationError("Comment cannot be empty")
        return value
    
    def validate(self, data):
        user = self.context['request'].user
        recipe = data['recipe']
        
        if Reviews.objects.filter(user=user, recipe=recipe).exists():
            raise serializers.ValidationError({
                "error": "You have already reviewed this recipe",
                "detail": "Users can only submit one review per recipe"
            })
        
        return data

class ReviewEditSerializer(serializers.ModelSerializer):
    class Meta:
        model = Reviews
        fields = ['review_id', 'rating', 'comment']
        read_only_fields = ['review_id', 'user', 'recipe', 'review_date']
    
    def validate_rating(self, value):
        if value < 1 or value > 5:
            raise serializers.ValidationError("Rating must be between 1 and 5")
        return value
    
    def validate_comment(self, value):
        if not value.strip():
            raise serializers.ValidationError("Comment cannot be empty")
        return value