@echo off
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter SDK is not installed or not on PATH.
  exit /b 1
)
flutter create . --platforms=android --org=com.schoolmanagement
if errorlevel 1 exit /b 1
flutter pub get
if errorlevel 1 exit /b 1
echo Android platform generated successfully.
echo Build with:
echo flutter build apk --release --dart-define=SUPABASE_URL=https://yeqpkotyeqvajxanlzpj.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
