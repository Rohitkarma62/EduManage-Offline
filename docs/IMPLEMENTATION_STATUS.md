# EduManage Offline implementation status

## Completed foundation

- Flutter app entry point with Riverpod.
- GoRouter dashboard, institute setup, and student management routes.
- Material 3 navy/teal theme.
- Drift/SQLite database with institute, class/batch, and student tables, schema version 3, and upgrade migrations that preserve existing records.
- Riverpod-managed database lifecycle and institute/student/class repositories.
- Institute setup form that creates or updates the single institute record locally.
- Student create/edit form with admission number, name, optional phone, and optional parent/guardian.
- Student list and local search by name or admission number.
- Student deactivation/reactivation uses the existing active flag and retains the record.
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

## Step 8: Student editing and deactivation

- Existing student details can be opened and edited without creating a second row.
- Students can be deactivated and reactivated without deleting their record.
- The list separates active and inactive students with a toggle; inactive records remain searchable and recoverable.
- The updated timestamp changes when student details or active status changes.

## Step 9: Student management hardening

- Admission numbers are trimmed and normalized to uppercase before saving.
- The form checks for an existing admission number before saving and displays a clear duplicate message.
- Admission number, name, phone, and guardian fields enforce length limits in the form.
- Database tests cover normalization, duplicate detection, and allowing the current student to keep its own admission number while editing.
- Widget tests cover required-field validation and duplicate admission feedback.

## Step 10: Class and batch management\n\n- Classes/batches can be created, searched, edited, deactivated, and reactivated locally.\n- Each class has a name, academic year, optional description, and active status.\n- Class names are unique per academic year; students can optionally be assigned to a class or batch.\n- Database schema version 3 migrates existing student records without removing them.\n\n## Step 10: Class and batch management\n\n- Classes/batches can be created, searched, edited, deactivated, and reactivated locally.\n- Each class has a name, academic year, optional description, and active status.\n- Class names are unique per academic year; students can optionally be assigned to a class or batch.\n- Schema version 3 adds the classes table and nullable student class assignment while preserving existing student rows.\n\n## Not implemented yet

- Fee, payment allocation, discounts/credits, refund/reversal, and attendance workflows.
- Staff, salary, expenses, exams, results, and certificates.
- Offline PDF generation workflows.
- Managed files, backup/restore, and signed offline licensing.
- One-year license expiry, activation-time policy, and clock rollback handling.
- Entitlement guards and finalized role permissions.
- Production release signing and release APK.

## Validation

- Pull request CI must pass formatting, analysis, tests, Drift code generation, and Android debug APK build before merge.
- Do not treat a debug APK as a production release.
