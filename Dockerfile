FROM python:3.12

LABEL authors="yejin99"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

COPY . .

# nginx 및 certbot 설치 (SSL 지원)
RUN apt-get update && apt-get install -y \
    nginx \
    certbot \
    python3-certbot-nginx \
    && rm -rf /var/lib/apt/lists/*

# certbot을 위한 디렉토리 생성
RUN mkdir -p /var/www/certbot

# nginx 설정 파일 복사 (SSL 설정 버전)
COPY nginx-ssl.conf /etc/nginx/nginx-ssl.conf

# 환경 변수 설정 (기본값)
ENV DOMAIN=taewojo.site
ENV LETSENCRYPT_EMAIL=your-email@example.com
ENV SSL_MODE=auto

# 80, 443 포트 모두 노출
EXPOSE 80 443

# entrypoint 스크립트 복사 및 실행 권한 부여
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 컨테이너 실행 시 entrypoint.sh 실행
CMD ["/entrypoint.sh"]
