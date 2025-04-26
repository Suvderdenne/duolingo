from django.shortcuts import render
from rest_framework import viewsets, permissions
from .models import Language, Lesson, LessonContent, UserProgress, ContentType, Quiz, QuizChoice
# Create your views here.
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import generics
from django.contrib.auth import get_user_model
from .serializers import RegisterSerializer, CustomTokenObtainPairSerializer, LanguageSerializer, LessonSerializer, LessonContentSerializer, UserProgressSerializer, ContentTypeSerializer, QuizSerializer, QuizChoiceSerializer
from rest_framework.permissions import AllowAny
from rest_framework_simplejwt.views import TokenObtainPairView
from django.shortcuts import get_object_or_404

User = get_user_model()

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = [AllowAny]
    serializer_class = RegisterSerializer


class CustomLoginView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer


# Language APIView
class LanguageAPIView(generics.ListCreateAPIView):
    queryset = Language.objects.all()
    serializer_class = LanguageSerializer
    permission_classes = [permissions.AllowAny]


# ✅ Lesson APIView
class LessonAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, content_type_id=None):
        if content_type_id:
            lessons = Lesson.objects.filter(content_type__id=content_type_id).order_by('order')
        else:
            lessons = Lesson.objects.none()

        serializer = LessonSerializer(lessons, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = LessonSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)




# ✅ LessonContent APIView
class LessonContentAPIView(APIView):
    def get(self, request, lesson_id):
        lesson_contents = LessonContent.objects.filter(lesson_id=lesson_id)

        if not lesson_contents.exists():
            return Response({'detail': 'Not found'}, status=status.HTTP_404_NOT_FOUND)

        serializer = LessonContentSerializer(lesson_contents, many=True)
        return Response(serializer.data)


# ❌ ContentType-тай холбоотой API-уудыг устгасан
# class ContentTypeListAPIView(APIView): ❌
# class ContentTypeLessonAPIView(APIView): ❌

# Хэрвээ ContentType model өөр зорилгоор хэрэглэгдэж байгаа бол
# ContentTypeListAPIView-ийг үлдээж болно:

class ContentTypeListAPIView(generics.ListAPIView):
    queryset = ContentType.objects.all()
    serializer_class = ContentTypeSerializer
    permission_classes = [permissions.AllowAny]


class ContentTypeWithLessonsAPIView(APIView):
    def get(self, request, language_id):
        content_types = ContentType.objects.filter(language_id=language_id)
        data = []
        for content_type in content_types:
            lessons = Lesson.objects.filter(content_type=content_type)
            lesson_data = [
                {
                    'id': lesson.id,
                    'title': lesson.title,
                    'thumbnail_base64': lesson.thumbnail_base64(),
                    'content_type_name': content_type.name,
                }
                for lesson in lessons
            ]
            data.append({
                'content_type_id': content_type.id,
                'content_type_name': content_type.name,
                'lessons': lesson_data
            })
        return Response(data)
# Quiz APIView
# class QuizAPIView(APIView):
#     permission_classes = [permissions.AllowAny]

#     def get(self, request):
#         quizzes = Quiz.objects.all()
#         serializer = QuizSerializer(quizzes, many=True)
#         return Response(serializer.data)

#     def post(self, request):
#         serializer = QuizSerializer(data=request.data)
#         if serializer.is_valid():
#             serializer.save()
#             return Response(serializer.data, status=status.HTTP_201_CREATED)
#         return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# Add this to your QuizAPIView
class QuizByContentTypeAPIView(APIView):
    def get(self, request, content_type_id):
        quizzes = Quiz.objects.filter(content_type_id=content_type_id).order_by('order')

        data = []
        for quiz in quizzes:
            choices = []
            for choice in quiz.choices.all():
                choices.append({
                    'id': choice.id,
                    'text': choice.text,
                    'is_correct': choice.is_correct,
                    'image_base64': choice.image_base64(),
                    'audio_base64': choice.audio_base64(),
                })

            data.append({
                'id': quiz.id,
                'question_text': quiz.question_text,
                'image_base64': quiz.image_base64(),
                'audio_base64': quiz.audio_base64(),
                'order': quiz.order,
                'choices': choices,
            })

        return Response(data, status=status.HTTP_200_OK)

class QuizChoicesAPIView(APIView):
    def get(self, request, quiz_id):
        quiz = get_object_or_404(Quiz, id=quiz_id)
        choices = quiz.choices.all()

        data = []
        for choice in choices:
            data.append({
                'id': choice.id,
                'text': choice.text,
                'is_correct': choice.is_correct,
                'image_base64': choice.image_base64(),
                'audio_base64': choice.audio_base64(),
            })

        return Response(data, status=status.HTTP_200_OK)



# UserProgress APIView
class UserProgressAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        progress = UserProgress.objects.filter(user=request.user)
        serializer = UserProgressSerializer(progress, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = UserProgressSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)