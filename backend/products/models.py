import uuid
from django.db import models

class Users(models.Model):
    user_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    username = models.CharField(max_length=255, unique=True)
    email = models.EmailField(max_length=255, unique=True)
    password = models.CharField(max_length=255)
    profile_picture = models.BinaryField(null=True, blank=True)
    reg_date = models.DateField(auto_now_add=True)
    
    def __str__(self):
        return self.username
    
    class Meta:
        db_table = 'Users'
        verbose_name_plural = "Users"

class Recipe(models.Model):
    recipe_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.TextField()
    description = models.TextField(null=True, blank=True)
    ingredients = models.CharField(max_length=1000, null=True, blank=True)
    instructions = models.TextField(null=True, blank=True)
    cuisine = models.TextField(null=True, blank=True)
    course = models.TextField(null=True, blank=True)
    prep_time = models.TimeField(null=True, blank=True)
    upload_date = models.DateField(auto_now_add=True)
    user = models.ForeignKey(Users, on_delete=models.CASCADE, related_name='recipes')
    image = models.CharField(max_length=255, null=True, blank=True)
    video_link = models.CharField(max_length=255, null=True, blank=True)
    
    def __str__(self):
        return self.title
    
    class Meta:
        db_table = 'Recipe'

class Reviews(models.Model):
    review_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(Users, on_delete=models.CASCADE, related_name='reviews')
    recipe = models.ForeignKey(Recipe, on_delete=models.CASCADE, related_name='reviews')
    rating = models.IntegerField()
    comment = models.TextField(null=True, blank=True)
    review_date = models.DateField(auto_now_add=True)
    
    def __str__(self):
        return f"Review by {self.user.username} for {self.recipe.title}"
    
    class Meta:
        db_table = 'Reviews'
        verbose_name_plural = "Reviews"
    
    def save(self, *args, **kwargs):
        if not 1 <= self.rating <= 5:
            raise ValueError("Rating must be between 1 and 5")
        super().save(*args, **kwargs)

class Bookmarks(models.Model):
    bookmark_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(Users, on_delete=models.CASCADE, related_name='bookmarks')
    recipe = models.ForeignKey(Recipe, on_delete=models.CASCADE, related_name='bookmarks')
    bookmark_date = models.DateField(auto_now_add=True)
    
    def __str__(self):
        return f"Bookmark by {self.user.username} for {self.recipe.title}"
    
    class Meta:
        db_table = 'Bookmarks'
        verbose_name_plural = "Bookmarks"
