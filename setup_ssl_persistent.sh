#!/bin/bash

echo "=== CI/CD 환경에서 SSL 설정 유지 가능한 스크립트 ==="

# 도메인 설정
DOMAIN="taewojo.site"
EMAIL="your-email@example.com"  # 실제 이메일 주소로 변경하세요

# 인증서 경로
CERT_PATH="/etc/letsencrypt/live/$DOMAIN"
HOST_CERT_PATH="/host/etc/letsencrypt"

# 1. 호스트에 인증서가 있는지 확인 (볼륨 마운트를 통해)
if [ -f "$CERT_PATH/fullchain.pem" ]; then
    echo "✅ 기존 SSL 인증서 발견. HTTPS 설정으로 시작합니다."
    
    # nginx SSL 설정 적용
    cp /app/nginx-ssl.conf /etc/nginx/nginx.conf
    
    # nginx 재시작
    service nginx restart
    
    echo "🔒 HTTPS 설정 완료!"
    echo "   - https://$DOMAIN 으로 접속 가능"
    
else
    echo "❌ SSL 인증서가 없습니다. 인증서를 발급합니다."
    
    # HTTP 전용 nginx 설정 (인증서 발급용)
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
        
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
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
    
    # nginx 시작
    service nginx restart
    
    echo "🔧 HTTP 서버 시작 완료. 인증서 발급 중..."
    
    # 인증서 발급
    certbot certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email $EMAIL \
        --agree-tos \
        --no-eff-email \
        --domains $DOMAIN,www.$DOMAIN
    
    if [ $? -eq 0 ]; then
        echo "✅ 인증서 발급 완료!"
        
        # HTTPS 설정으로 변경
        cp /app/nginx-ssl.conf /etc/nginx/nginx.conf
        service nginx restart
        
        echo "🔒 HTTPS 설정 완료!"
        echo "   - https://$DOMAIN 으로 접속 가능"
        
    else
        echo "❌ 인증서 발급 실패"
        echo "   - 도메인 DNS 설정을 확인하세요"
        echo "   - 포트 80이 열려있는지 확인하세요"
    fi
fi

echo "=== SSL 설정 스크립트 완료 ==="