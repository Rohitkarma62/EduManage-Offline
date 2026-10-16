# EduManage Offline implementation status

## Completed foundation

- Flutter app entry point with Riverpod and GoRouter.
- Material 3 navy/teal theme and institute setup.
- Drift/SQLite local database for institute, student, class, batch, fee charges, and fee payments.
- Schema migrations preserve existing institute and student records when class and batch tables are introduced.
- Student create/edit, local search, admission-number normalization, duplicate feedback, and deactivate/reactivate.
- Class create/edit, search, academic-year association, duplicate checks, and deactivate/reactivate.
- Class-scoped batch create/edit, subject, timing, teacher, monthly fee stored as integer paise, and archive/restore.
- Fee charge creation tied to a student's current historical assignment.
- Fee payment entry with partial payments, supported payment methods, optional reference, duplicate-safe database idempotency, payment history, and paid/balance summaries.
- Offline PDF receipts for recorded payments, including institute/student details, fee period, payment method/reference, receipt number, and current outstanding balance; receipts can be printed or shared.
- Daily attendance entry for active students with Present/Absent/Leave statuses, date navigation, local persistence, and daily counts.
- Database and widget tests; CI must pass formatting, analysis, tests, Drift code generation, and Android debug APK build before merge.

## Institute setup and persistence

- Required fields: institute name and academic year.
- Optional field: phone number.
- Values are trimmed and saved to local SQLite; editing updates the existing institute record instead of adding another.

## Student management

- Student admission number is unique in SQLite.
- Required fields: admission number and student name; phone and guardian are optional.
- Students can be listed and searched locally by name/admission number.
- Students can be deactivated/reactivated without deleting their records.
- Admission numbers are trimmed and normalized to uppercase before saving.
- Form fields enforce length limits; database and widget tests cover validation and duplicate handling.

## Class and batch management

- Classes have a name, academic year, optional description, and active status.
- Class names are unique within an academic year; class records can be deactivated/reactivated rather than deleted.
- Each batch belongs to one class and includes a name plus optional subject, timing, teacher, and monthly fee.
- Monthly fees are stored as integer paise; duplicate batch names are checked within the parent class.
- Archived batch records remain in the database.

## Student assignment and transfer history

- Student assignments are effective-dated and preserve assignment history.
- Existing student assignments are backfilled through the schema migration.
- Assignment and transfer history is available in the student UI.
- The transfer form supports selecting an active class and optional batch, an effective date, and a required reason.
- No-op transfers are blocked, and same-day transfers are rejected according to assignment-history rules.
- Transfer and assignment-history behavior is covered by database and widget tests.

## Fee workflow scope and follow-ups

- Current UI supports fee charge creation, payment recording, partial payment history, and outstanding balance display.
- Payment amounts are stored as integer paise; the UI locks payment submission while a dialog/write is active, and the database re-checks the outstanding balance transactionally to reject overpayments.
- Refunds/reversals, payment allocation across multiple charges, discounts/credits, and fee reminders are not implemented yet.

## Not implemented yet

- Attendance reports by class/batch and date range, plus attendance percentage summaries.
- Staff, salary, expenses, exams, results, and certificates.
- General-purpose app-managed file storage and backup/restore of generated documents.
- Backup/restore and signed offline licensing.
- One-year license expiry, activation-time policy, and clock rollback handling.
- Entitlement guards and finalized role permissions.
- Production release signing and release APK.

## Validation

- Pull request CI must pass formatting, analysis, tests, Drift code generation, and Android debug APK build before merge.
- A debug APK is not a production release.
