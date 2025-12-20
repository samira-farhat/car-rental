# this file defines the user model for authentication and registration, we used the accounts app in django to do so, and added needed features
# it matches our MySQL User table, with password hashing and user roles

from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.utils import timezone
from django.core.validators import FileExtensionValidator

# custom user manager
# handles creating normal users and superusers
class UserManager(BaseUserManager):
    
    # creates and saves regular users with the given email and password
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('Email is required')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields) # creates an instance of user
        user.set_password(password) # hashes the password
        user.save(using=self._db) # and saves user to db
        return user

    # creates and saves a superuser (admin) with all permisions
    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        return self.create_user(email, password, **extra_fields)

# custom user model
# custom user model for car rental system, the fields include first, middle, last name, phone, email, role
# it inherits from AbstractBaseUser for password management and from PermissionMixin for groups & permissions
class User(AbstractBaseUser, PermissionsMixin):
    # db User table fields that we need
    first_name = models.CharField(max_length=50)
    middle_name = models.CharField(max_length=50, blank=True, null=True)
    last_name = models.CharField(max_length=50)
    age = models.IntegerField(blank=True, null=True)
    address = models.CharField(max_length=255, blank=True, null=True)
    phone = models.CharField(max_length=20, unique=True)
    email = models.EmailField(unique=True)
    role = models.CharField(max_length=10, choices=[('admin','admin'),('manager','manager'),('customer','customer')], default='customer')
    created_at = models.DateTimeField(auto_now_add=True)

    # extra django fields for the accounts app
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)  

    # fix for groups/user_permissions clash
    groups = models.ManyToManyField(
        'auth.Group',
        related_name='custom_user_set',
        blank=True,
        help_text='The groups this user belongs to.'
    )
    user_permissions = models.ManyToManyField(
        'auth.Permission',
        related_name='custom_user_set',
        blank=True,
        help_text='Specific permissions for this user.'
    )

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['first_name', 'last_name', 'phone']

    def __str__(self):
        return self.email



# stores user uploaded documents such as drivers license
# each document is linked to a user
class Documentation(models.Model):
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='documents')
    document_type = models.CharField(max_length=50, default='Driver License')
    document_image = models.FileField(
        upload_to='documents/',
        validators=[
            FileExtensionValidator(
                allowed_extensions=['pdf', 'jpg', 'png', 'jpeg'] # allowed extensions that are the same in frontend
            )
        ]
    )  # uploaded images go to media/documents/

    status = models.CharField(
        max_length=20,
        choices=[('pending', 'pending'), ('verified', 'verified'), ('rejected', 'rejected')],
        default='pending'
    )

    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.email} - {self.document_type}"
