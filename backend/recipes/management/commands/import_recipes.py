import uuid
import csv
import os
from django.core.management.base import BaseCommand
from django.utils import timezone
from django.db import transaction
from users.models import Users
from recipes.models import Recipes

class Command(BaseCommand):
    help = 'Import recipes from CSV file'

    def add_arguments(self, parser):
        parser.add_argument('csv_file', type=str, help='Path to the CSV file')
        parser.add_argument('--start-row', type=int, default=0, help='Start importing from this row (0-indexed, excluding header)')

    def handle(self, *args, **options):
        csv_file_path = options['csv_file']
        start_row = options['start_row']
        
        if not os.path.exists(csv_file_path):
            self.stdout.write(self.style.ERROR(f'File not found: {csv_file_path}'))
            return
        
        try:
            with transaction.atomic():
                # Create or get Anonymous user
                anonymous_id = uuid.uuid4()
                anonymous_user, created = Users.objects.get_or_create(
                    username='Anonymous',
                    defaults={
                        'id': anonymous_id,
                        'email': 'anonymous@example.com',
                        'reg_date': timezone.now().date()
                    }
                )
                
                if created:
                    # Set a default password (but hashed) using set_password
                    anonymous_user.set_password('pbkdf2_sha256$260000$randomhashhere')
                    anonymous_user.save()
                    self.stdout.write(self.style.SUCCESS('Created Anonymous user'))
                else:
                    self.stdout.write(self.style.SUCCESS('Using existing Anonymous user'))
                    anonymous_id = anonymous_user.id
                
                # Read and import recipes
                recipes_imported = 0
                recipes_skipped = 0
                current_row = 0
                
                with open(csv_file_path, 'r', encoding='utf-8') as file:
                    reader = csv.DictReader(file)
                    
                    for row in reader:
                        # Skip rows until we reach the start row
                        if current_row < start_row:
                            current_row += 1
                            continue
                            
                        current_row += 1
                        
                        # Check if recipe with same name already exists
                        recipe_name = row.get('name', '').strip()
                        if not recipe_name:
                            recipe_name = 'Untitled Recipe'
                            
                        # Skip if recipe already exists
                        if Recipes.objects.filter(title=recipe_name).exists():
                            recipes_skipped += 1
                            if recipes_skipped % 50 == 0:
                                self.stdout.write(f"Skipped {recipes_skipped} existing recipes...")
                            continue
                            
                        # Map CSV columns to database fields
                        recipe_id = uuid.uuid4()
                        
                        # Extract time values and convert to proper format
                        try:
                            prep_time_minutes = int(float(row.get('prep_time (in mins)', 0)))
                            
                            # Handle special case where time would be 24:00:00
                            if prep_time_minutes >= 24 * 60:
                                hours = 23
                                minutes = 59
                            else:
                                hours, minutes = divmod(prep_time_minutes, 60)
                                
                            prep_time = f"{hours:02d}:{minutes:02d}:00"
                        except (ValueError, TypeError):
                            prep_time = "00:30:00"  # Default to 30 minutes
                        
                        # Map ingredients properly
                        ingredients = row.get('ingredients_name', '')
                        quantities = row.get('ingredients_quantity', '')
                        
                        # Combine ingredients and quantities if available
                        ingredient_list = []
                        if ingredients and quantities:
                            ing_items = ingredients.split(',')
                            qty_items = quantities.split(',')
                            
                            for i in range(min(len(ing_items), len(qty_items))):
                                ingredient_list.append(f"{qty_items[i].strip()} {ing_items[i].strip()}")
                        else:
                            ingredient_list = [ingredients]
                        
                        ingredients_text = ', '.join(ingredient_list)
                        
                        # Create recipe
                        Recipes.objects.create(
                            recipe_id=recipe_id,
                            title=recipe_name,
                            description=row.get('description', ''),
                            ingredients=ingredients_text[:1000],  # Truncate to fit VARCHAR(1000)
                            instructions=row.get('instructions', ''),
                            cuisine=row.get('cuisine', ''),
                            course=row.get('course', ''),
                            prep_time=prep_time,
                            upload_date=timezone.now().date(),
                            user_id=anonymous_id,
                            image=row.get('image_url', '')
                        )
                        
                        recipes_imported += 1
                        
                        if recipes_imported % 100 == 0:
                            self.stdout.write(f"Imported {recipes_imported} recipes...")
                
                self.stdout.write(self.style.SUCCESS(f'Successfully imported {recipes_imported} recipes'))
                self.stdout.write(self.style.SUCCESS(f'Skipped {recipes_skipped} existing recipes'))
                self.stdout.write(self.style.SUCCESS(f'Current row processed: {current_row}'))
                
        except Exception as e:
            self.stdout.write(self.style.ERROR(f'Error importing recipes: {str(e)}'))
            self.stdout.write(self.style.ERROR(f'Failed at row: {current_row}'))
