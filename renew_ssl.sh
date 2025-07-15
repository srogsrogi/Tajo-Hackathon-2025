#!/bin/bash

echo "=== SSL 인증서 갱신 시작 ==="

# 인증서 갱신
certbot renew --webroot --webroot-path=/var/www/certbot

if [ $? -eq 0 ]; then
    echo "인증서 갱신 완료!"
    
    # nginx 재시작
    echo "nginx 재시작..."
    service nginx restart
    
    echo "SSL 인증서 갱신 완료!"
else
    echo "인증서 갱신 실패. 로그를 확인하세요."
fi

echo "=== SSL 인증서 갱신 완료 ==="