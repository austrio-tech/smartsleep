# SmartSleep App - Implementation Details

This mobile application was generated based on the instructions provided in `README.md`. It follows a feature-first layered architecture and uses modern Flutter development practices.

## Features Implemented

### 1. Core Infrastructure
- **State Management**: Integrated **Riverpod** for robust and testable state handling.
- **Networking**: Configured **Dio** with `AuthInterceptor` for JWT-based secure API communication.
- **Local Storage**: Used **Flutter Secure Storage** for persisting sensitive data like authentication tokens.
- **Theming**: Implemented a custom theme with the specified "Deep Blue" and "Teal" color palette using `Google Fonts (Inter)`.

### 2. Authentication & Onboarding
- **Splash Screen**: Handles initial authentication check and routing.
- **Login & Signup**: Full forms with validation using `flutter_form_builder`.
- **Profile Completion**: Collects essential physiological data (age, gender, weight, height) required for sleep analysis.

### 3. Sleep Data Logging
- **Evening Check-in (Pre-Sleep)**: Form to log caffeine intake, alcohol, water, steps, activity, stress, and mood.
- **Morning Check-in (Post-Sleep)**: Form to log sleep/wake times, awakenings, and biometrics (HR, HRV, Temp) along with environmental factors.

### 4. Results & Insights
- **Dashboard (Home)**: Summary of sleep status and quick access to data entry.
- **Sleep Report**: Visual representation of the Sleep Score (using a circular progress indicator) and detailed metrics (Duration, Efficiency, Deep Sleep, REM).
- **Personalized Recommendations**: Display of AI-driven insights regarding habits and environment.
- **Feedback Loop**: Integrated feedback mechanism for users to rate the accuracy of the sleep analysis.

## Technical Stack
- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Riverpod
- **API Client**: Dio
- **Forms**: Flutter Form Builder
- **Charts**: FL Chart (prepared for historical trends)
- **Icons**: Material Icons & FontAwesome (via Cupertino)

## How to Run
1. Ensure Flutter SDK is installed.
2. Run `flutter pub get` to install dependencies.
3. Run `flutter pub run build_runner build` to generate model classes (Freezed/JSON Serializable).
4. Connect a device/emulator and run `flutter run`.
