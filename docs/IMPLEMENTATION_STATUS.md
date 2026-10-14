# EduManage Offline implementation status

## Completed foundation

- Flutter app entry point with Riverpod.
- GoRouter dashboard, institute setup, and student management routes.
- Material 3 navy/teal theme.
- Drift/SQLite database with institute and student tables, schema version 2, and an upgrade migration that preserves existing institute data.
- Riverpod-managed database lifecycle and institute/student repositories.
- Institute setup form that creates or updates the single institute record locally.
- Student create form with admission number, name, optional phone, and optional parent/guardian.
- Student list and local search by name or admission number.
- Database and widget tests; CI status is tracked in GitHub Actions.

## Step 6: Institute setup and persistence

- Required fields: institute name and academic year.
- Optional field: phone number.
- Values are trimmed and saved to local SQLite; editing updates the existing institute record instead of adding another.

## Step 7: Student management foundation

- Student admission number is unique in SQLite.
- Required fields: admission number and student name; phone and guardian are optional.
- Students can be listed and searched locally by name/admission number.
- Schema upgrade from version 1 creates the student table without recreating the institute table.
- This initial slice does not yet include student editing/deactivation, class allocation, fees, attendance, or import/export.

## Not implemented yet

- Class/batch, fee, payment allocation, discounts/credits, refund/reversal, and attendance workflows.
- Staff, salary, expenses, exams, results, and certificates.
- Offline PDF generation workflows.
- Managed files, backup/restore, and signed offline licensing.
- One-year license expiry, activation-time policy, and clock rollback handling.
- Entitlement guards and finalized role permissions.
- Production release signing and release APK.

## Validation

- Pull request CI must pass formatting, analysis, tests, Drift code generation, and Android debug APK build before merge.
- Do not treat a debug APK as a production release.
