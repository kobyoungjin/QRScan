# 🚀 Gravity-Free QR (GFQR)

**Gravity-Free QR (GFQR)**는 물리적 제약을 넘어선 듯한 초고속 스캔 경험과 미려한 Glassmorphism UI를 제공하는 차세대 QR 리더기입니다.

---

## ✨ 핵심 기능 (Key Features)

- **⚡ Instant-On Scanning**: Google ML Kit 기반의 초정밀, 무지연 QR 인식 엔진.
- **🎨 QR Studio (Maker)**: 프로필, 웹사이트, 은행 계좌 정보를 담은 고품질 QR 코드 실시간 생성.
- **🧭 Fluid Navigation**: 하단 내비게이션 바를 통한 스캔과 생성 기능의 매끄러운 전환.
- **🔍 Auto-Focus Scaling**: 멀리 있는 작은 QR 코드를 감지하면 자동으로 디지털 줌(Zoom-in) 처리.
- **💎 Weightless UX**: 배경 흐림 효과(Glassmorphism)와 부드러운 애니메이션이 적용된 프리미엄 디자인.
- **🔐 Secure History**: 모든 스캔 내역을 **AES-256** 방식으로 암호화하여 기기 내(Hive NoSQL) 안전하게 저장.

---

## 🛠 기술 스택 (Tech Stack)

- **Framework**: Flutter
- **Scanning**: Google ML Kit Barcode Scanning API (`mobile_scanner`)
- **Generation**: `qr_flutter` 기반 벡터 QR 렌더링
- **State Management**: Riverpod
- **Storage**: Hive (High-speed NoSQL) / AES-256 Encryption
- **UI Architecture**: Atomic Design Pattern
- **Design Style**: Glassmorphism & Neumorphism

---

## 📂 프로젝트 구조 (Architecture)

```text
lib/
├── core/             # 앱 테마 및 전역 로직 (ActionResolver, AppTheme)
├── features/         # 기능별 비즈니스 로직 및 서비스
│   ├── history/      # 스캔 내역 관리 및 암호화 서비스
│   └── maker/        # QR 생성 로직 및 UI (QR Maker)
├── ui/               # Atomic Design 기반 UI 컴포넌트
│   ├── atoms/        # 디자인 원자 (GlassContainer 등)
│   ├── molecules/    # 디자인 분자 (ScanLine 등)
│   ├── organisms/    # 독립 기능 단위 (CameraView 등)
│   └── pages/        # 화면 레이아웃 (MainNavigationPage, ScannerPage, HistoryPage)
└── main.dart         # 앱 진입점
```

---

## 🚀 시작하기 (Getting Started)

### 사전 요구 사항
- Flutter SDK (v3.10.0 이상)
- Android Studio / Xcode

### 설치 및 실행
1. 저장소를 클론합니다.
2. 의존성 패키지를 설치합니다.
   ```bash
   flutter pub get
   ```
3. 앱을 실행합니다.
   ```bash
   flutter run
   ```

---

## 📅 로드맵 (Milestones)
- [x] Phase 1: 환경 설정 및 기본 카메라 프리뷰 구현
- [x] Phase 2: ML Kit 연동 및 오토 줌 로직 완성
- [x] Phase 3: Glassmorphism 디자인 및 애니메이션 적용
- [x] Phase 4: Hive 기반 보안 스캔 내역 시스템 구축
- [x] Phase 5: 성능 최적화 및 최종 검증
- [x] Phase 6: QR 생성(Maker) 기능 및 내비게이션 시스템 구축

---
**Anti-Gravity Dev Team** | *Last Updated: 2026-02-05*
