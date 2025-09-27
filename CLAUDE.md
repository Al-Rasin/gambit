# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application project named "Gambit" - a gaming hub application that provides access to multiple online gaming platforms. The project uses Flutter SDK ^3.9.2 with WebView integration for seamless game browsing.

## Architecture

- **Entry Point**: `lib/main.dart` contains the main application with `GambitApp` widget
- **Dependencies**: Key dependencies include `webview_flutter` for game browsing and `cupertino_icons` for iOS-style icons
- **State Management**: Uses Flutter's built-in StatefulWidget for local state management
- **UI Framework**: Material Design using Flutter's Material library
- **Platform Support**: Multi-platform Flutter app supporting Android, iOS, Linux, macOS, Windows, and Web

## Development Commands

### Build and Run
- `flutter run` - Run the app on connected device/emulator
- `flutter run -d chrome` - Run on web browser
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build for iOS
- `flutter build web` - Build for web

### Testing
- `flutter test` - Run all unit and widget tests
- `flutter test test/widget_test.dart` - Run specific test file
- `flutter test --coverage` - Run tests with coverage report

### Code Quality
- `flutter analyze` - Static analysis using rules from `analysis_options.yaml`
- `dart format .` - Format all Dart files
- `flutter pub get` - Get dependencies
- `flutter pub upgrade` - Upgrade dependencies

### Project Management
- `flutter clean` - Clean build artifacts
- `flutter pub outdated` - Check for outdated dependencies
- `flutter doctor` - Check Flutter installation and dependencies

## Configuration Files

- `pubspec.yaml` - Project dependencies and metadata
- `analysis_options.yaml` - Dart analyzer configuration with flutter_lints rules
- `test/widget_test.dart` - Sample widget test for the counter functionality

## Testing Structure

Tests are located in the `test/` directory. The project includes a basic widget test that verifies the counter increment functionality of the default Flutter app.