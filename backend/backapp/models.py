from django.db import models
from django.contrib.auth.models import AbstractUser
import base64
import os
class User(AbstractUser):
    full_name = models.CharField(max_length=100)
    profile_picture = models.ImageField(upload_to='profiles/', null=True, blank=True)
    score = models.IntegerField(default=0)

class Language(models.Model):
    name = models.CharField(max_length=100)
    code = models.CharField(max_length=10)
    flag = models.ImageField(upload_to='flags/')
    flag_base64 = models.TextField(blank=True, null=True)

    def __str__(self):
        return self.name

    def save(self, *args, **kwargs):
        super(Language, self).save(*args, **kwargs)  # эхлээд файл хадгалагдах ёстой

        if self.flag and not self.flag_base64:
            with open(self.flag.path, "rb") as image_file:
                encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
                self.flag_base64 = encoded_string
                super(Language, self).save(update_fields=['flag_base64'])

class Lesson(models.Model):
    language = models.ForeignKey(Language, on_delete=models.CASCADE, related_name='lessons')
    content_type = models.ForeignKey('ContentType', on_delete=models.SET_NULL, null=True, blank=True, related_name='lessons')
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    thumbnail = models.ImageField(upload_to='lesson_thumbs/', null=True, blank=True)
    level = models.CharField(max_length=20, choices=[
        ('beginner', 'Beginner'),
        ('intermediate', 'Intermediate'),
        ('advanced', 'Advanced')
    ])
    order = models.PositiveIntegerField(default=0)

    def thumbnail_base64(self):
        if self.thumbnail and os.path.isfile(self.thumbnail.path):
            with open(self.thumbnail.path, 'rb') as img_file:
                return base64.b64encode(img_file.read()).decode('utf-8')
        return None

    def audio_base64(self):
        if hasattr(self, 'audio') and self.audio and os.path.isfile(self.audio.path):
            with open(self.audio.path, 'rb') as audio_file:
                return base64.b64encode(audio_file.read()).decode('utf-8')
        return None

    def __str__(self):
        return self.title


class LessonContent(models.Model):
    lesson = models.ForeignKey('Lesson', on_delete=models.CASCADE, related_name='contents')
    text = models.TextField(blank=True)
    image = models.ImageField(upload_to='lesson_images/', null=True, blank=True)
    audio = models.FileField(upload_to='lesson_audio/', null=True, blank=True)
    order = models.PositiveIntegerField()

    def image_base64(self):
        if self.image and os.path.isfile(self.image.path):
            with open(self.image.path, 'rb') as img_file:
                return base64.b64encode(img_file.read()).decode('utf-8')
        return None

    def __str__(self):
        return f"{self.lesson.title} - Content {self.order}"


    
class ContentType(models.Model):
    name = models.CharField(max_length=50)
    description = models.TextField(blank=True, null=True)
    language = models.ForeignKey('Language', on_delete=models.CASCADE, null=True, blank=True)

    def __str__(self):
        return self.name

class UserProgress(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='progress')
    lesson = models.ForeignKey(Lesson, on_delete=models.CASCADE)
    is_completed = models.BooleanField(default=False)
    score = models.IntegerField(default=0)
    last_accessed = models.DateTimeField(auto_now=True)

class Quiz(models.Model):
    lesson = models.ForeignKey(Lesson, on_delete=models.CASCADE, related_name='quizzes')
    content_type = models.ForeignKey('ContentType', on_delete=models.SET_NULL, null=True, blank=True, related_name='quizzes')
    question_text = models.CharField(max_length=500)
    audio = models.FileField(upload_to='quiz_audio/', null=True, blank=True)
    image = models.ImageField(upload_to='quiz_images/', null=True, blank=True)
    order = models.PositiveIntegerField(default=0)

    def image_base64(self):
        if self.image and os.path.isfile(self.image.path):
            with open(self.image.path, 'rb') as img_file:
                return base64.b64encode(img_file.read()).decode('utf-8')
        return None

    def audio_base64(self):
        if self.audio and os.path.isfile(self.audio.path):
            with open(self.audio.path, 'rb') as audio_file:
                return base64.b64encode(audio_file.read()).decode('utf-8')
        return None

    def __str__(self):
        return f"{self.lesson.title} - Question {self.order}"



class QuizChoice(models.Model):
    quiz = models.ForeignKey(Quiz, on_delete=models.CASCADE, related_name='choices')
    text = models.CharField(max_length=255)
    is_correct = models.BooleanField(default=False)
    image = models.ImageField(upload_to='choice_images/', null=True, blank=True)
    audio = models.FileField(upload_to='choice_audio/', null=True, blank=True)

    def image_base64(self):
        if self.image and os.path.isfile(self.image.path):
            with open(self.image.path, 'rb') as img_file:
                return base64.b64encode(img_file.read()).decode('utf-8')
        return None

    def audio_base64(self):
        if self.audio and os.path.isfile(self.audio.path):
            with open(self.audio.path, 'rb') as audio_file:
                return base64.b64encode(audio_file.read()).decode('utf-8')
        return None

    def __str__(self):
        return f"Choice for {self.quiz.question_text[:30]}"
