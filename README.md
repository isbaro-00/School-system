# Phase 17 Supabase Integration Tests

Run `supabase/PHASE17_DIAGNOSTIC.sql` in the Supabase SQL Editor first.

Then deploy the three onboarding functions and test these cases:

1. Valid School Access Code + valid Student Admission Number -> account found.
2. Valid school + wrong admission number -> rejected.
3. Valid school A + student from school B -> rejected.
4. Unactivated account -> setup required.
5. Activated account -> sign-in email returned, then normal Auth password sign-in.
6. Second setup attempt -> rejected as already activated.
7. Authenticated school A user cannot read school B rows through the Data API.
8. Student/teacher/parent records cannot be read across schools.
9. Attendance/result upserts work only within the current school.
10. Storage access is tested separately for school A/B before production.

Never put a Supabase secret/service-role key in Flutter or in this repository.
