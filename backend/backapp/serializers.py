from rest_framework import serializers
from .models import *
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'full_name', 'profile_picture', 'score']


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'password', 'full_name']

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            full_name=validated_data.get('full_name', ''),
            password=validated_data['password']
        )
        return user


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        data = super().validate(attrs)
        data.update({
            'user_id': self.user.id,
            'username': self.user.username,
            'full_name': self.user.full_name,
            'email': self.user.email,
            'score': self.user.score,
            'profile_picture': self.user.profile_picture.url if self.user.profile_picture else None,
        })
        return data


class LanguageSerializer(serializers.ModelSerializer):
    flag_base64 = serializers.SerializerMethodField()

    class Meta:
        model = Language
        fields = '__all__'

    def get_flag_base64(self, obj):
        if obj.flag:
            with open(obj.flag.path, "rb") as image_file:
                encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
            return encoded_string
        return None

class LessonContentSerializer(serializers.ModelSerializer):
    image_base64 = serializers.SerializerMethodField()
    audio_base64 = serializers.SerializerMethodField()
    # content_type хассан

    class Meta:
        model = LessonContent
        fields = '__all__'

    def get_image_base64(self, obj):
        if obj.image and hasattr(obj.image, 'path'):
            with open(obj.image.path, 'rb') as image_file:
                return base64.b64encode(image_file.read()).decode('utf-8')
        return None

    def get_audio_base64(self, obj):
        if obj.audio and hasattr(obj.audio, 'path'):
            with open(obj.audio.path, 'rb') as audio_file:
                return base64.b64encode(audio_file.read()).decode('utf-8')
        return None

    
class LessonSerializer(serializers.ModelSerializer):
    contents = LessonContentSerializer(many=True, read_only=True)
    thumbnail_base64 = serializers.SerializerMethodField()

    class Meta:
        model = Lesson
        fields = ['id', 'title', 'description', 'contents', 'thumbnail_base64']

    def get_thumbnail_base64(self, obj):
        # Make sure this function gets the actual base64 image data
        return obj.thumbnail_base64()  # Or however you get the base64 data

class ContentTypeSerializer(serializers.ModelSerializer):
    lessons = LessonSerializer(many=True, read_only=True)  # Nested lessons in content type
    language = serializers.PrimaryKeyRelatedField(queryset=Language.objects.all())  # Reference to language
    language_name = serializers.CharField(source='language.name', read_only=True)  # Read-only field for language name

    class Meta:
        model = ContentType
        fields = ['id', 'name', 'description', 'language', 'language_name', 'lessons']


class QuizChoiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = QuizChoice
        fields = '__all__'

class QuizSerializer(serializers.ModelSerializer):
    choices = QuizChoiceSerializer(many=True, read_only=True)
    audio_base64 = serializers.SerializerMethodField()

    class Meta:
        model = Quiz
        fields = '__all__'

    def get_audio_base64(self, obj):
        return obj.audio_base64()  # `audio_base64` method-ийг ашиглана

class UserProgressSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProgress
        fields = '__all__'
