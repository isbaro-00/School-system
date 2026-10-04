
# Phase 5 — Students Module

Added:

- Student list
- Student search-ready service layer
- Add Student
- Automatic database-generated Admission Number support
- Student profile
- School-scoped queries

Important:
The Flutter code does not generate admission numbers itself. The database
generator/trigger remains responsible for the official admission number.

RLS:
Queries include school_id for clarity, but database RLS remains the real
security boundary. Do not weaken RLS if a query is denied.

Next:
Teacher module → Parents → Classes/Subjects → Attendance → Fees → Exams.
