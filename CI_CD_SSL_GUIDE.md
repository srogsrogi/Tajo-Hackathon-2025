# CI/CD 환경에서 SSL 설정 관리 가이드

## 문제 해결 요약

### 1. DNS 설정 관련
**질문**: CNAME 설정이 필요한가요?
**답변**: ❌ **필요하지 않습니다!**

현재 DNS 설정이 이미 올바릅니다:
- `@` (taewojo.site): A 레코드 → `52.78.209.56`
- `www` (www.taewojo.site): A 레코드 → `52.78.209.56`

### 2. CI/CD 환경에서 설정 초기화 문제
**질문**: GitHub Actions로 배포할 때 nginx 설정이 초기화되지 않나요?
**답변**: ✅ **해결 방법을 제시했습니다!**

## CI/CD 환경에서 SSL 설정 유지 방법

### 방법 1: 환경 변수 기반 자동 SSL 관리 (권장)

#### 1-1. 파일 구조
```
프로젝트/
├── Dockerfile-cicd              # CI/CD용 Dockerfile
├── Dockerrun-cicd.aws.json      # CI/CD용 AWS 배포 설정
├── entrypoint-cicd.sh           # SSL 자동 관리 스크립트
├── nginx-ssl.conf               # HTTPS nginx 설정
├── .github/workflows/
│   └── docker-ssl-image.yml     # SSL 지원 워크플로우
└── .ebextensions/
    └── ssl-renewal.config       # SSL 인증서 자동 갱신
```

#### 1-2. 환경 변수 설정
AWS Elastic Beanstalk 환경 설정에서 다음을 추가:
```bash
LETSENCRYPT_EMAIL=your-email@example.com
SSL_MODE=auto  # auto, force, disable
```

#### 1-3. 배포 방법
```bash
# 1. 기존 파일 백업
cp Dockerfile Dockerfile.backup
cp Dockerrun.aws.json Dockerrun.aws.json.backup

# 2. CI/CD용 파일로 교체
cp Dockerfile-cicd Dockerfile
cp Dockerrun-cicd.aws.json Dockerrun.aws.json

# 3. GitHub Actions 워크플로우 교체
cp .github/workflows/docker-ssl-image.yml .github/workflows/docker-image.yml

# 4. Git 커밋 및 푸시
git add .
git commit -m "Add SSL support to CI/CD pipeline"
git push origin main
```

### 방법 2: 수동 SSL 설정 후 볼륨 마운트

#### 2-1. 초기 SSL 설정
```bash
# EC2에 SSH 접속
ssh -i your-key.pem ec2-user@your-ec2-ip

# 컨테이너에 접속
docker exec -it $(docker ps -q) /bin/bash

# SSL 인증서 발급
./setup_ssl_persistent.sh
```

#### 2-2. 인증서 지속성 확보
인증서는 호스트의 `/etc/letsencrypt`에 저장되므로 컨테이너 재시작 시에도 유지됩니다.

## SSL 모드 설명

### `SSL_MODE=auto` (기본값)
- 인증서가 있으면 HTTPS 사용
- 없으면 HTTP로 시작 후 자동 발급 시도
- 발급 성공 시 HTTPS로 전환

### `SSL_MODE=force`
- 항상 HTTPS 사용
- 인증서가 없으면 에러 발생

### `SSL_MODE=disable`
- 항상 HTTP 사용
- 인증서가 있어도 무시

## 자동 인증서 갱신

### cron job 설정
`.ebextensions/ssl-renewal.config`에 설정됨:
- **매일 오전 3시**: 인증서 갱신 시도
- **매주 월요일 오전 9시**: 인증서 상태 확인

### 수동 갱신
```bash
# 컨테이너 내에서 실행
./renew_ssl.sh

# 또는 직접 실행
certbot renew --webroot --webroot-path=/var/www/certbot
service nginx restart
```

## 문제 해결

### 1. 배포 후 HTTPS가 작동하지 않는 경우

```bash
# 1. 컨테이너 로그 확인
docker logs $(docker ps -q)

# 2. SSL 인증서 상태 확인
docker exec $(docker ps -q) certbot certificates

# 3. nginx 설정 확인
docker exec $(docker ps -q) nginx -t
```

### 2. 인증서 발급 실패

```bash
# 1. 도메인 접속 확인
curl -I http://taewojo.site

# 2. 80번 포트 접근 확인
telnet taewojo.site 80

# 3. DNS 설정 확인
nslookup taewojo.site
```

### 3. CI/CD 배포 실패

```bash
# 1. GitHub Actions 로그 확인
# 2. AWS Elastic Beanstalk 이벤트 확인
# 3. Docker Hub 이미지 확인
```

## 장점

### 자동화된 SSL 관리
- ✅ 인증서 자동 발급
- ✅ 자동 갱신 (90일마다)
- ✅ 설정 초기화 방지
- ✅ 환경 변수로 간편 제어

### CI/CD 통합
- ✅ GitHub Actions 완전 지원
- ✅ 설정 변경 없이 배포 가능
- ✅ 볼륨 마운트로 인증서 지속성 확보

## 실제 사용 시나리오

### 시나리오 1: 새 프로젝트 시작
1. CI/CD용 파일들 적용
2. 환경 변수 설정
3. 첫 배포 시 자동으로 SSL 인증서 발급
4. 이후 배포 시 기존 인증서 사용

### 시나리오 2: 기존 프로젝트 업그레이드
1. 기존 파일 백업
2. SSL 지원 파일들 적용
3. 점진적 마이그레이션
4. 테스트 후 완전 전환

## 결론

이 방법으로 **CI/CD 환경에서도 SSL 설정이 초기화되지 않고 자동으로 관리**됩니다.

핵심 해결책:
1. **볼륨 마운트**: 인증서 지속성 확보
2. **환경 변수**: 설정 분리 및 자동화
3. **자동 갱신**: cron job으로 관리
4. **fallback 로직**: 실패 시 HTTP 모드로 안전하게 작동

더 이상 배포할 때마다 SSL 설정을 걱정할 필요가 없습니다!