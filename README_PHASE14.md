# Phase 14 — Reports

Added:
- Reports dashboard
- Students report
- Attendance report with date filters
- Finance/payment report with date filters
- Results report

Important:
1. This phase is the Flutter reporting foundation.
2. Export to PDF/Excel can be added later after the report queries are confirmed.
3. Exact payment/result/attendance columns must match the SQL actually running in Supabase.
4. RLS remains the authority for school isolation.
5. For production, larger reports should preferably use database views/RPCs or server-side pagination instead of loading huge datasets into the mobile app.
