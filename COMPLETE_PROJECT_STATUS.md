# Reconstructed Phase 1–16 Project

This archive was reconstructed from the available Phase 1 through Phase 16 incremental ZIP files.

## Important limitation
The original incremental archives did NOT contain Flutter platform folders such as `android/`, `ios/`, `web/`, or `windows/`. Therefore this reconstruction contains the available Flutter/Dart source, tests, Supabase functions/migrations, and project metadata, but it is NOT a fully generated Flutter platform project yet.

The next AI should NOT pretend that `android/` already exists. It should inspect the source and, if needed, run `flutter create .` in a real Flutter environment to generate missing platform scaffolding without replacing the existing `lib/` source.

Do not add fake credentials or service-role keys.
