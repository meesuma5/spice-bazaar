from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import Users

class CustomUserAdmin(UserAdmin):
    # Specify the fields to display in the admin panel for users
    model = Users
    list_display = ('id', 'email', 'username', 'is_active', 'is_staff', 'reg_date')
    list_filter = ('is_active', 'is_staff', 'reg_date')
    search_fields = ('email', 'username', 'id')
    ordering = ('reg_date',)
    
    # Specify the fields for the user details page
    fieldsets = (
        (None, {'fields': ('email', 'username', 'password')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important Dates', {'fields': ('last_login', 'reg_date')}),
    )
    
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'username', 'password1', 'password2', 'is_active', 'is_staff')}
        ),
    )
    
    # Define the form that will be used for creating a new user
    def save_model(self, request, obj, form, change): # override 
        if not change:
            obj.set_password(obj.password)
        obj.save()

# Register the custom user model with the admin
admin.site.register(Users, CustomUserAdmin)
