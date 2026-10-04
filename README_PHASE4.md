
# Phase 4 — Role-Based Dashboards

This phase adds the first real dashboard architecture.

## Roles

- School Admin / Principal / Accountant → Admin dashboard
- Teacher → Teacher dashboard
- Student → Student dashboard
- Parent → Parent dashboard

## Security model

The Flutter app reads the current authenticated user's profile from `public.users`
using `auth_user_id = auth.currentUser.id`.

The app does NOT send a school_id from the client to decide which school data
to show. The database/RLS remains responsible for school isolation.

## Important

The dashboard cards are navigation placeholders. The next phase will connect
each module to its actual Supabase table and add real counts/data.

Do not remove or weaken RLS to make a query work. If a query fails because of
RLS, fix the policy on the database side.
