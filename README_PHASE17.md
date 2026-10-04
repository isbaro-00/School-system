# Phase 17 — Supabase Full Integration & Testing

This package keeps the existing Phase 1–16 source and completes the client-side onboarding flow.

## Supabase project

- Project URL: `https://yeqpkotyeqvajxanlzpj.supabase.co`
- REST endpoint: `https://yeqpkotyeqvajxanlzpj.supabase.co/rest/v1/`
- Flutter initialization uses the project URL, not the REST endpoint.
- Publishable key is supplied at runtime; it is not committed to source.

## What was completed

- Flutter Supabase initialization configuration.
- School Access Code → account identifier → server verification.
- Real `setup-account` Edge Function call from the password screen.
- Real Supabase Auth sign-in after account setup.
- Existing activated accounts can sign in using their returned internal Auth email.
- Existing `resolve-account`, `verify-school-account`, and `setup-account` Edge Functions remain in the project.
- Phase 17 read-only diagnostic SQL is included.
- Security test checklist is included.

## Important

A source package cannot prove that the live Supabase project is fully working until the Edge Functions are deployed and the diagnostic SQL/tests are run against the project.

## Run

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://yeqpkotyeqvajxanlzpj.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=the configured Publishable Key (or override with --dart-define)
```

Do not use a service-role/secret key in Flutter.
