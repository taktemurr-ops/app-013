# APP-013 · İlaç 360 (Medication 360)

Offline personal medication schedule and intake journal for Android and iOS, built with Flutter. The 400-app bootstrap catalog specifies APP-013 only as `health-medical`; the product name is a **provisional product decision**, not an existing catalog assignment.

## Features
- User-entered medication names, dose labels and multiple daily clock times
- Start date, optional end date and active/pause status in the data model
- Today's scheduled doses, manual taken/skipped status, recent log, seven-day adherence
- Turkish, English and Arabic text, RTL via Flutter locale
- Local encrypted storage via `flutter_secure_storage`
- JSON text backup/import with version and validation; permanent data deletion
- Automated model/repository/widget tests and GitHub Actions workflow

## Safety and limitations
This is a **manual journal**, not a prescribing, diagnosis or dosage recommendation service. No medical advice or automatic dose changes. No push/local notifications have been implemented. The user must open the app to check their schedule. No cloud sync, caregiver sharing, health platform sync or medical-device certification. Backups displayed as plain JSON contain sensitive health data: treat them as unencrypted after export.

## Run
```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Native Android/iOS project scaffolding is generated using `flutter create --platforms=android,ios --project-name ilac360 .` before building. Production signing, app icons, store approvals and real-device tests are not included.
