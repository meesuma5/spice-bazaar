# Generated by Django 5.2 on 2025-04-09 22:53

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('recipes', '0002_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='recipes',
            name='cook_time',
            field=models.TimeField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='recipes',
            name='diet',
            field=models.TextField(blank=True, null=True),
        ),
    ]
