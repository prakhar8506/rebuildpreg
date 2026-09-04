# Mira

Pregnancy companion rebuilt from the UI/UX spec in `cursor-rebuild-prompt.md`. Flutter, Hive (offline-first), Firestore-shaped sync mirror, Provider, go_router.

## Run

```bash
flutter pub get
flutter run -d chrome
# or: flutter run -d macos
```

Guest sign-in works with no backend. Google/Apple need native client IDs. Phone OTP demo code is `123456`. Paste a Gemini key in Settings for live Ask Mira answers.

## Design

Tokens live in `lib/ui/theme/design_tokens.dart`. Screens compose the eight shared pieces in `lib/ui/components/components.dart` (mesh background, glass cards, pill tabs, ring chips, composer, display headline, vital cards, photo chips). SOS is the one solid-color exception.

## Data

Hive is the source of truth. Writes also land in the `firestore_mirror` box under paths like `users/{id}/vitals/{id}`. `SyncService` clears the pending flag when the device is online. Point that flush at `cloud_firestore` when a Firebase project is linked — collection paths stay the same.

Android home-screen widget: `PregCareWidget`.
