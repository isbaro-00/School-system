# Phase 15 — Settings + Super Admin

Added school-side settings:
- Settings dashboard
- School profile settings
- Academic settings
- Security information

Added Super Admin foundation:
- Platform overview
- Schools list
- School payments list
- Support tickets list

Important:
1. Super Admin data must be protected by database RLS/policies. The Flutter UI is not a security boundary.
2. The platform owner email configured in the database is the authority for Super Admin access.
3. Exact column names in `schools`, `school_settings`, `school_payments`, and `support_tickets` must match the SQL actually running in Supabase.
4. This phase intentionally does not put service-role keys in Flutter.
5. Advanced actions such as approving schools, changing subscriptions, resolving tickets, and managing platform users should be implemented through secure backend/Edge Functions with authorization checks.
