import uuid
from django.db import models

class Recipes(models.Model):
    recipe_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    title = models.TextField()
    description = models.TextField()
    ingredients = models.CharField(max_length=1000)
    instructions = models.TextField()
    cuisine = models.TextField(null=True, blank=True)
    course = models.TextField(null=True, blank=True)
    diet = models.TextField(null=True, blank=True)
    prep_time = models.TimeField()
    cook_time = models.TimeField()
    upload_date = models.DateField(auto_now_add=True)
    user = models.ForeignKey('users.Users', on_delete=models.CASCADE, related_name='recipes')
    image = models.CharField(max_length=1024, null=True)
    video_link = models.CharField(max_length=1024, null=True, blank=True)
    
    def __str__(self):
        return self.title
    
    class Meta:
        db_table = 'Recipes'
        verbose_name_plural = "Recipes"