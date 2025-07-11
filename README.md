# 🎙️ Voice Transportation Assistant - Tajo

> 2025년 제7회 K-디지털 트레이닝 해커톤 대회 출품작
> 
> **음성 인터랙션 기반 한국 대중교통 안내 시스템**

[![Python](https://img.shields.io/badge/Python-3.9+-blue.svg)](https://python.org)
[![Django](https://img.shields.io/badge/Django-4.2+-green.svg)](https://djangoproject.com)
[![Whisper](https://img.shields.io/badge/OpenAI-Whisper-orange.svg)](https://openai.com/research/whisper)
[![Ollama](https://img.shields.io/badge/LLM-Ollama-purple.svg)](https://ollama.ai)

## 🌟 프로젝트 개요

**Tajo**는 한국어 음성 인식과 AI를 활용하여 대중교통 정보를 제공하는 혁신적인 서비스입니다. 사용자가 자연스러운 음성으로 질문하면, 실시간 교통 정보를 바탕으로 최적의 경로를 안내해드립니다.

### 🎯 핵심 가치
- **접근성**: 시각 장애인과 고령자를 위한 음성 우선 인터페이스
- **실시간성**: 실시간 버스 위치와 교통 상황 반영
- **자연스러움**: 한국어 특화 대화형 AI 상담
- **편의성**: 복잡한 대중교통 시스템을 음성으로 간단히 이용

## ✨ 주요 기능

### 🎤 음성 인터랙션
```
사용자: "강남역에서 홍대까지 가는 방법 알려줘"
AI: "지하철 2호선을 이용하세요. 강남역에서 탑승하여 신촌역에서 하차 후 6호선으로 환승하여 홍대입구역까지 약 35분 소요됩니다."
```

### 🚌 실시간 교통 정보
- 버스 실시간 위치 추적
- 도착 예정 시간 안내
- 최적 경로 추천

### 🗺️ 지도 연동
- 네이버 클라우드 맵 API 활용
- 시각적 경로 안내
- 대중교통 정류장 정보

## 🏗️ 기술 스택

### Backend
- **Framework**: Django 4.2+
- **Database**: MySQL (PyMySQL)
- **Environment**: python-dotenv

### AI/ML Pipeline
- **STT**: OpenAI Whisper (한국어 특화)
- **LLM**: Ollama (Llama3, Mistral)
- **TTS**: Google Text-to-Speech (gTTS)

### APIs & External Services
- **교통정보**: 공공데이터포털 버스 위치 API
- **지도서비스**: 네이버 클라우드 Map API
- **알림**: Discord Webhook (팀 협업)

## 🚀 성능 지표

| 구분 | 현재 성능 | 목표 성능 |
|------|-----------|-----------|
| 음성인식 | 0.66초 | 0.5초 |
| AI 응답 | 17.85초 | 3-5초 |
| 음성합성 | 8.30초 | 3-5초 |
| 전체 응답 | ~26초 | <10초 |

## 📱 사용법

### 개발 환경 설정
```bash
# 1. 저장소 클론
git clone https://github.com/your-team/Hackathon-2025.git
cd Hackathon-2025

# 2. 가상환경 생성 및 활성화
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 3. 의존성 설치
pip install -r requirements.txt

# 4. 환경변수 설정
cp .env.example .env
# .env 파일에 API 키 설정

# 5. 데이터베이스 마이그레이션
cd tajo
python manage.py migrate

# 6. 개발 서버 실행
python manage.py runserver
```

### API 테스트
```bash
# Jupyter 노트북으로 각 API 테스트
cd api_test
jupyter lab
```

## 🏆 해커톤 데모 시나리오

### 1단계: 음성 입력 (30초)
- 사용자가 마이크에 대고 자연스럽게 질문
- 실시간 음성 인식 시각화

### 2단계: AI 처리 (30초)  
- STT → LLM → TTS 파이프라인 실시간 표시
- 처리 단계별 진행 상황 안내

### 3단계: 경로 안내 (60초)
- 인터랙티브 지도에 최적 경로 표시
- 단계별 이동 방법 설명

### 4단계: 실시간 추적 (60초)
- 경로상 버스들의 실시간 위치
- 도착 예정 시간 업데이트

### 5단계: 접근성 기능 (60초)
- 음성만으로 완전한 내비게이션
- 시각 장애인 사용 시연

## 🌐 접근성 특화 기능

### 👥 대상 사용자
- **시각 장애인**: 음성 전용 인터페이스
- **고령자**: 복잡한 앱 조작 없이 음성으로 간편 이용
- **관광객**: 한국 대중교통 시스템 안내
- **일반 사용자**: 핸즈프리 내비게이션

### ♿ 웹 접근성 준수
- WCAG 2.1 AA 수준 준수
- 스크린 리더 호환
- 키보드 전용 내비게이션
- 고대비 테마 지원

## 🤝 팀 정보

### 개발팀
- **팀명**: [팀명 입력]
- **구성원**: [구성원 정보]
- **역할 분담**: [역할 분담 정보]

### 연락처
- **이메일**: [이메일 주소]
- **Discord**: [Discord 채널]
- **GitHub**: [GitHub 저장소]

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 🙏 감사의 말

- **K-디지털 트레이닝**: 교육 및 해커톤 기회 제공
- **공공데이터포털**: 교통 데이터 API 제공  
- **네이버 클라우드**: 지도 API 지원
- **OpenAI**: Whisper 모델 제공
- **Ollama**: 로컬 LLM 환경 지원

---

**🎯 2025 K-Digital Training Hackathon을 위해 제작된 프로젝트입니다.**
