# Phase 8 — Classes & Subjects

Added:
- Classes list
- Add class
- Class profile
- Subjects list
- Add subject
- Class-subject relationship service
- View assigned subjects for a class

Database tables used:
- classes
- subjects
- class_subjects
- academic_years (field supported by service when needed)
- teachers (teacher assignment field supported)

Important:
- `school_id` is passed to school-level list/create operations.
- RLS remains the database authority for school isolation.
- This phase does not yet add a full UI for assigning subjects/teachers to classes; the service method is included for the next integration step.
- Verify your exact `classes`, `subjects`, and `class_subjects` columns match the SQL that was executed in Supabase.
