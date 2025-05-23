# Generated by Django 5.2 on 2025-04-12 18:07

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('recipes', '0003_recipes_cook_time_recipes_diet'),
    ]

    operations = [
        migrations.AlterField(
            model_name='recipes',
            name='cook_time',
            field=models.TimeField(),
        ),
        migrations.AlterField(
            model_name='recipes',
            name='description',
            field=models.TextField(),
        ),
        migrations.AlterField(
            model_name='recipes',
            name='image',
            field=models.CharField(max_length=255),
        ),
        migrations.AlterField(
            model_name='recipes',
            name='ingredients',
            field=models.CharField(max_length=1000),
        ),
        migrations.AlterField(
            model_name='recipes',
            name='instructions',
            field=models.TextField(),
        ),
        migrations.AlterField(
            model_name='recipes',
            name='prep_time',
            field=models.TimeField(),
        ),
    ]
