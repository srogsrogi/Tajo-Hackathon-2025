#!/bin/bash

echo "=== CI/CD 환경용 SSL 자동 설정 시작 ==="

# 환경 변수 설정
DOMAIN="${DOMAIN:-taewojo.site}"
EMAIL="${LETSENCRYPT_EMAIL:-your-email@example.com}"
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"

# SSL 모드 확인 (환경 변수로 제어)
SSL_MODE="${SSL_MODE:-auto}"

echo "설정 정보:"
echo "  - 도메인: $DOMAIN"
echo "  - 이메일: $EMAIL"
echo "  - SSL 모드: $SSL_MODE"

# 1. 인증서 존재 여부 확인
if [ -f "$CERT_PATH/fullchain.pem" ]; then
    echo "✅ 기존 SSL 인증서 발견"
    USE_SSL=true
else
    echo "❌ SSL 인증서 없음"
    USE_SSL=false
fi

# 2. SSL 모드에 따른 설정
case $SSL_MODE in
    "force")
        echo "🔒 강제 SSL 모드: HTTPS만 사용"
        USE_SSL=true
        ;;
    "disable")
        echo "🔓 SSL 비활성화 모드: HTTP만 사용"
        USE_SSL=false
        ;;
    "auto")
        echo "🔄 자동 모드: 인증서 상태에 따라 결정"
        # USE_SSL은 이미 위에서 설정됨
        ;;
esac

# 3. nginx 설정 적용
if [ "$USE_SSL" = true ] && [ -f "$CERT_PATH/fullchain.pem" ]; then
    echo "🔒 HTTPS 설정 적용 중..."
    cp /app/nginx-ssl.conf /etc/nginx/nginx.conf
    
    # nginx 설정 테스트
    if nginx -t; then
        echo "✅ nginx HTTPS 설정 검증 완료"
    else
        echo "❌ nginx HTTPS 설정 오류. HTTP 모드로 fallback"
        USE_SSL=false
    fi
fi

if [ "$USE_SSL" = false ]; then
    echo "🔓 HTTP 설정 적용 중..."
    cat > /etc/nginx/nginx.conf << 'EOF'
worker_processes 1;
events { worker_connections 1024; }
http {
    include mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;
    
    server {
        listen 80;
        server_name taewojo.site www.taewojo.site;
        charset utf-8;
        
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }
        
        location /static/ {
            alias /app/staticfiles/;
            expires 30d;
            add_header Cache-Control "public";
        }
        
        location / {
            proxy_pass http://127.0.0.1:8000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF
fi

# 4. nginx 시작
echo "🚀 nginx 시작 중..."
service nginx start

# 5. Gunicorn 시작
echo "🐍 Django 애플리케이션 시작 중..."
gunicorn tajo.wsgi:application --bind 0.0.0.0:8000 &

# 6. SSL 인증서 자동 발급 (필요한 경우)
if [ "$SSL_MODE" = "auto" ] && [ "$USE_SSL" = false ]; then
    echo "🔄 SSL 인증서 자동 발급 시도..."
    sleep 5  # 서버 시작 대기
    
    certbot certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email $EMAIL \
        --agree-tos \
        --no-eff-email \
        --domains $DOMAIN,www.$DOMAIN \
        --non-interactive
    
    if [ $? -eq 0 ]; then
        echo "✅ 인증서 발급 완료! HTTPS 설정으로 전환..."
        cp /app/nginx-ssl.conf /etc/nginx/nginx.conf
        service nginx restart
        echo "🔒 HTTPS 활성화 완료"
    else
        echo "❌ 인증서 발급 실패. HTTP 모드로 계속 진행"
    fi
fi

echo "=== CI/CD 환경용 SSL 설정 완료 ==="

# 7. 로그 출력 (포그라운드 유지)
tail -f /var/log/nginx/access.log /var/log/nginx/error.log