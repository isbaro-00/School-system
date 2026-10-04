# Super Admin V2

This version changes school creation to a secure Supabase RPC.

## What changed
- Super Admin can create a school from the app.
- School + school-admin user are created together by `platform_create_school`.
- Flutter no longer inserts directly into `schools` or `users` for school creation.
- Only emails listed in `platform_admins` with `status='active'` can use the RPC.
- School status can be Active/Inactive.

## Supabase step
Run:
`supabase/migrations/20261004_super_admin_platform.sql`

Then add your own authenticated Super Admin email to `public.platform_admins` in SQL Editor:

```sql
insert into public.platform_admins (email)
values ('YOUR_SUPER_ADMIN_EMAIL');
```

Use the same email as the Supabase Auth account you use to sign in as Super Admin.

Do NOT put a service-role/secret key in Flutter, GitHub, or the APK.


## Create School + Supabase

The Create School screen calls the `platform_create_school` PostgreSQL function through Supabase RPC. Subscription dates are sent as `YYYY-MM-DD` values because the database columns are `date`. The app never contains a Service Role key. The signed-in account must be a platform admin.
