# Flutter Mobile App Development Guide

## Personalized Sleep Quality Analyzer – Mobile Application

This document provides comprehensive instructions for implementing the Flutter mobile application component of the Personalized Sleep Quality Analyzer system. The app serves as the primary user interface for data entry, result visualization, and human-in-the-loop feedback collection.

---

## 1. Overview

The mobile app is responsible for:

- User authentication (signup, login)
- Profile completion and management
- Daily pre‑sleep data entry (evening)
- Daily post‑sleep data entry (morning)
- Displaying the sleep quality score and classification
- Collecting subjective user feedback (ground truth labels)
- Presenting personalized insights and recommendations

The app communicates exclusively with a RESTful backend API (as described in the design documentation) and does not perform any machine learning or complex computation locally.

---

## 2. Prerequisites

| Requirement              | Version / Tool                                   |
|--------------------------|--------------------------------------------------|
| Flutter SDK              | ≥ 3.16.x                                         |
| Dart SDK                 | ≥ 3.2.x                                          |
| IDE                      | Android Studio / VS Code with Flutter extensions |
| Target Platforms         | iOS (≥ 13.0) and Android (API level 23+)         |
| Backend API Base URL     | Provided via environment configuration            |

---

## 3. Project Structure

Adopt a **feature‑first** layered architecture for maintainability and scalability.

```
lib/
├── main.dart
├── app/
│   ├── app.dart                     # MaterialApp configuration
│   ├── routes.dart                  # Named route definitions
│   └── theme.dart                   # AppTheme with colors and text styles
├── core/
│   ├── constants/
│   │   ├── api_constants.dart       # Endpoint paths, timeouts
│   │   └── app_constants.dart       # Sleep score ranges, cold start days
│   ├── network/
│   │   ├── api_client.dart          # Dio HTTP client with interceptors
│   │   └── api_exception.dart       # Custom exception handling
│   ├── storage/
│   │   └── secure_storage.dart      # Encrypted token storage
│   └── utils/
│       ├── validators.dart          # Form field validators
│       └── date_helper.dart         # Date/time formatting
├── data/
│   ├── models/
│   │   ├── user.dart                # User profile model
│   │   ├── raw_sleep_data.dart      # 25‑field raw data model
│   │   ├── derived_sleep_data.dart  # Score and metrics model
│   │   ├── sleep_analysis_result.dart
│   │   └── recommendation.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── profile_repository.dart
│   │   ├── sleep_data_repository.dart
│   │   └── analysis_repository.dart
│   └── providers/                   # Riverpod providers (or Bloc cubits)
│       ├── auth_provider.dart
│       ├── profile_provider.dart
│       ├── sleep_data_provider.dart
│       └── analysis_provider.dart
├── presentation/
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   ├── onboarding/
│   │   │   └── profile_completion_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart          # Dashboard with day/night prompts
│   │   ├── data_entry/
│   │   │   ├── pre_sleep_entry_screen.dart
│   │   │   └── post_sleep_entry_screen.dart
│   │   ├── results/
│   │   │   ├── sleep_report_screen.dart  # Score, classification, insights
│   │   │   └── feedback_screen.dart      # Subjective rating collection
│   │   └── history/
│   │       └── sleep_history_screen.dart # List of past records
│   └── widgets/
│       ├── common/
│       │   ├── loading_indicator.dart
│       │   ├── error_view.dart
│       │   ├── custom_app_bar.dart
│       │   └── primary_button.dart
│       ├── forms/
│       │   ├── numeric_input_field.dart
│       │   ├── time_picker_field.dart
│       │   ├── slider_input_field.dart
│       │   └── mood_selector.dart
│       └── charts/
│           └── score_trend_chart.dart    # Optional history visualization
└── l10n/                                 # Optional localization
    └── app_en.arb
```

---

## 4. State Management

Use **Riverpod** (recommended) or **BLoC** for predictable state management.

### Example Riverpod Providers

```dart
// auth_provider.dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// sleep_data_provider.dart
final sleepDataRepositoryProvider = Provider<SleepDataRepository>((ref) {
  return SleepDataRepository(ref.watch(apiClientProvider));
});

final preSleepFormProvider = StateProvider<RawSleepData>((ref) {
  return RawSleepData.empty();
});
```

