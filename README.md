# EduManage Offline

Offline-first education institute management app for tuition centres, coaching institutes and small schools.

## Planned product direction

- Flutter / Dart Android application.
- Local SQLite database through Drift.
- Riverpod state management and GoRouter navigation.
- Core workflows designed to operate without internet.
- Offline PDF generation and app-managed local documents.
- Signed offline Basic, Professional and Premium licenses.
- Financial and academic history preserved through explicit correction events and snapshots.

## Current implementation status

The repository now contains the initial Flutter application foundation:

- App entry point and Riverpod provider scope.
- Material 3 navy/teal theme.
- Initial GoRouter dashboard route.
- Honest dashboard placeholder with no fabricated institute records.
- Dart lint configuration and an initial widget smoke test.
- Implementation status checklist in [docs/IMPLEMENTATION_STATUS.md](docs/IMPLEMENTATION_STATUS.md).

**This is an early scaffold, not a completed app.** The Android platform scaffold, package resolution, database schema/migrations, business modules, backup/restore, license verification, CI, build and test execution remain outstanding. No build or test result is claimed here.

## Blueprint

Implementation must follow the approved product plan and screen blueprint. The proposed architecture and logical table inventory are design inputs, not proof of an already existing database schema.

## Security rules

- Do not commit signing keys, private license-signing keys, passwords or local environment secrets.
- Keep institute records on-device for core workflows.
- Do not reset or silently overwrite historical financial or academic records to recover from errors.

## Development

Use a compatible Flutter SDK, then run:

```sh
flutter pub get
dart format .
flutter analyze
flutter test
```

These commands are instructions only; they have not been executed in this environment.
