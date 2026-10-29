# LuxeChat

A colorful-luxury, Android-first Flutter messaging app starter. This repository currently implements **email/password authentication and a shared authenticated community lobby** using Supabase. It is an MVP foundation, not a finished WhatsApp/Discord replacement.

## Implemented in this starter

- Flutter Android app with colorful luxury theme
- Supabase email/password sign-up and sign-in
- Display name stored in auth user metadata
- Live lobby message stream and message sending
- 2,000-character message limit and basic form validation
- Sign-out flow and user-visible network/backend errors
- Supabase Row Level Security (RLS) policy for lobby messages
- Unit/widget tests and GitHub Actions CI workflow

## Not implemented yet

Private one-to-one chats, group creation, media uploads, push notifications, voice/video calls, blocking/reporting, end-to-end encryption, moderation tools, and production monitoring. The lobby is visible to all authenticated users in the same Supabase project. Do not use it for sensitive/private conversations.

## Requirements

- Flutter stable SDK (see https://docs.flutter.dev/get-started/install)
- Android Studio or Android SDK + a device/emulator
- A Supabase project (https://supabase.com)
- Git and a GitHub account

## 1. Create the Supabase backend

1. Create a Supabase project.
2. Open **SQL Editor** and run `supabase/schema.sql`.
3. In **Authentication > Providers**, enable Email. Configure email confirmation according to your needs.
4. In **Database > Publications**, add `public.messages` to `supabase_realtime` so new messages stream live.
5. Copy the project URL and **anon/public key** from Project Settings > API. Never use the `service_role` key in a mobile app or commit it to Git.

The RLS policies permit authenticated users to read lobby messages and insert messages only with their own `sender_id`. The display name is client supplied in this MVP, so it is not a verified identity; do not use it for authorization. For a public launch, move sender-name authority into a database trigger/profile table, add rate limits and moderation, and review RLS with security tests.

## 2. Generate Android runner and run

This source-first archive does not include Flutter-generated Android Gradle wrapper binaries. After installing Flutter, run the following once from the repository root to generate the Android platform runner, then run the app:

```bash
flutter create --platforms=android .
```

Then run from the repository root:

```bash
flutter doctor
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

Replace both placeholders. The public anon key is designed to be used by clients when RLS is correctly configured. **Never** pass a Supabase service-role key to `--dart-define`.

If you want to build an APK:

```bash
flutter build apk --release --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

The output should be at `build/app/outputs/flutter-apk/app-release.apk` after a successful build.

## 3. Run checks locally

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test --coverage
```

Tests included:
- `test/chat_message_test.dart`: message parsing and fallback values
- `test/widget_test.dart`: honest unconfigured-backend setup screen

The CI workflow repeats formatting checks, static analysis, and tests on pushes and pull requests. CI does not prove live Supabase integration; test against a dedicated non-production Supabase project before release.

## 4. Publish the source to GitHub

Create an empty repository on GitHub, then run from this folder:

```bash
git init
git add .
git commit -m "Initial LuxeChat Android MVP"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/LuxeChat.git
git push -u origin main
```

GitHub stores the source and runs CI. It does **not** host the Supabase database or make the app live by itself. Keep project credentials out of commits. The app receives its public Supabase URL/key at build time; for public release, plan a controlled build process and review the repository for secrets before pushing.

## Security and launch checklist

- [ ] Run `supabase/schema.sql` and verify RLS is enabled.
- [ ] Test read/insert policies with two separate test accounts.
- [ ] Confirm anonymous users cannot read or insert messages.
- [ ] Confirm one user cannot insert a message with another user's `sender_id`.
- [ ] Add server-side rate limiting / anti-spam controls.
- [ ] Add moderation, report/block, deletion, privacy policy, and account deletion.
- [ ] Add crash/error monitoring and backups appropriate to the service.
- [ ] Test on physical Android devices and weak networks.
- [ ] Review data collection, age requirements, and applicable laws before public release.
- [ ] Consider end-to-end encryption only with a reviewed protocol and implementation; this starter does not provide it.

## Project layout

```text
lib/
  main.dart
  models/chat_message.dart
  screens/auth_screen.dart
  screens/chat_screen.dart
  services/chat_service.dart
supabase/schema.sql
test/
  chat_message_test.dart
  widget_test.dart
.github/workflows/flutter-ci.yml
```

## License

No license is granted by default. Add a license file if you want to permit reuse or redistribution.
