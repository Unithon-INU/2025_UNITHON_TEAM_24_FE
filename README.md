# Unithon 2025 - Team 24 프론트엔드 프로젝트

여행 경로 추천 및 커뮤니티 서비스를 위한 Flutter 기반 모바일/웹 애플리케이션입니다.

## 기술 스택

- Flutter 3.x
- Dart
- Firebase Authentication
- Firebase Cloud Storage
- Provider 상태관리
- Google Maps API

## 설치 및 환경설정

### 1. 저장소 클론

```bash
git clone https://github.com/Unithon-INU/2025_UNITHON_TEAM_24_FE.git
cd 2025_UNITHON_TEAM_24_FE
```

### 2. Flutter 설치

아직 Flutter가 설치되어 있지 않다면, [Flutter 공식 문서](https://docs.flutter.dev/get-started/install)를 참고하여 설치하세요.

### 3. 의존성 패키지 설치

```bash
flutter pub get
```

### 4. Firebase 설정

Firebase를 설정하기 위해 다음 단계를 따르세요:

1. [Firebase 콘솔](https://console.firebase.google.com/)에서 프로젝트 생성 또는 선택
2. 앱 등록 (Android, iOS, Web)
3. 다운로드 받은 구성 파일들을 적절한 위치에 배치:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
   - 웹 구성 → `lib/firebase_options.dart` 생성

`firebase_options.example.dart` 파일을 참고하여 `firebase_options.dart` 파일을 생성하세요:

```bash
cp lib/firebase_options.example.dart lib/firebase_options.dart
# 편집기로 firebase_options.dart 파일 열기
# Firebase 콘솔에서 얻은 실제 값으로 대체하세요
```

### 5. 웹 버전 설정

웹 버전을 실행하려면 다음 추가 설정이 필요합니다:

1. `web/index.html` 파일 생성:
   ```bash
   cp web/index.example.html web/index.html
   ```

2. `web/index.html` 파일의 다음 부분을 실제 API 키와 클라이언트 ID로 대체하세요:
   ```html
   <meta name="google-signin-client-id" content="YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com">
   <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_GOOGLE_MAPS_API_KEY"></script>
   ```

3. 환경 변수 설정:
   ```bash
   cp assets/.env.example assets/.env
   # 편집기로 .env 파일 열기
   # API_BASE_URL, GOOGLE_MAPS_API_KEY 등의 값을 실제 값으로 수정하세요
   ```

### 6. 백엔드 API 연결

`lib/config/` 디렉토리에서 백엔드 서버 URL 설정을 확인하고 필요하다면 수정하세요.
기본값은 개발 환경에서 로컬 서버를 가리킵니다:

```dart
// 개발 환경
static const String baseUrl = 'http://localhost:8000/api/v1';

// 프로덕션 환경
// static const String baseUrl = 'https://your-api-server.com/api/v1';
```

## 앱 실행

### 개발 모드

```bash
# 디버그 모드로 실행
flutter run

# 특정 기기/플랫폼으로 실행
flutter run -d chrome  # 웹 브라우저로 실행
flutter run -d ios     # iOS 시뮬레이터/기기로 실행
flutter run -d android # Android 에뮬레이터/기기로 실행
```

### 릴리즈 빌드

```bash
# Android APK 빌드
flutter build apk

# iOS 빌드
flutter build ios

# Web 빌드
flutter build web
```

## 폴더 구조

```
lib/
├── config/         # 앱 설정, 상수, 테마 등
├── models/         # 데이터 모델
├── providers/      # 상태 관리
├── screens/        # 화면 UI
├── services/       # API, 인증, 저장소 등 서비스
├── widgets/        # 재사용 가능한 UI 컴포넌트
├── firebase_options.dart  # Firebase 설정
└── main.dart       # 앱 시작점
```

## 테스트

```bash
flutter test
```

## 라이센스

이 프로젝트는 MIT 라이센스로 배포됩니다.
