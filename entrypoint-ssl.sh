#!/bin/bash

# SSL 인증서 경로
CERT_PATH="/etc/letsencrypt/live/taewojo.site"

# 인증서가 존재하는지 확인
if [ ! -f "$CERT_PATH/fullchain.pem" ]; then
    echo "SSL 인증서가 없습니다. 기본 nginx 설정으로 시작합니다."
    
    # HTTP만 지원하는 임시 nginx 설정
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
    
    echo "인증서 발급 후 /setup_ssl.sh 스크립트를 실행하세요."
else
    echo "SSL 인증서가 있습니다. HTTPS 설정으로 시작합니다."
    # nginx-ssl.conf 파일을 사용 (이미 복사됨)
fi

# Nginx 시작
service nginx start

# Gunicorn 시작
gunicorn tajo.wsgi:application --bind 0.0.0.0:8000