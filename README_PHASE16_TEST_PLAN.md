# Phase 16 — Testing Plan

Run the following before production/APK release.

## 1. Flutter checks

From the Flutter project:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Fix every analyzer error and failing test before release.

## 2. Authentication tests

Test:
- Admin login
- Teacher login
- Student login
- Parent login
- Wrong password
- Invalid School Access Code
- Wrong account code
- Logout
- Session restoration
- Password reset

Expected:
- A School Access Code identifies the school but does not grant access by itself.
- Users can only access the records permitted by their role and school.

## 3. School isolation test

Create School A and School B.

While authenticated as School A:
- Students must only show School A students.
- Teachers must only show School A teachers.
- Parents must only show School A parents.
- Attendance, fees, exams, timetable, notifications and reports must not expose School B data.

Repeat as School B.

This is a critical RLS test.

## 4. Core module tests

Students:
- Create
- View
- Edit
- Admission number generation

Teachers:
- Create
- View
- Teacher code generation

Parents:
- Create
- Link child
- View children

Classes/Subjects:
- Create class
- Create subject
- Assign subject

Attendance:
- Take attendance
- Update attendance
- View history

Fees:
- Create fee type
- Assign fee
- Record payment
- Check balance/payment automation

Exams:
- Create exam
- Add exam subject
- Enter marks
- View results
- Verify grade calculation

Timetable:
- Add period
- Filter by class
- Student timetable

Notifications:
- Create notification
- User notification
- Read/unread

Reports:
- Students
- Attendance
- Finance
- Results

Settings:
- School profile
- Academic settings
- Security

Super Admin:
- Schools
- School payments
- Support tickets

## 5. Security tests

Never put:
- Supabase service-role key
- Database password
- Other server secrets

inside Flutter.

Check:
- RLS enabled on every school-data table.
- RLS policies do not allow cross-school reads/writes.
- Super Admin policies are separate and restricted.
- Storage policies do not expose another school's private files.
- Edge Functions validate authorization server-side.

## 6. Database tests

Check:
- Foreign keys
- Unique constraints
- Required fields
- Code generators
- Updated-at triggers
- Payment automation
- Grade calculation
- Audit logs

Pay special attention to Flutter upserts:
- Attendance uses student_id + attendance_date.
- Results uses exam_id + exam_subject_id + student_id.

The matching database uniqueness constraints must exist.

## 7. Device/UI tests

Test:
- Small Android phone
- Larger Android phone
- Slow network
- No network
- Loading states
- Empty states
- Error states
- Keyboard/form behavior
- Rotation if supported
- Dark/light mode if enabled

## 8. Release gate

Do not move to Phase 17 until:
- `flutter analyze` passes
- `flutter test` passes
- Debug APK builds
- Auth works
- RLS isolation passes
- Core modules pass
- No secrets are bundled
- Critical errors are fixed
