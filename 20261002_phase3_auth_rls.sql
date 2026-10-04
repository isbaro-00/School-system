
-- PHASE 3
-- Supabase Auth <-> public.users + RLS recursion fix.
-- Run after the original School Management System schema.

create extension if not exists pgcrypto;

-- 1) Internal login email used by Supabase Auth.
-- Real school email/phone stays in users.email/users.phone.
alter table public.users
  add column if not exists auth_login_email text;

create unique index if not exists users_auth_login_email_uidx
  on public.users(auth_login_email)
  where auth_login_email is not null;

-- 2) Generate a stable internal Auth email for users who do not have
-- a suitable login email. This address is only for Supabase Auth.
create or replace function public.make_auth_login_email()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.auth_login_email is null or btrim(new.auth_login_email) = '' then
    new.auth_login_email :=
      'u-' || replace(new.id::text, '-', '') || '@accounts.school-system.invalid';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_users_auth_login_email on public.users;
create trigger trg_users_auth_login_email
before insert or update of id, auth_login_email on public.users
for each row execute function public.make_auth_login_email();

-- Backfill existing users.
update public.users
set auth_login_email =
  'u-' || replace(id::text, '-', '') || '@accounts.school-system.invalid'
where auth_login_email is null or btrim(auth_login_email) = '';

-- 3) SECURITY DEFINER helper functions.
-- They read users without recursively invoking the users RLS policy.
create or replace function public.current_user_record()
returns public.users
language sql
stable
security definer
set search_path = public
as $$
  select u.*
  from public.users u
  where u.auth_user_id = auth.uid()
  limit 1;
$$;

create or replace function public.current_school_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select u.school_id
  from public.users u
  where u.auth_user_id = auth.uid()
  limit 1;
$$;

create or replace function public.current_user_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select u.role::text
  from public.users u
  where u.auth_user_id = auth.uid()
  limit 1;
$$;

create or replace function public.is_platform_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.platform_admins pa
    where lower(pa.email) = lower(
      coalesce((select email from auth.users where id = auth.uid()), '')
    )
  );
$$;

-- 4) Replace users policies to avoid recursive evaluation.
alter table public.users enable row level security;

drop policy if exists "users own school" on public.users;
drop policy if exists "users can view own profile" on public.users;
drop policy if exists "users platform admin" on public.users;

create policy "users self or same school"
on public.users
for select
to authenticated
using (
  auth_user_id = auth.uid()
  or school_id = public.current_school_id()
  or public.is_platform_admin()
);

create policy "users update own profile"
on public.users
for update
to authenticated
using (auth_user_id = auth.uid())
with check (auth_user_id = auth.uid());

-- Do not allow normal client inserts into users.
-- Account creation is handled by the backend function.

-- 5) Strong tenant-isolation policies for the main school tables.
-- These policies use the SECURITY DEFINER current_school_id() helper.

do $$
declare
  t text;
begin
  foreach t in array array[
    'academic_years',
    'terms',
    'classes',
    'parents',
    'students',
    'teachers',
    'subjects',
    'class_subjects',
    'attendance',
    'fee_types',
    'student_fees',
    'payments',
    'exams',
    'exam_subjects',
    'results',
    'timetable',
    'notifications',
    'user_notifications',
    'school_payments',
    'support_tickets',
    'school_settings',
    'student_documents',
    'audit_logs'
  ]
  loop
    execute format('alter table public.%I enable row level security', t);
  end loop;
end $$;

-- The exact role/action rules for each module remain in the original schema.
-- These baseline policies make sure a normal authenticated user cannot cross
-- school boundaries. Existing more-specific policies can be reviewed after
-- this migration.

drop policy if exists "tenant select" on public.students;
create policy "tenant select" on public.students
for select to authenticated
using (
  school_id = public.current_school_id()
  or public.is_platform_admin()
);

drop policy if exists "tenant select" on public.teachers;
create policy "tenant select" on public.teachers
for select to authenticated
using (
  school_id = public.current_school_id()
  or public.is_platform_admin()
);

drop policy if exists "tenant select" on public.parents;
create policy "tenant select" on public.parents
for select to authenticated
using (
  school_id = public.current_school_id()
  or public.is_platform_admin()
);

-- 6) Helper used by Edge Functions to verify an account.
-- SECURITY DEFINER means the public client never gets broad table access.
create or replace function public.find_login_account(
  p_school_access_code text,
  p_account_type text,
  p_identifier text
)
returns table (
  user_id uuid,
  school_id uuid,
  auth_login_email text,
  display_name text,
  role text,
  already_activated boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_school_id uuid;
begin
  select s.id into v_school_id
  from public.schools s
  where upper(s.school_access_code) = upper(btrim(p_school_access_code))
    and s.status = 'active'
  limit 1;

  if v_school_id is null then
    return;
  end if;

  if p_account_type = 'student' then
    return query
    select u.id, u.school_id, u.auth_login_email,
           concat_ws(' ', s.first_name, s.middle_name, s.last_name),
           u.role::text,
           (u.auth_user_id is not null)
    from public.students s
    join public.users u on u.id = s.user_id
    where s.school_id = v_school_id
      and upper(s.admission_number) = upper(btrim(p_identifier))
      and u.status = 'active'
    limit 1;

  elsif p_account_type = 'teacher' then
    return query
    select u.id, u.school_id, u.auth_login_email,
           u.full_name,
           u.role::text,
           (u.auth_user_id is not null)
    from public.teachers t
    join public.users u on u.id = t.user_id
    where t.school_id = v_school_id
      and upper(t.teacher_code) = upper(btrim(p_identifier))
      and u.status = 'active'
    limit 1;

  elsif p_account_type = 'parent' then
    return query
    select u.id, u.school_id, u.auth_login_email,
           u.full_name,
           u.role::text,
           (u.auth_user_id is not null)
    from public.parents p
    join public.users u on u.id = p.user_id
    where p.school_id = v_school_id
      and upper(p.parent_code) = upper(btrim(p_identifier))
      and u.status = 'active'
    limit 1;

  elsif p_account_type = 'school_admin' then
    return query
    select u.id, u.school_id, u.auth_login_email,
           u.full_name,
           u.role::text,
           (u.auth_user_id is not null)
    from public.users u
    where u.school_id = v_school_id
      and (
        lower(coalesce(u.email, '')) = lower(btrim(p_identifier))
        or regexp_replace(coalesce(u.phone, ''), '\D', '', 'g')
           = regexp_replace(btrim(p_identifier), '\D', '', 'g')
      )
      and u.role in ('school_admin', 'principal', 'accountant')
      and u.status = 'active'
    limit 1;
  end if;
end;
$$;

revoke all on function public.find_login_account(text,text,text) from public;
grant execute on function public.find_login_account(text,text,text) to service_role;

-- 7) Ensure clients can read only their own authenticated users row.
-- The backend creates/links users.auth_user_id.

-- IMPORTANT:
-- This migration fixes the known users/current_school_id recursion problem.
-- Test RLS with two separate schools before production.
