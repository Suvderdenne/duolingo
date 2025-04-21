from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    RegisterView, CustomLoginView,
    LanguageAPIView, LessonAPIView, 
    LessonContentAPIView, QuizAPIView, 
    QuizChoiceAPIView, UserProgressAPIView, ContentTypeListAPIView, ContentTypeWithLessonsAPIView
)


urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', CustomLoginView.as_view(), name='login'),
    path('languages/', LanguageAPIView.as_view(), name='language-list'),
    # path('lessons/', LessonAPIView.as_view(), name='lesson-list'),
    path('lessons/<int:content_type_id>/', LessonAPIView.as_view(), name='lesson-list-by-content-type'),

    # path('lessons/<int:language_id>/', LessonAPIView.as_view(), name='lesson-list-by-language'),
    path('lesson-content/<int:lesson_id>/', LessonContentAPIView.as_view(), name='lesson_content_by_lesson_id'),
    path('content-types/<int:language_id>/', ContentTypeListAPIView.as_view(), name='content-type-list'),
    path('content-types/<int:lesson_id>/', ContentTypeListAPIView.as_view(), name='content-type-list'),
    path('quizzes/', QuizAPIView.as_view(), name='quiz-list'),
    path('quiz-choices/', QuizChoiceAPIView.as_view(), name='quiz-choice-list'),
    path('user-progress/', UserProgressAPIView.as_view(), name='user-progress-list'),
    path('content-types-with-lessons/<int:language_id>/', ContentTypeWithLessonsAPIView.as_view(), name='content-type-with-lessons'),
]


