# Security Integration Checklist

This file is a manual test checklist for Supabase.

## Cross-school read

1. Sign in as a School A user.
2. Query School B student IDs directly.
3. Confirm RLS denies or returns no unauthorized rows.

Repeat for:
- users
- students
- teachers
- parents
- classes
- subjects
- attendance
- fee_types
- student_fees
- payments
- exams
- exam_subjects
- results
- timetable
- notifications
- user_notifications
- student_documents
- school_settings

## Cross-school write

Attempt to insert/update a row with another school's `school_id`.

Expected:
- The operation must be denied by RLS/constraints/backend authorization.

## Super Admin

Confirm that only the intended platform administrator can access platform-wide data.

Do not test this by putting a service-role key into the app.

## Storage

Test that an authenticated user from School A cannot download private files belonging to School B.

If storage policies are path-based, verify the path contains a trusted school identifier and the policy validates it server-side.

## Auth

Test expired sessions, logout, wrong credentials, password reset and account creation.

## Important

If any cross-school test succeeds unexpectedly, stop release and fix RLS/backend authorization before APK deployment.
