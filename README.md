# GMMX Mobile

Flutter mobile client for the GMMX MVP.

## Overview

This repository contains the mobile app for GMMX, built with Flutter and
Firebase authentication. The current app boot flow initializes Firebase and
starts on the OTP request screen.

## Tech Stack

- Flutter (Dart SDK >= 3.4.0 < 4.0.0)
- Firebase Core + Firebase Auth
- Riverpod for state management
- Dio for API networking

## Current Modules

- Auth: OTP request and verification, login, role selection
- Core: shared theme and app-level utilities
- Feature placeholders for attendance, dashboard, gym, plans, profile, trainer,
	and more

## Project Structure

```text
mobile/
	lib/
		core/
		features/
			auth/
				data/
				presentation/
		firebase_options.dart
		main.dart
```

## Prerequisites

- Flutter SDK installed
- Android Studio or Xcode (depending on target platform)
- A Firebase project configured for this app

## Environment Configuration

Copy `.env.example` to `.env` and update values as needed:

```env
API_BASE_URL=http://10.0.2.2:8080
TENANT_SLUG=coachmohan
FIREBASE_EMAIL_LINK_URL=https://gmmx.app/auth/email-link
ANDROID_PACKAGE_NAME=com.example.gmmx_mobile
IOS_BUNDLE_ID=com.example.gmmxMobile
```

## Firebase Setup

This project uses `lib/firebase_options.dart`. If you are setting up from
scratch, generate it for your Firebase project using FlutterFire CLI.

## Run Locally

```bash
flutter pub get
flutter run
```

## Quality Checks

```bash
flutter analyze
flutter test
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening pull requests.

## License

Licensed under GNU Affero General Public License v3.0.
See [LICENSE](LICENSE) for details.
