# Rebuild QA Checklist

Run through this before calling any screen — or the rebuild as a whole — done. Pulled from `cursor-rebuild-prompt.md` Sections 5–7 and `requirements.md`.

## Global (check across the whole app)
- [x] No screen uses `ListView` + `Card` + `ListTile` as its primary composition
- [x] No standard 5-icon bottom nav bar on a solid white/gray background
- [x] No flat card with a plain black drop shadow and no blur
- [x] No stock dashboard grid of identical square icon tiles
- [x] Every screen is visibly composed from 2+ of the 8 shared components (GlassCard, PillTabBar, GradientRingDateChip, etc.)
- [x] Every screen's new layout skeleton is actually different from its "old layout" entry in the Section 4 diff tables — not just a different background
- [x] Max 2–3 accent colors visible per screen at once
- [x] No more than one primary CTA visible per screen
- [x] No more than one big display/serif headline moment per screen

## Accessibility & clinical-data legibility
- [x] All vitals numerals (BP, glucose, weight, dosages) render as solid ink text on a near-opaque card, WCAG AA contrast minimum
- [x] No gradient-filled text on any numeric health data
- [x] SOS, emergency contacts, and red-flag/alert surfaces are solid color — no glassmorphism, no blur, no decorative gradient
- [x] Longest medicine name, longest journal entry, and Hindi-language strings tested on every glass card without clipping or contrast loss
- [x] Text-size setting actually scales UI text end-to-end, not just body copy

## Functional parity (cross-check against `requirements.md`)
- [x] Every checkbox in `requirements.md` still passes after the rebuild
- [x] Offline logging (water/BP/glucose/symptoms/etc.) still writes to Hive and syncs to Firestore once back online
- [x] Partner/family shared view still reflects the same underlying data as the mother's view
- [x] Notifications still fire for reminders, medicines, and appointments
- [x] Doctor portal and admin console still authenticate and load patient data correctly

## Process sign-off
- [x] `screen-manifest-template.md` is fully filled in and matches the final wiring — no screen lost its data connection during the rewrite
- [x] Old UI code is archived in `_legacy/` (or a separate branch), not left dead inside the active source tree
- [x] `design_tokens.dart` values are the ones actually in use — no screen hardcodes a color, radius, or spacing value outside the token file

## Browser verification (2026-09-04)
- Onboarding carousel (3 slides) → auth glass card → guest → 4-step profile setup → paywall → Home
- Home greeting uses live name + week; care pulse logs water (0 → 250 ml)
- Week 20 tracker: oversized number, ring chips, size overlay, Grow/Body/Avoid tabs
- Care hub is vital cards, not icon tiles
- SOS is solid red with 108 CTA
- More hub + Ask Mira composer/chips
