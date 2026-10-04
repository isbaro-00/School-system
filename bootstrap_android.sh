#!/usr/bin/env bash
set -euo pipefail

# Run this from the Flutter project root.
# Generates the Android platform files using the Flutter SDK installed on the machine.
if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK is not installed or not on PATH."
  exit 1
fi

flutter create . --platforms=android --org=com.schoolmanagement

echo "Android platform generated successfully."
echo "Next: flutter pub get"
echo "Then build with:"
echo "flutter build apk --release --dart-define=SUPABASE_URL=https://yeqpkotyeqvajxanlzpj.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY"
