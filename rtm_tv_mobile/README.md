# Flutter Mobile App

This project is a native Flutter application for RTM TV.

## Security
Sensitive information (Backend URL and Auth Key) is injected at build time using `--dart-define`.
The APK is built with obfuscation enabled.

## Build Instructions
To build the APK locally:
```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols --dart-define=BACKEND_URL=your_url --dart-define=AUTH_KEY=your_key
```
