import uuid
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator

class Reviews(models.Model):
    review_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey('users.Users', on_delete=models.CASCADE, related_name='reviews')
    recipe = models.ForeignKey('recipes.Recipes', on_delete=models.CASCADE, related_name='reviews')
    rating = models.IntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)])
    comment = models.TextField(null=True, blank=True)
    review_date = models.DateField(auto_now_add=True)
    
    def __str__(self):
        return f"Review by {self.user.username} for {self.recipe.title}"
    
    class Meta:
        db_table = 'Reviews'
        verbose_name_plural = "Reviews"