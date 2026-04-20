# GMMX Mobile

Flutter mobile client for the GMMX MVP.

## Overview

This repository contains the mobile app for GMMX, built with Flutter and
backend-driven authentication APIs.

## Tech Stack

- Flutter (Dart SDK >= 3.4.0 < 4.0.0)
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
		main.dart
```

## Prerequisites

- Flutter SDK installed
- Android Studio or Xcode (depending on target platform)

## Environment Configuration

Copy `.env.example` to `.env` and update values as needed:

```env
API_BASE_URL=http://10.0.2.2:8080
TENANT_SLUG=coachmohan
GOOGLE_SERVER_CLIENT_ID=
```

If you later add backend token exchange, set `GOOGLE_SERVER_CLIENT_ID` to the Web OAuth client ID from Google Cloud.

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
