# Phase 16 — Testing

This phase is a testing package rather than a new feature module.

Included:
- Flutter test checklist
- Basic automated tests
- Payment total test
- Security/RLS integration checklist
- Release gate

Recommended commands:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Important:
- Testing cannot prove security from the Flutter UI alone.
- Supabase RLS must be tested with real authenticated users from at least two schools.
- Storage isolation must also be tested.
- Do not place service-role or database secrets in Flutter.
- Phase 17 should only start after the release gate passes.
