#!/bin/bash

echo "=== 🚀 Django App with Auto SSL 시작 ==="

# 환경 변수 설정 (기본값 적용)
DOMAIN="${DOMAIN:-taewojo.site}"
EMAIL="${LETSENCRYPT_EMAIL:-your-email@example.com}"
SSL_MODE="${SSL_MODE:-auto}"
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"

echo "📋 설정 정보:"
echo "  - 도메인: $DOMAIN"
echo "  - 이메일: $EMAIL"
echo "  - SSL 모드: $SSL_MODE"

# 1. SSL 인증서 존재 여부 확인
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
        ;;
esac

# 3. nginx 설정 적용
if [ "$USE_SSL" = true ] && [ -f "$CERT_PATH/fullchain.pem" ]; then
    echo "🔒 HTTPS 설정 적용 중..."
    
    # SSL 설정 파일 복사
    cp /etc/nginx/nginx-ssl.conf /etc/nginx/nginx.conf
    
    # nginx 설정 테스트
    if nginx -t; then
        echo "✅ nginx HTTPS 설정 검증 완료"
    else
        echo "❌ nginx HTTPS 설정 오류. HTTP 모드로 fallback"
        USE_SSL=false
    fi
fi

# 4. HTTP 모드 설정 (SSL 실패 시 또는 인증서 없을 때)
if [ "$USE_SSL" = false ]; then
    echo "🔓 HTTP 설정 적용 중..."
    
    cat > /etc/nginx/nginx.conf << 'EOF'
worker_processes 1;

events { 
    worker_connections 1024; 
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    server {
        listen 80;
        server_name taewojo.site www.taewojo.site;
        charset utf-8;

        # Let's Encrypt 인증서 발급을 위한 경로
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        # 정적 파일 라우팅
        location /static/ {
            alias /app/staticfiles/;
            expires 30d;
            add_header Cache-Control "public";
        }

        # 모든 요청을 Django(Gunicorn)으로 프록시
        location / {
            proxy_pass http://127.0.0.1:8000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $server_name;
        }
    }
}
EOF
fi

# 5. Nginx 시작
echo "🚀 nginx 시작 중..."
service nginx start

# 6. Gunicorn 시작 (백그라운드)
echo "🐍 Django 애플리케이션 시작 중..."
gunicorn tajo.wsgi:application --bind 0.0.0.0:8000 &

# 7. SSL 인증서 자동 발급 (필요한 경우)
if [ "$SSL_MODE" = "auto" ] && [ "$USE_SSL" = false ]; then
    echo "🔄 SSL 인증서 자동 발급 시도 중..."
    sleep 5  # 서버 시작 대기
    
    # 인증서 발급 시도
    certbot certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email $EMAIL \
        --agree-tos \
        --no-eff-email \
        --domains $DOMAIN,www.$DOMAIN \
        --non-interactive \
        --keep-until-expiring \
        --expand
    
    if [ $? -eq 0 ]; then
        echo "✅ 인증서 발급 완료! HTTPS 설정으로 전환..."
        
        # SSL 설정으로 전환
        cp /etc/nginx/nginx-ssl.conf /etc/nginx/nginx.conf
        
        # nginx 재시작
        service nginx restart
        
        echo "🔒 HTTPS 활성화 완료!"
        echo "   - https://$DOMAIN 으로 접속 가능"
    else
        echo "❌ 인증서 발급 실패. HTTP 모드로 계속 진행"
        echo "   - 도메인 DNS 설정을 확인하세요"
        echo "   - 포트 80이 열려있는지 확인하세요"
    fi
fi

echo "=== ✅ 애플리케이션 시작 완료 ==="
echo "   - HTTP: http://$DOMAIN"
if [ -f "$CERT_PATH/fullchain.pem" ]; then
    echo "   - HTTPS: https://$DOMAIN"
fi

# 8. 로그 출력 (포그라운드 유지)
tail -f /var/log/nginx/access.log /var/log/nginx/error.log
