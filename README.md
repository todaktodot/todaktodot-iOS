# 투닥투닷 (todaktodot) iOS

> 현실적인 대화를 부담없이 시작할 수 있는 AI 기반 커플 대화

## 📱 소개

연인 사이에서 꺼내기 어려운 현실적인 질문을 AI가 대신 던져주고, 대화 패턴을 분석하여 관계 인사이트를 제공하는 앱입니다.

매일 새로운 질문 카드가 커플에게 제공되며, 각자의 답변을 공유하고 이모지로 반응할 수 있습니다.
AI가 축적된 답변을 분석하여 관계 리포트를 생성합니다.

## 🛠 기술 스택

`Swift` `ReactorKit` `RxSwift` `FlexLayout` `PinLayout` `Alamofire` `Firebase` `Tuist` `Lottie`

## 🏗 아키텍처

**Clean Architecture + ReactorKit + Coordinator**

```
Presentation (View + Reactor + Coordinator)
     ↕
Domain (UseCase + Repository Protocol)
     ↕
Data (RepositoryImpl + DTO + NetworkKit)
```

- 모듈 분리: `todaktodot` (메인 앱) + `NetworkKit` (네트워크 독립 모듈)
- 단방향 데이터 흐름: View → Action → Reactor → State → View
- Coordinator 패턴으로 화면 전환 로직 분리

## 👥 팀 구성

PM 1 · 디자이너 1 · 백엔드 2 · **iOS 2** · Android 2

### iOS 담당

| | 임대진 | 정다혜 |
|---|---|---|
| 설계 | 프로젝트 초기 설계 (Tuist, xcconfig) | Coordinator 패턴 설계, 딥링크 라우팅 모듈 |
| 기능 | 로그인/온보딩, AI 리포트, 마이페이지, 잔디 히트맵 | 홈, 데일리카드, 히스토리, 공유링크 |
| 인프라 | Fastlane CD, FCM, Analytics, Remote Config | Crashlytics, GitHub Actions CI (Gemini 코드 리뷰) |

## ✨ 주요 기능

| 기능 | 설명 |
|------|------|
| 🔐 소셜 로그인 | Kakao, Google, Apple 연동 |
| 💑 커플 연결 | 초대 코드로 파트너 매칭 |
| 📋 데일리 카드 | 매일 새로운 질문 카드 + 답변 작성 |
| 🔍 히스토리 카드 | 답변 히스토리 + AI 답변 분석 |
| 📊 AI 리포트 | 답변 패턴 기반 AI 관계 분석 |
| 🔗 공유하기 | Universal Link + 서버 토큰 방식 |
| 🔔 푸시 알림 | 이모지 반응, 답변 독촉, 딥링크 라우팅 |
| 🌱 잔디 히트맵 | 답변 활동 시각화 |

## 📂 협업 프로세스

```
feature/TDTDIOS-{Jira번호} → PR → Gemini AI 리뷰 + 팀원 리뷰 → develop → Fastlane → TestFlight
```

- Jira 티켓 기반 브랜치 관리
- PR 생성 시 AI 코드 리뷰 자동 실행
- MVP 이후 팀 단위 스프린트 진행

## ⚙️ 환경

| 개발 기간 | iOS | 관리 | 협업 |
|-----------|-----|------|------|
| MVP 2025.11 ~ 2026.04 · 스프린트 2026.05 ~ 현재 | 15.0+ | Tuist + SPM | Jira, Git Flow + PR 코드리뷰 |
