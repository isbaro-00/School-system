# Phase 12 — Timetable

Added:
- Timetable dashboard
- Filter timetable by class
- Add timetable period
- Day selection
- Start/end time
- Subject and teacher references
- Optional room
- Delete timetable entry
- Student timetable viewer

Database table expected:
- timetable

Expected fields:
- id
- school_id
- class_id
- subject_id
- teacher_id
- day_of_week
- start_time
- end_time
- room

Important:
1. `day_of_week` is treated as 0=Sunday through 6=Saturday in this Flutter phase.
2. Subject ID and Teacher ID are currently entered as IDs in the add form. A later integration can replace them with searchable dropdowns from the Subjects/Teachers tables.
3. Verify exact time column types and names against the SQL already executed in Supabase.
4. RLS remains the authority for school isolation.
