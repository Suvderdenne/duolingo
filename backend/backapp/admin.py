from django.contrib import admin
from .models import (
    User, Language, Lesson, LessonContent, UserProgress, ContentType, Quiz, QuizChoice
)
from django.utils.html import format_html
import base64

class QuizChoiceInline(admin.TabularInline):  # эсвэл admin.StackedInline гэж бас болно
    model = QuizChoice
    extra = 1  # Нэмэлт хоосон мөр үзүүлэх

@admin.register(Quiz)
class QuizAdmin(admin.ModelAdmin):
    list_display = ('id', 'lesson', 'content_type', 'question_text', 'order')
    list_filter = ('lesson', 'content_type')
    search_fields = ('question_text',)
    ordering = ('lesson', 'order')
    inlines = [QuizChoiceInline]  # Quiz дотроо QuizChoice-уудыг харуулах

@admin.register(QuizChoice)
class QuizChoiceAdmin(admin.ModelAdmin):
    list_display = ('id', 'quiz', 'text', 'is_correct')
    list_filter = ('is_correct', 'quiz')
    search_fields = ('text',)
@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('username', 'full_name', 'email', 'score')
    search_fields = ('username', 'full_name')
    list_filter = ('is_staff', 'is_superuser')

@admin.register(Language)
class LanguageAdmin(admin.ModelAdmin):
    list_display = ('name', 'code', 'flag_image', 'flag_base64')  # flag_image-г харуулна
    search_fields = ('name', 'code')

    def flag_image(self, obj):
        """Admin талбар дээр тугны зургийг үзүүлэх"""
        if obj.flag:
            return format_html('<img src="{}" width="50" height="50" />', obj.flag.url)
        return 'No image'
    flag_image.short_description = 'Flag Image'  # Admin дээр гарч ирэх баганын нэр

@admin.register(Lesson)
class LessonAdmin(admin.ModelAdmin):
    list_display = ('title', 'language', 'level', 'order', 'thumbnail_preview')
    list_filter = ('language', 'level')
    search_fields = ('title',)

    def thumbnail_preview(self, obj):
        """Admin дээрх хичээлийн бяцхан зураг харах"""
        if obj.thumbnail:
            return format_html('<img src="{}" width="50" height="50" />', obj.thumbnail.url)
        return "No Thumbnail"
    
    thumbnail_preview.short_description = 'Thumbnail Preview'

@admin.register(LessonContent)
class LessonContentAdmin(admin.ModelAdmin):
    list_display = ('lesson', 'order', 'text', 'get_image_base64', 'get_audio_base64')
    list_filter = ('lesson',)  # content_type хасагдсан
    search_fields = ('text',)

    def get_image_base64(self, obj):
        """Конверт Image-ийн контентыг Base64 форматанд"""
        if obj.image:
            try:
                with open(obj.image.path, 'rb') as img_file:
                    img_data = img_file.read()
                    return base64.b64encode(img_data).decode('utf-8')
            except FileNotFoundError:
                return "Image not found"
        return None
    get_image_base64.short_description = 'Image Base64'

    def get_audio_base64(self, obj):
        """Конверт Audio-ийн контентыг Base64 форматанд"""
        if obj.audio:
            try:
                with open(obj.audio.path, 'rb') as audio_file:
                    audio_data = audio_file.read()
                    return base64.b64encode(audio_data).decode('utf-8')
            except FileNotFoundError:
                return "Audio not found"
        return None
    get_audio_base64.short_description = 'Audio Base64'

@admin.register(ContentType)
class ContentTypeAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'description', 'language')  # language нэмэгдсэн
    search_fields = ('name', 'description')
    ordering = ('name',)
    list_filter = ('language',)  # Хайлт шүүлтэд хэлээр шүүх боломжтой

@admin.register(UserProgress)
class UserProgressAdmin(admin.ModelAdmin):
    list_display = ('user', 'lesson', 'is_completed', 'score', 'last_accessed')
    list_filter = ('is_completed', 'lesson')
    search_fields = ('user__username',)  


