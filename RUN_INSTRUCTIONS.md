# Prepify - Setup and Run Instructions

This guide provides exactly what you need to run, test, and deploy the Prepify app.

## 1. Prerequisites
- **Flutter SDK** (Ensure you have `>=3.0.0` or later configured).
- **Android Studio** (For Android Emulators / SDK).
- **Xcode** (For iOS Simulators - macOS only).
- **Firebase CLI** installed globally (`npm install -g firebase-tools`).

## 2. Connect Firebase & Environment Setup
Because this is a Flutter app using Firebase, you need to configure your specific Firebase project.

1. Login to Firebase CLI:
   ```bash
   firebase login
   ```
2. Activate FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
3. Link your Firebase project (Run inside `Prepify-main` directory):
   ```bash
   flutterfire configure
   ```
   *Select your project and the platforms (Android, iOS) to generate the `firebase_options.dart` file.*

## 3. Install Dependencies
Run the following at the root of the project to download all the required dart packages:
```bash
flutter pub get
```

## 4. Deploying Firestore Rules
We have generated the exact security rules needed for the new application schema in `firestore.rules`.

Deploy them to your Firebase project:
```bash
firebase deploy --only firestore:rules
```

## 5. How to Run the App

**On Emulator (Android or iOS):**
1. Start your emulator via Android Studio or command line.
2. Run the application:
   ```bash
   flutter run
   ```

**On Real Device (Android):**
1. Enable **Developer Options** and **USB Debugging** on your phone.
2. Connect your phone via USB.
3. Run:
   ```bash
   flutter run -d <your-device-id>
   ```

**On Real Device (iOS):**
1. Open the project in Xcode: `open ios/Runner.xcworkspace`
2. Select your signing team in Xcode settings under "Signing & Capabilities".
3. Plug in your iPhone and select it as the target.
4. Run via Xcode or use `flutter run -d <your-device-id>`.

## 6. Build Commands for Production

**For Android (APK / AppBundle):**
- APK (for testing): `flutter build apk --release`
- AppBundle (for Google Play): `flutter build appbundle --release`

**For iOS (IPA):**
```bash
flutter build ipa --release
```
