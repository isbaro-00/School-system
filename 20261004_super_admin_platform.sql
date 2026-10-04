-- SUPER ADMIN PLATFORM CONTROL
-- Run after the existing School Management schema + Phase 3 auth/RLS migration.

create table if not exists public.platform_admins (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  status text not null default 'active' check (status in ('active','inactive')),
  created_at timestamptz not null default now()
);

alter table public.platform_admins enable row level security;

drop policy if exists "platform admins self" on public.platform_admins;
create policy "platform admins self"
on public.platform_admins
for select to authenticated
using (lower(email) = lower(coalesce((select email from auth.users where id = auth.uid()), '')));

-- Replace/extend the existing helper so platform-admin status is the single gate.
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
      and pa.status = 'active'
  );
$$;

revoke all on function public.is_platform_admin() from public;
grant execute on function public.is_platform_admin() to authenticated;

-- Platform admins can manage the school-level records from the Super Admin app.
-- Normal school users remain restricted by their own school policies.
alter table public.schools enable row level security;

drop policy if exists "platform admins manage schools" on public.schools;
create policy "platform admins manage schools"
on public.schools
for all to authenticated
using (public.is_platform_admin())
with check (public.is_platform_admin());

-- Platform-admin school creation is done through this SECURITY DEFINER RPC,
-- so the Flutter client never needs INSERT permission on users.
create or replace function public.platform_create_school(
  p_name text,
  p_admin_name text,
  p_email text,
  p_phone text,
  p_location text,
  p_subscription_plan text,
  p_subscription_start timestamptz,
  p_subscription_end timestamptz
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_school_id uuid;
  v_school_code text;
  v_access_code text;
  v_user_id uuid;
  v_auth_email text;
  v_result jsonb;
begin
  if not public.is_platform_admin() then
    raise exception 'Only platform administrators can create schools';
  end if;

  if nullif(btrim(p_name), '') is null
     or nullif(btrim(p_admin_name), '') is null
     or nullif(btrim(p_email), '') is null then
    raise exception 'School name, admin name and email are required';
  end if;

  -- Generate collision-safe school code.
  loop
    v_school_code := 'SCH-' || lpad((floor(random() * 900000 + 100000))::int::text, 6, '0');
    exit when not exists (select 1 from public.schools where school_code = v_school_code);
  end loop;

  -- Generate collision-safe access code.
  loop
    v_access_code := 'AC-' || upper(substr(encode(gen_random_bytes(6), 'hex'), 1, 6));
    exit when not exists (select 1 from public.schools where school_access_code = v_access_code);
  end loop;

  insert into public.schools (
    school_code,
    school_access_code,
    name,
    admin_name,
    email,
    phone,
    location,
    subscription_plan,
    subscription_start,
    subscription_end,
    status
  ) values (
    v_school_code,
    v_access_code,
    btrim(p_name),
    btrim(p_admin_name),
    lower(btrim(p_email)),
    nullif(btrim(p_phone), ''),
    nullif(btrim(p_location), ''),
    coalesce(nullif(btrim(p_subscription_plan), ''), 'Standard'),
    p_subscription_start,
    p_subscription_end,
    'active'
  ) returning id into v_school_id;

  -- The admin is created as a normal school user, but Auth is not created here.
  -- On first login/setup, setup-account creates the Auth account and links it.
  insert into public.users (
    school_id,
    email,
    phone,
    full_name,
    role,
    status
  ) values (
    v_school_id,
    lower(btrim(p_email)),
    nullif(btrim(p_phone), ''),
    btrim(p_admin_name),
    'school_admin',
    'active'
  ) returning id, auth_login_email into v_user_id, v_auth_email;

  v_result := jsonb_build_object(
    'school_id', v_school_id,
    'school_code', v_school_code,
    'school_access_code', v_access_code,
    'admin_user_id', v_user_id,
    'auth_login_email', v_auth_email
  );

  return v_result;
exception when others then
  raise;
end;
$$;

revoke all on function public.platform_create_school(text,text,text,text,text,text,timestamptz,timestamptz) from public;
grant execute on function public.platform_create_school(text,text,text,text,text,text,timestamptz,timestamptz) to authenticated;

-- Platform admins may update school status from the app; the policy above covers it.
