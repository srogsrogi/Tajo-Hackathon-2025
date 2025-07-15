# 📦 Dockerfile만 수정해서 SSL 자동화하기

## 🎯 목표
**기존 CI/CD 파이프라인을 그대로 두고 Dockerfile만 수정해서 SSL 자동 적용**

## 📋 수정된 파일들
- ✅ `Dockerfile` - SSL 지원 및 자동 감지 기능 추가
- ✅ `entrypoint.sh` - SSL 자동 설정 로직 추가
- ✅ `Dockerrun.aws.json` - 443 포트 및 볼륨 마운트 추가
- ✅ `.ebextensions/ssl-environment.config` - 환경 변수 설정

## 🚀 사용 방법

### 1. 이메일 주소 설정
`.ebextensions/ssl-environment.config` 파일에서 이메일 주소를 변경하세요:
```yaml
LETSENCRYPT_EMAIL: "your-email@example.com"  # 실제 이메일로 변경
```

### 2. 그냥 배포하기
```bash
git add .
git commit -m "Add SSL auto-setup to Dockerfile"
git push origin main
```

**끝!** 기존 GitHub Actions 워크플로우가 자동으로 실행됩니다.

## 🔄 동작 방식

### 첫 번째 배포
1. 🔓 HTTP 모드로 시작
2. 🔍 SSL 인증서 자동 발급 시도
3. ✅ 성공 시 → HTTPS 모드로 전환
4. ❌ 실패 시 → HTTP 모드로 계속

### 두 번째 이후 배포
1. 🔍 기존 인증서 확인
2. ✅ 있으면 → 바로 HTTPS 모드
3. ❌ 없으면 → 재발급 시도

## 📊 배포 후 확인 방법

### 컨테이너 로그 확인
```bash
# EC2에 SSH 접속
ssh -i your-key.pem ec2-user@your-ec2-ip

# 컨테이너 로그 확인
docker logs $(docker ps -q)
```

### 로그 출력 예시
```
=== 🚀 Django App with Auto SSL 시작 ===
📋 설정 정보:
  - 도메인: taewojo.site
  - 이메일: your-email@example.com
  - SSL 모드: auto
❌ SSL 인증서 없음
🔄 자동 모드: 인증서 상태에 따라 결정
🔓 HTTP 설정 적용 중...
🚀 nginx 시작 중...
🐍 Django 애플리케이션 시작 중...
🔄 SSL 인증서 자동 발급 시도 중...
✅ 인증서 발급 완료! HTTPS 설정으로 전환...
🔒 HTTPS 활성화 완료!
   - https://taewojo.site 으로 접속 가능
=== ✅ 애플리케이션 시작 완료 ===
   - HTTP: http://taewojo.site
   - HTTPS: https://taewojo.site
```

### 웹사이트 접속 테스트
```bash
# HTTP 접속 (HTTPS로 리다이렉트)
curl -I http://taewojo.site

# HTTPS 접속 (정상 응답)
curl -I https://taewojo.site
```

## 🔧 SSL 모드 제어

환경 변수로 SSL 동작을 제어할 수 있습니다:

### `SSL_MODE=auto` (기본값)
- 인증서 있으면 HTTPS, 없으면 HTTP → 자동 발급

### `SSL_MODE=force`
- 무조건 HTTPS 사용 (인증서 없으면 에러)

### `SSL_MODE=disable`
- 무조건 HTTP 사용 (인증서 있어도 무시)

## 📈 장점

### ✅ 최소 변경
- 기존 GitHub Actions 워크플로우 그대로
- 기존 CI/CD 파이프라인 그대로
- Dockerfile만 수정

### ✅ 자동화
- 첫 배포 시 자동 인증서 발급
- 이후 배포 시 기존 인증서 재사용
- 90일 후 자동 갱신 (cron job)

### ✅ 안전성
- SSL 실패 시 HTTP 모드로 fallback
- 인증서 상태 자동 감지
- 설정 초기화 방지 (볼륨 마운트)

## 🚨 주의사항

### 1. 이메일 주소 변경 필수
```yaml
LETSENCRYPT_EMAIL: "your-email@example.com"  # 실제 이메일로 변경
```

### 2. AWS 보안 그룹 설정
EC2 보안 그룹에 443 포트 추가:
- 포트 443 (HTTPS): 0.0.0.0/0

### 3. 첫 배포 후 5-10분 대기
SSL 인증서 발급에 시간이 걸릴 수 있습니다.

## 🔄 인증서 갱신

### 자동 갱신 (권장)
cron job이 자동으로 설정되어 90일마다 갱신됩니다.

### 수동 갱신
```bash
# 컨테이너 내에서
docker exec -it $(docker ps -q) /bin/bash
certbot renew --webroot --webroot-path=/var/www/certbot
service nginx restart
```

## 🎉 결론

**Dockerfile만 수정하면 끝!**
- 기존 GitHub Actions 그대로
- 기존 CI/CD 파이프라인 그대로
- SSL 자동 설정 및 관리
- 설정 초기화 걱정 없음

이제 매번 배포할 때마다 SSL 걱정 없이 개발에 집중하세요! 🚀