---
description: Repository Information Overview
alwaysApply: true
---

# City_Watch Information

## Summary
City_Watch is a disaster response mobile application designed to streamline communication, coordination, and resource management during emergencies. It allows users to report incidents, view interactive maps with real-time updates, request aid, and navigate to safe zones. The project is built using Flutter for the frontend and Firebase for backend services.

## Structure
- **lib/**: Core Flutter application source code (Dart).
- **android/**: Android-specific build configurations and native code.
- **ios/**: iOS-specific build configurations and native code.
- **app/**: A secondary Java-based Gradle project (auxiliary or boilerplate).
- **assets/**: Global application assets including GeoJSON data and images.
- **images/** / **pngs/**: Additional image resources for the application.
- **test/**: Contains unit and widget tests for the Flutter application.

## Language & Runtime
**Language**: Dart (Flutter), Java (Auxiliary)  
**Version**: Dart SDK ^3.6.1, Java 21 (for auxiliary app)  
**Build System**: Flutter Build System, Gradle  
**Package Manager**: pub (Flutter), Gradle (Android/Auxiliary)

## Dependencies
**Main Dependencies (Flutter)**:
- **Firebase**: `firebase_auth`, `firebase_core`, `firebase_storage`, `cloud_firestore`, `firebase_app_check`
- **Maps & Geolocation**: `google_maps_flutter`, `geolocator`, `geojson_vi`, `flutter_polyline_points`
- **State Management**: `provider`
- **Utilities**: `shared_preferences`, `intl`, `uuid`, `shimmer`, `permission_handler`
- **Image Handling**: `image_picker`, `image_cropper`, `image`

**Development Dependencies**:
- `flutter_test`, `lints`, `flutter_native_splash`, `flutter_launcher_icons`

## Build & Installation
```bash
# Install dependencies
flutter pub get

# Build Android APK
flutter build apk

# Build iOS (requires macOS)
flutter build ios
```

## Testing

**Framework**: Flutter Test (based on `test/widget_test.dart`)
**Test Location**: `test/`
**Naming Convention**: `*_test.dart`
**Configuration**: `pubspec.yaml`, `analysis_options.yaml`

**Run Command**:
```bash
flutter test
```

## Main Files & Resources
- **lib/main.dart**: Main entry point for the Flutter application.
- **pubspec.yaml**: Flutter project configuration and dependency manifest.
- **firebase.json**: Firebase project configuration.
- **lib/firebase_options.dart**: Auto-generated Firebase configuration for different platforms.
- **android/app/google-services.json**: Firebase Android configuration file.
- **assets/Kirinyaga.geojson**: GeoJSON data for mapping.
