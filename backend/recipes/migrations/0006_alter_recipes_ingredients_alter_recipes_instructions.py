# Generated by Django 5.2 on 2025-04-14 11:49

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('recipes', '0005_alter_recipes_image_alter_recipes_video_link'),
    ]

    operations = [
        migrations.AlterField(
            model_name='recipes',
            name='ingredients',
            field=models.JSONField(default=list),
        ),
        migrations.AlterField(
            model_name='recipes',
            name='instructions',
            field=models.JSONField(default=list),
        ),
    ]