For form state management, combine `StateProvider` with `FormBuilder` (from `flutter_form_builder`) or use Riverpod's `StateNotifierProvider`.

---

## 5. Theming & UI Style

Adopt a calm, trustworthy, and health‑oriented visual identity.

### Color Palette

| Name               | Hex       | Usage                                      |
|--------------------|-----------|--------------------------------------------|
| Primary (Deep Blue)| `#1E3A5F` | App bar, primary buttons, icons            |
| Secondary (Teal)   | `#2A9D8F` | Accent elements, success indicators        |
| Background         | `#F5F7FA` | Scaffold background                        |
| Surface            | `#FFFFFF` | Cards, dialogs                             |
| Error              | `#E63946` | Validation errors, warnings                |
| Sleep Score Good   | `#4CAF50` | Score > 75                                 |
| Sleep Score Medium | `#FFC107` | Score 50‑75                                |
| Sleep Score Poor   | `#F44336` | Score < 50                                 |
| Text Primary       | `#212121` | Body text                                  |
| Text Secondary     | `#757575` | Subtitles, hints                           |

### Typography

- Font family: **Inter** (or default Roboto)
- Headlines: `TextTheme.headlineMedium` (bold, 24‑28sp)
- Body: `TextTheme.bodyLarge` (regular, 16sp)
- Captions: `TextTheme.bodySmall` (14sp, grey)

### Component Styling

- **Primary Button**: Rounded corners (12px), elevation 2, filled with primary color.
- **Cards**: Rounded corners (16px), subtle shadow, padding 16px.
- **Input Fields**: Outlined border, rounded corners (12px), label text with primary color when focused.

---

## 6. API Integration

### API Client Setup (Dio)

```dart
class ApiClient {
  late final Dio _dio;
  final SecureStorage _storage;

  ApiClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(AuthInterceptor(_storage));
    _dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  Future<Response> post(String path, {dynamic data}) => _dio.post(path, data: data);
  Future<Response> get(String path) => _dio.get(path);
  // ... other methods
}
```

### Authentication Interceptor

Automatically attach JWT token to every request.

