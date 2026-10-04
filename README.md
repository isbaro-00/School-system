
# School Management System — Phase 3

## What this phase does

This phase connects:

- Supabase Auth
- public.users.auth_user_id
- Student Admission Number
- Teacher Code
- Parent Code
- School/Admin email or phone
- School Access Code
- secure Edge Functions
- the first RLS recursion fix

## Important security design

The Flutter app uses only the Supabase publishable key.

The privileged Supabase secret/service-role capability stays inside Edge Functions. Supabase documents secret keys as server-only because they bypass RLS.

## Files

- `supabase/migrations/20261002_phase3_auth_rls.sql`
- `supabase/functions/setup-account/index.ts`
- `supabase/functions/resolve-account/index.ts`
- `lib/core/services/auth_service.dart`

## Integration order

1. Run the migration in Supabase SQL Editor.
2. Deploy `resolve-account`.
3. Deploy `setup-account`.
4. Copy `auth_service.dart` into the Flutter project.
5. Update the Phase 2 password screen to call `setupAccount()`.
6. After setup succeeds, call `signIn()`.
7. Load the authenticated `public.users` row.
8. Route the user to the correct dashboard.
9. Test RLS using two different schools.

Do not put any secret/service-role key in Flutter.

## Super Admin school creation with Auth
Run `supabase/migrations/20261004_super_admin_auth_registration.sql` in Supabase SQL Editor, then deploy the `create-school-admin` Edge Function. The Flutter Super Admin Create School screen now sends school/admin creation to that Edge Function. The Service Role key stays server-side in Supabase and is never embedded in the APK.
