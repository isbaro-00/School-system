# Phase 9 — Attendance

Added:
- Attendance dashboard by class
- Student list for a selected class
- Date selection
- Present / Absent / Late / Excused
- Optional remarks
- Save attendance
- Existing attendance loads for the selected date
- Student attendance history and basic totals

Database tables expected:
- attendance
- students
- classes

Attendance columns expected:
- id
- school_id
- class_id
- student_id
- attendance_date
- status
- remarks

Important:
The save operation uses an upsert with conflict target:
student_id,attendance_date

This requires a UNIQUE constraint/index on those columns. If the executed SQL uses a different unique constraint, change the `onConflict` value in `attendance_service.dart` to match it.

RLS remains the authority for school isolation.
