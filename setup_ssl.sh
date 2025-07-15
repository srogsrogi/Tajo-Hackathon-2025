#!/bin/bash

echo "=== Let's Encrypt SSL 인증서 발급 시작 ==="

# 도메인 설정
DOMAIN="taewojo.site"
EMAIL="your-email@example.com"  # 실제 이메일 주소로 변경하세요

# certbot을 사용해 인증서 발급
echo "1. SSL 인증서 발급 중..."
certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    --domains $DOMAIN,www.$DOMAIN

if [ $? -eq 0 ]; then
    echo "2. 인증서 발급 완료!"
    
    # nginx 설정을 SSL 버전으로 변경
    echo "3. nginx 설정을 HTTPS 버전으로 업데이트..."
    cp /app/nginx-ssl.conf /etc/nginx/nginx.conf
    
    # nginx 재시작
    echo "4. nginx 재시작..."
    service nginx restart
    
    echo "5. SSL 설정 완료!"
    echo "   - https://$DOMAIN 으로 접속 가능합니다"
    echo "   - 인증서는 90일마다 갱신이 필요합니다"
    
else
    echo "인증서 발급 실패. 다음을 확인하세요:"
    echo "1. 도메인이 올바르게 설정되었는지 확인"
    echo "2. 80번 포트로 접속이 가능한지 확인"
    echo "3. DNS 설정이 올바른지 확인"
fi

echo "=== SSL 설정 완료 ==="