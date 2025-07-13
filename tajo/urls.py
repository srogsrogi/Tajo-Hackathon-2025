"""
URL configuration for tajo project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('main.urls')),  # 메인 페이지 url 연결
    path('call/', include('call.urls')),  # call url 연결
    path('faq/', include('faq.urls')),  # faq url 연결
    path('guide/', include('guide.urls')),  # guide url 연결
    path('kakao/', include('kakao.urls')),  # kakao url 연결
    path('mypage/', include('mypage.urls')),  # mypage url 연결
    path('dashboard/', include('dashboard.urls')),  # dashboard url 연결
]

# DEBUG 모드에서 static 파일 서빙
if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATICFILES_DIRS[0])