```dart
class AuthInterceptor extends Interceptor {
  final SecureStorage storage;
  AuthInterceptor(this.storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storage.readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

### Endpoints (from Design.pdf)

| Endpoint                     | Method | Purpose                                 |
|------------------------------|--------|-----------------------------------------|
| `/auth/signup`               | POST   | User registration                       |
| `/auth/login`                | POST   | Login, returns JWT                      |
| `/profile`                   | GET    | Fetch user profile                      |
| `/profile`                   | PUT    | Update profile (age, gender, etc.)      |
| `/sleep/raw`                 | POST   | Submit pre‑sleep or post‑sleep raw data |
| `/sleep/analysis`            | GET    | Trigger analysis and retrieve report    |
| `/sleep/feedback`            | POST   | Submit subjective `user_score` / `user_class` |
| `/sleep/history`             | GET    | Retrieve historical records             |
| `/insights/recommendations`  | GET    | Get personalized insights               |

---

## 7. Screens Implementation Details

### 7.1 Splash Screen

- Check authentication status using `SecureStorage`.
- Navigate to `LoginScreen` or `HomeScreen`.

### 7.2 Authentication Screens

**LoginScreen** and **SignupScreen**:

- Use `Form` with validation (email format, password length ≥ 8).
- On success, store JWT token and navigate to profile completion or home.

### 7.3 Profile Completion Screen

Required fields: `age`, `gender`, `weight_kg`, `height_cm`.
These are needed for baseline physiological normalization.

- Use dropdown for gender, numeric fields with validation.
- Submit via `PUT /profile`.

### 7.4 Home Screen (Dashboard)

- Display current day's status (e.g., "Pre‑sleep data pending" or "Analysis ready").
- Two primary action cards:
    - **Evening Check‑in**: Navigate to `PreSleepEntryScreen`.
    - **Morning Check‑in**: Navigate to `PostSleepEntryScreen` (only if pre‑sleep data submitted).
- Show recent sleep score trend (last 7 days) if data available.

### 7.5 Pre‑Sleep Data Entry Screen

Collects behavioral and self‑reported data for the evening.

Form fields (all required unless noted):

| Field                   | Input Type                | Unit / Range   |
|-------------------------|---------------------------|----------------|
| Caffeine Time           | Time picker               | HH:MM          |
| Caffeine Amount         | Numeric (optional slider) | mg (0‑800)     |
| Alcohol Units           | Numeric stepper           | 0‑10           |
| Water Intake            | Numeric                   | liters         |
| Steps                   | Numeric                   | count          |
| Activity Intensity      | Segmented control         | Low/Med/High   |
| Screen Time Before Bed  | Numeric (minutes)         | 0‑240          |
| Stress (self‑eval)      | Slider (1‑10)             | 1 = low        |
| Mood (self‑eval)        | Slider (1‑10)             | 10 = best      |

**Submission**:

- POST to `/sleep/raw` with `type: "pre_sleep"`.
- After success, navigate back to Home.

### 7.6 Post‑Sleep Data Entry Screen

Collected upon waking.

| Field                   | Input Type                | Unit / Range   |
|-------------------------|---------------------------|----------------|
| Sleep Time              | Time picker (HH:MM)       | Yesterday time |
| Wake Time               | Time picker               | Today time     |
| Awakenings              | Numeric stepper           | 0‑20           |
| Sleep Latency           | Numeric (minutes)         | 0‑120          |
| Naps                    | Numeric (minutes)         | 0‑180          |
| HR Rest                 | Numeric                   | bpm            |
| HRV                     | Numeric                   | ms             |
| Body Temperature        | Numeric                   | °C             |
| Respiratory Rate        | Numeric                   | breaths/min    |
| Room Temperature        | Numeric                   | °C             |
| Noise Level             | Numeric / Slider          | dB (30‑100)    |
| Light Lux               | Numeric                   | 0‑1000         |
| **Subjective Rating**   | Slider (0‑100) + Class    | Good/Mod/Poor  |

**Important**: The subjective rating fields (`user_score`, `user_class`) are collected on this screen as part of the post‑sleep entry. They are **ground truth labels** for the ML pipeline.

**Submission**:

- POST to `/sleep/raw` with `type: "post_sleep"`.
- After success, trigger analysis by calling `GET /sleep/analysis` (or the backend may automatically process).
- Navigate to `SleepReportScreen`.

### 7.7 Sleep Report Screen

Displays:

- **Final Sleep Score** (0‑100) with color‑coded circular progress indicator.
- **Sleep Classification** (Good, Moderate, Poor).
- **Key Metrics**: Sleep Efficiency, TST, Consistency, Bio Score.
- **Personalized Insights**: e.g., "Your caffeine intake 3h before bed lowered your score by 8 points."
- **Actionable Recommendations**: "Try a wind‑down routine without screens."

If the user is still within the cold start period (< 14 days), display a badge indicating "Learning your patterns – score based on general guidelines."

### 7.8 Feedback Screen (Optional Standalone)

If not integrated into post‑sleep entry, this screen collects the user's perception of the generated report. The user can adjust the slider and classification, then submit to improve the model.

### 7.9 Sleep History Screen

- List view of past dates with Final Score and classification.
- Tap to view detailed report for that day.
- Implement pagination using `GET /sleep/history`.

---

## 8. Navigation

Use **GoRouter** (recommended for declarative routing with deep linking support).

```dart
final router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    final isLoggedIn = await SecureStorage().hasToken();
    final isOnboardingComplete = await ProfileRepository().isComplete();
    if (!isLoggedIn && state.matchedLocation != '/login') return '/login';
    if (isLoggedIn && !isOnboardingComplete && state.matchedLocation != '/onboarding') {
      return '/onboarding';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => SignupScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => ProfileCompletionScreen()),
    ShellRoute(
      builder: (_, __, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => HomeScreen()),
        GoRoute(path: '/pre-sleep', builder: (_, __) => PreSleepEntryScreen()),
        GoRoute(path: '/post-sleep', builder: (_, __) => PostSleepEntryScreen()),
        GoRoute(path: '/report/:date', builder: (_, state) => SleepReportScreen(date: state.pathParameters['date'])),
        GoRoute(path: '/history', builder: (_, __) => SleepHistoryScreen()),
      ],
    ),
  ],
);
```

---

## 9. Data Models

Create Dart classes with `fromJson` / `toJson` factories matching backend schemas.

### Example: RawSleepData

```dart
class RawSleepData {
  final String userId;
  final DateTime recordDate;
  final TimeOfDay? sleepTime;
  final TimeOfDay? wakeTime;
  final int? awakenings;
  final int? sleepLatencyMinutes;
  final int? naps;
  final int? hrRest;
  final int? hrv;
  final double? bodyTemp;
  final int? respRate;
  final TimeOfDay? caffeineTime;
  final int? caffeineMg;
  final int? alcoholUnits;
  final double? waterLiters;
  final int? steps;
  final String? activityIntensity;
  final int? screenMinutesBeforeBed;
  final int? stress;
  final int? mood;
  final double? roomTemp;
  final int? noiseDb;
  final int? lightLux;

