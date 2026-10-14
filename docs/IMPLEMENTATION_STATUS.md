# EduManage Offline implementation status

## Completed foundation

- Flutter app entry point with Riverpod and GoRouter.
- Material 3 navy/teal theme and institute setup.
- Drift/SQLite local database for institute, student, class, and batch records.
- Schema migrations preserve existing institute and student records when class and batch tables are introduced.
- Student create/edit, local search, admission-number normalization, duplicate feedback, and deactivate/reactivate.
- Class create/edit, search, academic-year association, duplicate checks, and deactivate/reactivate.
- Class-scoped batch create/edit, subject, timing, teacher, monthly fee stored as integer paise, and archive/restore.
- Database and widget tests; CI must pass before each feature PR is merged.

## Step 6: Institute setup and persistence

- Required fields: institute name and academic year.
- Optional field: phone number.
- Values are trimmed and saved to local SQLite; editing updates the existing institute record instead of adding another.

## Step 7: Student management foundation

- Student admission number is unique in SQLite.
- Required fields: admission number and student name; phone and guardian are optional.
- Students can be listed and searched locally by name/admission number.
- Schema upgrade from version 1 creates the student table without recreating institute data.

## Step 8: Student editing and deactivation

- Existing student details can be edited without creating a second row.
- Students can be deactivated/reactivated without deleting their records.
- Inactive students remain searchable and recoverable.

## Step 9: Student management hardening

- Admission numbers are trimmed and normalized to uppercase before saving.
- The form checks for an existing admission number and displays clear duplicate feedback.
- Form fields enforce length limits; database and widget tests cover validation and duplicate handling.

## Step 10: Class and batch management

- Classes have a name, academic year, optional description, and active status.
- Class names are unique within an academic year; class records can be deactivated/reactivated rather than deleted.
- Each batch belongs to one class and includes a name plus optional subject, timing, teacher, and monthly fee.
- Monthly fees are stored as integer paise; duplicate batch names are checked within the parent class.
- Archived batch records remain in the database. Student assignment is currently class-level; effective-dated batch assignment and transfer history remain future work.

## Not implemented yet

- Effective-dated student class/batch assignment and transfer history.
- Fee charges, payments, payment allocation, discounts/credits, refund/reversal, and attendance workflows.
- Staff, salary, expenses, exams, results, and certificates.
- Offline PDF generation workflows.
- Managed files, backup/restore, and signed offline licensing.
- One-year license expiry, activation-time policy, and clock rollback handling.
- Entitlement guards and finalized role permissions.
- Production release signing and release APK.

## Validation

- Pull request CI must pass formatting, analysis, tests, Drift code generation, and Android debug APK build before merge.
- A debug APK is not a production release.
