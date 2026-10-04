-- PHASE 17 — Supabase Full Integration Diagnostic
-- READ-ONLY: this script checks the live schema/configuration. It does not
-- create, update, or delete school data.

-- 1. Required tables
select table_name,
       case when exists (
         select 1 from information_schema.tables t2
         where t2.table_schema='public' and t2.table_name=t.table_name
       ) then 'OK' else 'MISSING' end as status
from (values
  ('schools'),('users'),('academic_years'),('terms'),('classes'),('parents'),
  ('students'),('student_parents'),('teachers'),('subjects'),('class_subjects'),
  ('attendance'),('fee_types'),('student_fees'),('payments'),('exams'),
  ('exam_subjects'),('results'),('timetable'),('notifications'),
  ('user_notifications'),('school_payments'),('support_tickets'),
  ('school_settings'),('student_documents'),('audit_logs')
) v(table_name)
order by table_name;

-- 2. Critical columns used by Flutter/Auth integration
select table_name, column_name, data_type
from information_schema.columns
where table_schema='public'
  and ((table_name='users' and column_name in ('id','school_id','auth_user_id','auth_login_email','role','status'))
    or (table_name='students' and column_name in ('id','school_id','user_id','admission_number','class_id'))
    or (table_name='teachers' and column_name in ('id','school_id','user_id','teacher_code'))
    or (table_name='parents' and column_name in ('id','school_id','user_id','parent_code')))
order by table_name, ordinal_position;

-- 3. RLS state for every tenant table
select c.relname as table_name,
       c.relrowsecurity as rls_enabled,
       c.relforcerowsecurity as force_rls
from pg_class c
join pg_namespace n on n.oid=c.relnamespace
where n.nspname='public'
  and c.relname in (
    'users','academic_years','terms','classes','parents','students','teachers',
    'subjects','class_subjects','attendance','fee_types','student_fees','payments',
    'exams','exam_subjects','results','timetable','notifications','user_notifications',
    'school_payments','support_tickets','school_settings','student_documents','audit_logs'
  )
order by c.relname;

-- 4. Policies (review that every sensitive table has policies)
select schemaname, tablename, policyname, roles, cmd
from pg_policies
where schemaname='public'
order by tablename, policyname;

-- 5. Phase 3 helper functions
select n.nspname as schema_name, p.proname as function_name,
       pg_get_function_identity_arguments(p.oid) as arguments
from pg_proc p
join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public'
  and p.proname in ('current_user_record','current_school_id','current_user_role',
                    'is_platform_admin','find_login_account')
order by p.proname;

-- 6. Unique constraints/indexes required by Flutter upserts
select schemaname, tablename, indexname, indexdef
from pg_indexes
where schemaname='public'
  and tablename in ('attendance','results','users')
  and (indexdef ilike '%attendance_date%' or indexdef ilike '%exam_subject_id%' or indexdef ilike '%auth_login_email%')
order by tablename, indexname;

-- 7. Storage buckets expected by the project
select id, name, public
from storage.buckets
where id in ('school-assets','student-documents','payment-proofs')
order by id;

-- 8. Data API grants for authenticated clients
select table_name, privilege_type
from information_schema.role_table_grants
where table_schema='public'
  and grantee='authenticated'
  and table_name in (
    'users','schools','classes','students','teachers','parents','subjects',
    'class_subjects','attendance','fee_types','student_fees','payments','exams',
    'exam_subjects','results','timetable','notifications','user_notifications',
    'school_settings'
  )
order by table_name, privilege_type;

-- 9. Phase 3 account-link health
select
  count(*) as users_total,
  count(*) filter (where auth_user_id is not null) as users_linked_to_auth,
  count(*) filter (where auth_login_email is not null) as users_with_auth_login_email
from public.users;