  RawSleepData({...});

  Map<String, dynamic> toJson() {
    return {
      'sleep_time': sleepTime?.format(context), // use HH:MM string
      // ... all fields
    };
  }
}
```

Use `TimeOfDay` extension to convert to/from ISO string.

---

## 10. Local Storage

Use **flutter_secure_storage** for JWT token and **shared_preferences** for non‑sensitive flags (e.g., onboarding completed).

```dart
class SecureStorage {
  final _storage = const FlutterSecureStorage();
  Future<void> saveToken(String token) => _storage.write(key: 'jwt', value: token);
  Future<String?> readToken() => _storage.read(key: 'jwt');
  Future<void> deleteToken() => _storage.delete(key: 'jwt');
}
```

---

## 11. Error Handling & Validation

### Form Validation

```dart
String? validateRequired(String? value) => value == null || value.isEmpty ? 'Required' : null;
String? validateNumericRange(String? value, int min, int max) {
  final num = int.tryParse(value ?? '');
  if (num == null || num < min || num > max) return 'Enter $min-$max';
  return null;
}
```

### API Error Handling

Catch `DioError` and map to user‑friendly messages. Show `SnackBar` or inline error widget.

```dart
String getErrorMessage(DioError error) {
  if (error.type == DioErrorType.connectionTimeout) return 'Connection timeout';
  if (error.response?.statusCode == 401) return 'Session expired. Please login again.';
  return error.response?.data['message'] ?? 'Something went wrong';
}
```

---

## 12. Handling Cold Start vs Personalized Mode

The app does not need to implement the 14‑day logic; the backend determines whether ML is used. However, the UI can reflect the learning status:

- Fetch `learning_factor` or a `personalization_enabled` flag from the analysis response.
- Display a subtle banner: "🎓 AI is learning your sleep patterns (Day X of 14)."
- After 14 days, the report may include "Personalized insights based on your unique patterns."

---

## 13. Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  # State Management
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  # Networking
  dio: ^5.3.0
  # Routing
  go_router: ^13.0.0
  # Local Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.0
  # UI Utilities
  flutter_form_builder: ^9.1.0
  form_builder_validators: ^9.0.0
  intl: ^0.18.0
  fl_chart: ^0.65.0               # For trend charts
  percent_indicator: ^4.2.3        # Score circular indicator
  # Date/Time
  jiffy: ^6.2.0
  # Helpers
  equatable: ^2.0.5
  json_annotation: ^4.8.1

dev_dependencies:
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
```

---

## 14. Building & Deployment

### Environment Configuration

Create `.env` files (using `flutter_dotenv`) to store `API_BASE_URL`.

```env
API_BASE_URL=https://your-render-backend.onrender.com
```

### Android / iOS Specifics

- Add Internet permission in `AndroidManifest.xml`.
- For iOS, allow arbitrary loads only for debug (use HTTPS in production).

---

## 15. Testing Guidance

- **Unit tests**: Repository and provider logic.
- **Widget tests**: Form validation, navigation.
- **Integration tests**: End‑to‑end flow with mock backend.

---

## 16. Conclusion

This Flutter application serves as the frontend for a self‑supervised personalized sleep quality system. By following the architecture, state management, and UI guidelines described above, developers can build a maintainable, user‑friendly mobile app that seamlessly integrates with the backend’s human‑in‑the‑loop machine learning pipeline.

For subsequent parts (backend, ML services), refer to the design and methodology documents.