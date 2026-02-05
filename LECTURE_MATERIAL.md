# 🎓 Flutter 실무 프로젝트: Gravity-Free QR 개발 가이드

이 문서는 **Gravity-Free QR (GFQR)** 프로젝트를 활용하여 Flutter 앱 개발의 핵심 실무 역량을 학습하기 위한 수업 자료입니다.

---

## 📅 학습 목표 (Learning Objectives)

1.  **Flutter 실무 아키텍처 이해**: Atomic Design 패턴을 활용한 폴더 구조 설계.
2.  **하드웨어 제어 기술**: Google ML Kit 기반의 카메라 제어 및 실시간 데이터 처리.
3.  **고급 UI/UX 구현**: Glassmorphism 디자인 시스템 및 애니메이션 적용.
4.  **데이터 보안 및 영속성**: NoSQL(Hive)과 AES-256 암호화를 활용한 로컬 데이터 관리.
5.  **QR 엔진 활용**: QR 코드의 구조 이해 및 동적 생성 라이브러리 활용.

---

## 🛠 1장: 프로젝트 준비 및 아키텍처

### 1.1 필수 패키지 구성
프로젝트의 핵심 기능을 담당하는 주요 의존성입니다.
- `mobile_scanner`: 카메라 제어 및 QR 인식.
- `qr_flutter`: QR 코드 벡터 생성.
- `hive_flutter`: 고속 NoSQL 데이터베이스.
- `flutter_riverpod`: 전역 상태 관리.

### 1.2 Atomic Design 패턴
협업과 유지보수를 위한 계층형 구조 설계법을 배웁니다.
- **Atoms**: 최하위 컴포넌트 (Button, GlassContainer)
- **Molecules**: 원자들의 조합 (ScanLine, ScanResultItem)
- **Organisms**: 독립적인 기능 단위 (CameraView, HistoryList)
- **Pages**: 전체 화면 레이아웃 (ScannerPage, MakerPage)

---

## 📷 2장: QR 스캐닝 엔진 구현

### 2.1 Google ML Kit 연동
`mobile_scanner`를 활용하여 지연 없는(Instant-on) 스캔 기능을 구현합니다.
- 카메라 권한 획득 방법.
- `MobileScannerController`를 활용한 감지 속도 및 플래시 제어.

### 2.2 오토 줌(Auto-Zoom) 로직
사용자 경험을 극대화하는 지능형 스캔 기능을 구현합니다.
- 인식된 바코드의 크기를 계산하여 자동으로 배율 조정.
- `Barcode.corners` 좌표 데이터 활용법.

---

## 🎨 3장: 프리미엄 UI 설계 (Glassmorphism)

### 3.1 BackdropFilter 활용
Flutter의 `ImageFilter.blur`를 사용하여 미려한 배경 흐림 효과를 구현합니다.
- 투명도 조절(`withOpacity`)과 블러 효과의 최적 점 찾기.
- 다크 모드 테마에 최적화된 컬러 팔레트 구축.

### 3.2 애니메이션 레이어
- `AnimationController`를 활용한 스캔 가이드 라인 개발.
- 햅틱 피드백(`vibration`)을 통한 물리적 경험 제공.

---

## 🔐 4장: 로컬 데이터 보안 및 관리

### 4.1 Hive NoSQL 활용
SQLite보다 빠른 로컬 저장소 Hive의 사용법을 익힙니다.
- `Hive.initFlutter()` 및 박스(Box) 개념 이해.

### 4.2 AES-256 암호화
민감한 스캔 내역을 보호하기 위한 암호화 기술입니다.
- `HiveAesCipher`를 활용한 데이터 읽기/쓰기 가속화.
- 암호화 키 관리 전략.

---

## 🎨 5장: QR Studio (생성 기능)

### 5.1 데이터 타입별 QR 구조
- **URL**: 웹 주소 연결.
- **Banking**: 특정 규격(`BANK:NAME:ACC`)에 따른 데이터 포맷 설계.
- **Profile**: 개인 정보 공유를 위한 커스텀 스키마.

---

## 🚀 실습 과제 (Assignments)

1.  **[기초]** 생성된 QR 코드 이미지를 기기 갤러리에 저장하는 기능을 추가해 보세요.
2.  **[심화]** 스캔한 데이터가 URL일 경우, 특정 안전 도메인(White-list) 여부를 체크하는 보안 로직을 구현해 보세요.
3.  **[창의]** 스캔 히스토리 페이지에서 특정 아이템을 왼쪽으로 스와이프하여 삭제하는 기능을 구현해 보세요.

---
**Gravity-Free Dev Academy** | *Contact: your-email@example.com*
