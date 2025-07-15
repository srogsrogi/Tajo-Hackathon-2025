# Let's Encrypt SSL 인증서 설정 가이드

## 개요

네, 맞습니다! 코드를 그대로 두고 EC2에서 Let's Encrypt를 통해 SSL 인증서를 발급받고 nginx 설정을 수정하면 HTTPS가 작동합니다.

## 단계별 설정 방법

### 1. 파일 준비

다음 파일들이 준비되어 있습니다:
- `Dockerfile-ssl`: SSL 지원 Docker 이미지 빌드용
- `nginx-ssl.conf`: HTTPS 지원 nginx 설정
- `entrypoint-ssl.sh`: SSL 인증서 확인 및 nginx 시작 스크립트
- `setup_ssl.sh`: Let's Encrypt 인증서 발급 스크립트
- `renew_ssl.sh`: 인증서 갱신 스크립트
- `Dockerrun-ssl.aws.json`: AWS 배포 설정 (443 포트 포함)

### 2. 사전 준비사항

#### A. AWS 보안 그룹 설정
EC2 보안 그룹에서 다음 포트를 열어야 합니다:
- **포트 80 (HTTP)**: 0.0.0.0/0
- **포트 443 (HTTPS)**: 0.0.0.0/0

#### B. 도메인 DNS 설정 확인
- `taewojo.site` A 레코드가 EC2 IP를 가리키는지 확인
- `www.taewojo.site` CNAME 레코드가 `taewojo.site`를 가리키는지 확인

### 3. 배포 및 인증서 발급

#### 방법 1: 기존 코드 수정

```bash
# 1. 기존 Dockerfile을 SSL 버전으로 교체
cp Dockerfile-ssl Dockerfile

# 2. 기존 Dockerrun.aws.json을 SSL 버전으로 교체
cp Dockerrun-ssl.aws.json Dockerrun.aws.json

# 3. setup_ssl.sh에서 이메일 주소 변경
# EMAIL="your-email@example.com"을 실제 이메일로 변경

# 4. Docker 이미지 빌드 및 푸시
docker build -t yejin99/tajo-web:ssl-latest .
docker push yejin99/tajo-web:ssl-latest

# 5. AWS Elastic Beanstalk에 배포
```

#### 방법 2: EC2에 직접 접속하여 설정

```bash
# 1. EC2 인스턴스에 SSH 접속
ssh -i your-key.pem ec2-user@your-ec2-ip

# 2. 실행 중인 Docker 컨테이너에 접속
docker exec -it $(docker ps -q) /bin/bash

# 3. 인증서 발급 스크립트 실행
/setup_ssl.sh

# 스크립트가 완료되면 자동으로 HTTPS가 활성화됩니다
```

### 4. 인증서 발급 과정

```bash
# 컨테이너 내에서 실행
root@container:/app# ./setup_ssl.sh

# 출력 예시:
# === Let's Encrypt SSL 인증서 발급 시작 ===
# 1. SSL 인증서 발급 중...
# 2. 인증서 발급 완료!
# 3. nginx 설정을 HTTPS 버전으로 업데이트...
# 4. nginx 재시작...
# 5. SSL 설정 완료!
#    - https://taewojo.site 으로 접속 가능합니다
```

### 5. 설정 완료 후 테스트

```bash
# HTTP 접속 (HTTPS로 리다이렉트됨)
curl -I http://taewojo.site

# HTTPS 접속 (정상 응답)
curl -I https://taewojo.site

# SSL 인증서 확인
openssl s_client -connect taewojo.site:443 -servername taewojo.site
```

### 6. 인증서 갱신 (90일마다 필요)

```bash
# 컨테이너 내에서 실행
./renew_ssl.sh

# 또는 cron job으로 자동 갱신 설정
# crontab -e
# 0 12 * * * /path/to/renew_ssl.sh
```

## 주의사항

### 1. 이메일 주소 변경 필수
`setup_ssl.sh` 파일에서 이메일 주소를 실제 이메일로 변경해야 합니다:
```bash
EMAIL="your-email@example.com"  # 실제 이메일 주소로 변경
```

### 2. 포트 443 개방 확인
AWS 보안 그룹에서 포트 443이 열려있는지 확인하세요.

### 3. 도메인 검증
Let's Encrypt는 도메인 소유권을 확인하므로, 도메인이 올바르게 EC2를 가리켜야 합니다.

### 4. 인증서 지속성
인증서는 호스트의 `/etc/letsencrypt` 디렉토리에 저장되므로, 컨테이너가 재시작되어도 유지됩니다.

## 문제 해결

### 인증서 발급 실패 시
```bash
# 1. 도메인 접속 확인
curl -I http://taewojo.site

# 2. DNS 설정 확인
nslookup taewojo.site

# 3. 80번 포트 접근 확인
telnet taewojo.site 80
```

### nginx 설정 오류 시
```bash
# nginx 설정 문법 확인
nginx -t

# nginx 로그 확인
tail -f /var/log/nginx/error.log
```

## 장점

1. **무료**: Let's Encrypt는 무료 SSL 인증서
2. **자동화**: 스크립트로 간편하게 설정
3. **갱신 가능**: 90일마다 자동 갱신 가능
4. **표준 보안**: 브라우저에서 신뢰하는 인증서

## 결론

이 방법으로 설정하면 코드 변경 없이 HTTPS를 사용할 수 있습니다. AWS Application Load Balancer보다 더 직접적인 제어가 가능하며, 비용도 절약할 수 있습니다.