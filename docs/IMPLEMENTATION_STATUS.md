# EduManage Offline implementation status

## Completed foundation

- Flutter app entry point with Riverpod.
- GoRouter dashboard and institute setup routes.
- Material 3 navy/teal theme.
- Drift/SQLite database with the initial institute table and schema version 1.
- Riverpod-managed database lifecycle and institute repository.
- Institute setup form that creates or updates the single institute record locally.
- Dashboard reads saved institute details and links to setup.
- Database and widget tests are included; current CI status is tracked in GitHub Actions.

## Step 6: Institute setup and persistence

- Required fields: institute name and academic year.
- Optional field: phone number.
- Values are trimmed and saved to local SQLite; editing updates the existing institute record instead of adding another.
- This is an initial onboarding slice, not a completed institute management system.

## Not implemented yet

- Student, class/batch, fee, payment allocation, discounts/credits, refund/reversal, and attendance workflows.
- Staff, salary, expenses, exams, results, and certificates.
- Offline PDF generation workflows.
- Managed files, backup/restore, and signed offline licensing.
- One-year license expiry, activation-time policy, and clock rollback handling.
- Entitlement guards and finalized role permissions.
- Production release signing and release APK.

## Validation

- Pull request CI must pass formatting, analysis, tests, Drift code generation, and Android debug APK build before merge.
- Do not treat a debug APK as a production release.
