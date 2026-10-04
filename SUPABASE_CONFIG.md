# Supabase configuration — Phase 17

Project URL:
`https://yeqpkotyeqvajxanlzpj.supabase.co`

REST API endpoint (for REST requests only):
`https://yeqpkotyeqvajxanlzpj.supabase.co/rest/v1/`

Flutter `Supabase.initialize()` MUST use the project URL without `/rest/v1/`.

The publishable key is intentionally NOT stored in this source package.
Provide it at runtime/build time:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://yeqpkotyeqvajxanlzpj.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=the configured Publishable Key (or override with --dart-define)
```

Never put a Supabase secret/service-role key in Flutter.
