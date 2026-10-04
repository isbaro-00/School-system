-- Super Admin -> create school + school admin Auth account
-- Run this in Supabase SQL Editor.

create or replace function public.platform_create_school_internal(
  p_name text,
  p_admin_name text,
  p_email text,
  p_phone text,
  p_location text,
  p_subscription_plan text,
  p_subscription_start date,
  p_subscription_end date,
  p_auth_user_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_school_id uuid;
  v_user_id uuid;
  v_school_code text;
  v_access_code text;
begin
  if nullif(trim(p_name), '') is null then raise exception 'School name is required'; end if;
  if nullif(trim(p_admin_name), '') is null then raise exception 'Admin name is required'; end if;
  if nullif(trim(p_email), '') is null then raise exception 'Admin email is required'; end if;

  loop
    v_school_code := 'SCH-' || lpad((floor(random() * 900000) + 100000)::int::text, 6, '0');
    exit when not exists (select 1 from public.schools where school_code = v_school_code);
  end loop;

  loop
    v_access_code := 'ACC-' || upper(substr(encode(gen_random_bytes(4), 'hex'), 1, 8));
    exit when not exists (select 1 from public.schools where school_access_code = v_access_code);
  end loop;

  insert into public.schools (
    school_code, school_access_code, name, admin_name, email, phone, location,
    subscription_plan, subscription_start, subscription_end, status
  ) values (
    v_school_code, v_access_code, trim(p_name), trim(p_admin_name), lower(trim(p_email)),
    nullif(trim(p_phone), ''), nullif(trim(p_location), ''),
    coalesce(nullif(trim(p_subscription_plan), ''), 'Standard'),
    p_subscription_start, p_subscription_end, 'active'
  ) returning id into v_school_id;

  insert into public.users (
    auth_user_id, school_id, email, phone, full_name, role, status
  ) values (
    p_auth_user_id, v_school_id, lower(trim(p_email)), nullif(trim(p_phone), ''),
    trim(p_admin_name), 'school_admin', 'active'
  ) returning id into v_user_id;

  return jsonb_build_object(
    'success', true,
    'school_id', v_school_id,
    'user_id', v_user_id,
    'auth_user_id', p_auth_user_id,
    'school_code', v_school_code,
    'school_access_code', v_access_code,
    'status', 'active'
  );
end;
$$;

revoke all on function public.platform_create_school_internal(
  text, text, text, text, text, text, text, uuid
) from public;

grant execute on function public.platform_create_school_internal(
  text, text, text, text, text, text, text, uuid
) to service_role;
