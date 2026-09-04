# Pregnancy App — From-Scratch UI/UX Rebuild Prompt for Cursor

Paste this whole document into Cursor as the instruction. It replaces your previous prompts — don't combine them, Cursor will revert to old patterns if both are in context. Same tech stack, same features — the UI/UX is rebuilt from zero.

---

## 0. What this rebuild is — and isn't

This is a **full from-scratch rebuild of the UI/UX layer**, not an edit pass on the existing app. The last two attempts edited existing screens/widgets in place, which is why the result kept the **same widget tree, same screen composition, same information hierarchy** as the original even after a new skin was applied on top. This time every screen, widget, navigation route, and theme file gets deleted and rewritten from an empty file — nothing is restyled on top of what exists.

**Stays exactly the same:**
- **Tech stack** — Flutter, Hive (offline-first local storage), Firestore (sync), and whatever state-management, routing, and DI packages are already declared in `pubspec.yaml`. Do not swap frameworks, do not introduce a new state-management library, do not change the storage/sync approach.
- **Feature set** — every feature listed in Section 4 must still exist and work exactly as it does today. This is a redesign, not a re-scope: nothing added, nothing removed, no behavior changes.
- **Data layer** — models, Hive schema, Firestore collections, repositories, services, and business logic are untouched.

**Changes completely:**
- Every screen's composition, layout skeleton, card shapes, spacing, navigation structure, and control types. See Section 4 and the anti-patterns in Section 5.

The fix for the repeat-failure pattern: before deleting any old UI code, produce a short manifest mapping each existing screen to the providers/services/repositories it reads and writes (Section 7, Step 1). That's what makes it safe to delete the old screens/widgets folders outright and rebuild from zero, rather than editing in place — new screens reconnect to the same data layer by contract, not by inheriting old code. Then, for each screen group, produce a layout skeleton (old composition → new composition) before writing code, and wait for confirmation before implementing it.

---

## 1. Design system extracted from the reference set

The references (5 images) share one consistent aesthetic: soft mesh-gradient backgrounds, frosted glassmorphic cards, oversized editorial typography for emotional moments, pill-shaped controls, and photo-first cards with glass label chips. Build this as a real Flutter theme, not ad-hoc styling per screen.

### 1.1 Color & gradient tokens
Create `AppGradients` and extend `ThemeData` with a `ThemeExtension`:

- **Background mesh gradient** (used behind hero/greeting screens): rose `#F7B8D0` → orchid `#C9A6E8` → peach `#FBC9A6`, soft radial/mesh blend, never a flat linear 2-stop gradient — reference images use 3+ color blobs blurred together.
- **Accent radial gradient** (selected states, avatar rings, active date/tab): magenta → violet → amber, used small and concentrated (e.g. the selected day circle in the calendar widget reference), not spread across whole screens.
- **Neutral surfaces:** warm white `#FFFBFB` base, ink `#241C24` primary text, muted gray `#7A7280` secondary/caption text.
- **Semantic colors (vitals, alerts, medicine adherence):** keep these **solid and saturated**, not gradient-washed — see Section 6 on clinical legibility.

### 1.2 Typography
Two-family pairing, not one font for everything:
- **Display/editorial font** (Google Fonts: `Fraunces`, `Newsreader`, or `Instrument Serif`) for big emotional moments only — greetings, week number, date headers. Bold, tight letter-spacing, large sizes (40–56px).
- **UI/body font** (`Inter` or `General Sans`) for everything else — body text, labels, form fields, buttons.
- Type scale: Display 40–56 / Title 22–28 / Body 15–16 / Caption 12–13 (caption = muted gray eyebrow labels like "Scheduled for April 12" in the reference).

### 1.3 Glass surfaces (glassmorphism spec — implement as a real reusable widget)
- `BackdropFilter` blur sigma 20–30
- Fill: white at 12–18% opacity over the gradient backdrop
- Border: 1px solid white at ~25% opacity
- Corner radius: 28px large cards, 20px small cards, full pill (999) for buttons/tabs/chips
- Shadow: soft and **tinted** (rose/violet at low opacity), large blur radius, low spread, y-offset 8–16 — never a plain black drop shadow, that's what makes it look default.

### 1.4 Motion
Cards enter with slight scale + fade (not slide-from-bottom, which is the default pattern). Segmented/pill tabs animate with a springy indicator. Gentle parallax on scroll for hero backgrounds.

---

## 2. Reusable components to build first (before any screen)

Build these once, then compose every screen from them. This is what actually breaks the "same architecture" problem — the old app is composed of `ListView` + `Card` + `ListTile`; the new app must be composed of these instead:

1. **GradientMeshBackground** — the blurred multi-color backdrop
2. **GlassCard** — base component with variants: `standalone`, `stacked` (slightly rotated/offset, like scattered notes in the "Good Morning" reference), `photoOverlay` (image with gradient scrim + glass label chip, like the Memories grid)
3. **PillTabBar** — segmented control (Weekly/Monthly, Videos/Photos/Audio style)
4. **GradientRingDateChip** — circular date/avatar selector with the accent radial gradient on the active state
5. **BottomComposerBar** — pill-shaped input with leading icon + mic/send action (used for Ask Mira, journal quick-entry)
6. **DisplayHeadline** — the big serif/display text style widget for greetings and week headers
7. **VitalStatCard** — data-forward glass card: large legible numeral, sparkline, solid semantic color badge (not gradient text)
8. **PhotoLabelChip** — small glass chip overlaid bottom-left on photo cards

Every screen in Section 4 should visibly be an assembly of 2+ of these — that's how you and I will both verify the rebuild actually happened.

---

## 3. Translating the "premium / Apple-like / personal" feeling into concrete rules

Vague direction → concrete rule, so there's no ambiguity left for you to fill in with defaults:

- **"Feels personal"** → every hero/greeting screen pulls live data into the headline itself (name, current week, days to due date) — never a generic "Welcome back" with data below it.
- **"Premium, not $10k-cheap"** → max 2–3 accent colors visible per screen at once; restraint, not rainbow. Generous whitespace — no card should touch another without at least 16px gap.
- **"Apple-like"** → no visual clutter, no more than one primary CTA visible per screen, systematic spacing scale (8/12/16/24/32), never arbitrary padding numbers.
- **"Should not feel like a form"** → replace multi-field forms (profile setup, symptom logging) with conversational/step-based single-focus screens where possible, styled like the Ask Mira composer, not a stacked `TextFormField` list.

---

## 4. Screen-by-screen rebuild spec

For **every** group below: (a) list of existing features it must contain — unchanged functionally, (b) the new layout direction, (c) which reference pattern it borrows.

### A. Onboarding & Auth
Splash · onboarding carousel · sign in (email/Google/Apple/OTP/guest) · register with role · forgot password · pregnancy profile setup (dates, week, doctor, hospital, blood group) · edit profile & pregnancy · theme/language/text size · account recovery · sign out/delete account · Gemini API key field · premium paywall.

- Splash and onboarding carousel use full-bleed `GradientMeshBackground` with the `DisplayHeadline` style (borrow the "Memories don't begin in focus" big-type treatment) instead of a centered logo on white.
- Auth screen: glass card floating over the mesh background, not a plain white sheet.
- Profile setup: turn into a step-based flow (one question per screen, big type, pill-shaped inputs) instead of one long form.
- Paywall: borrow the stacked-card depth from the Memories reference to present tiers as physical, layered cards rather than a flat pricing table.

### B. Home
Daily greeting + week collage · daily affirmation/nutrition tip/myth-fact/smile · today's care pulse (water, medicines, next visit) · Ask Mira entry · wellbeing helper · SOS banner · Android widget sync.

- This is the direct analog of the "Good Morning" reference: `GradientMeshBackground` + `DisplayHeadline` greeting, with affirmation/nutrition-tip/reminder cards scattered as `GlassCard(stacked)` at slight rotation rather than a vertical list.
- Care pulse (water/medicine/next visit) becomes 3 compact `VitalStatCard`s in a horizontal scroll, not a checklist.
- SOS banner: solid, high-contrast, not glass — it must never be visually softened (see Section 6).
- Ask Mira entry sits as a `BottomComposerBar` pinned near the bottom, echoing the "Share with Dot…" pattern, not a floating action button.

### C. Week tracker
40-week baby size/development/body changes · what to avoid/clinical guidance · nutrition/exercise/yoga for the week · FAQs · jump-to-week / back-to-current.

- Borrow the calendar-widget reference directly: oversized week number as `DisplayHeadline`, horizontal week scroller with `GradientRingDateChip` marking the current week, "jump to week" as a bottom sheet rather than a dropdown.
- Baby size/development as a hero `GlassCard(photoOverlay)` illustration, swipeable between size/body-changes/what-to-avoid as tabs (`PillTabBar`) instead of stacked sections on one long scroll.

### D. Care & vitals
Care hub · water intake · weight trend · blood pressure · blood sugar/glucose · sleep · symptoms · mood calendar · medicine scheduler · vaccination schedule · appointments · pregnancy calendar · reminders list · health reports hub · insights.

- Care hub becomes a grid of `VitalStatCard`s (glass frame, solid legible numerals/sparklines) — not generic icon tiles.
- Mood calendar: reuse the `GradientRingDateChip` day-selector pattern from the calendar reference, with mood expressed as a small color dot rather than an emoji grid.
- Medicine scheduler & vaccination schedule: timeline-style, not table rows — each dose as a small glass chip along a vertical time rail.
- Reports/insights hub: chart cards keep solid, high-contrast data lines on a glass card background — gradient decoration stays in the card chrome, never behind the data itself.

### E. Baby & labor
Kick/movement counter · contraction timer · hospital bag checklist · birth plan + export · baby names + AI ideas · shopping/nursery list.

- Contraction timer and kick counter: large circular tap target styled like the accent gradient ring, with a live glass card showing the running log beneath — this is a moment that should feel calm, not clinical.
- Baby names: card-swipe interface (like flipping through the stacked Memories cards) instead of a plain searchable list.
- Checklists (hospital bag, shopping/nursery): grouped glass cards with pill-shaped checkboxes, not default `CheckboxListTile`.

### F. Daily life & memories
Nutrition guide · exercise/prenatal movement · journal · memories (photos/videos) · community posts + detail.

- Memories screen is the direct analog of reference image 2: `PillTabBar` (Videos/Photos/Audio), 2×2 `GlassCard(photoOverlay)` grid with `PhotoLabelChip` overlays, search bar + filter + add pinned at the bottom.
- Journal: entries as the "Morning Reflection" floating quote-card pattern, with a waveform-style entry for any voice notes.
- Community: posts as photo-first cards, same `photoOverlay` component, comment/detail view keeps the same card language rather than switching to a plain feed style.

### G. AI (Ask Mira)
Ask Mira chat · symptom checker · weekly meal plan · yoga/wellness plan · weekly summary of logged data · prescription scan · lab report analysis.

- Chat screen borrows reference image 1 directly: pill-shaped suggestion chips above the composer ("How am I feeling today", "Is this symptom normal"), `BottomComposerBar` with mic + attach.
- Weekly summary, meal plan, yoga plan: presented as swipeable glass cards (like "Saved Insights" in reference 5) rather than plain text responses in a chat bubble.
- Prescription/lab scan: camera capture screen keeps chrome minimal, result appears as a glass card overlay, not a new page navigation.

### H. People & safety
Partner/family invite + shared tracking · emergency SOS + ambulance (108) + contacts · nearby blood donor directory · doctor portal + patient detail · admin console.

- SOS/emergency: solid color, one large primary action, zero decorative gradient — this screen is the one deliberate exception to the whole aesthetic (see Section 6).
- Partner invite & shared tracking: reuse the "partner daily glance" feeling — a compact glass summary card partner sees first, not a raw data dump.
- Doctor portal / admin console: these are professional-facing, not expectant-mother-facing — keep the same design tokens for consistency but favor denser, table-like glass cards over decorative stacking, since these users need speed over delight.

### I. System
Push notifications · offline-first storage sync indicator.

- Notification banners: glass style consistent with in-app cards, except safety/SOS notifications which stay solid per Section 6.
- Add a subtle offline/sync indicator (small pill in the app bar), not present in the old build.

---

## 5. Explicit anti-patterns — do not do any of this

- No `ListView.builder` of plain `Card` + `ListTile` (icon, title, chevron) for a whole section — this is exactly what "same architecture" looks like.
- No standard bottom nav bar with 5 flat icons on a solid white/gray background.
- No flat white/gray cards with plain black drop shadow and no blur — reads as default Flutter Material, not the reference.
- No stock dashboard grid of identical square icon tiles for the care hub.
- Do not simply swap a background image or color behind the existing widget tree. The composition itself — card shapes, stacking, typography scale, control shapes — must change on every screen.
- No more than one serif/display headline moment per screen — don't apply the big editorial type everywhere or it stops feeling special.

---

## 6. Accessibility & clinical-data legibility (non-negotiable)

This is a health app used by pregnant women — beauty cannot come at the cost of reading blood pressure or a medicine name correctly.

- All numeric health data (BP, glucose, weight, dosages) must render in solid ink text on a near-opaque card background, WCAG AA contrast minimum — never gradient-filled text, never text directly on the mesh background.
- SOS, emergency contacts, and any red-flag/alert surface must use solid, high-contrast color — no glassmorphism, no blur, no decorative gradient. This is the one screen category exempt from the aesthetic system.
- Test every card with realistic long content (longest medicine name, longest journal entry, Hindi-language strings) to confirm glass cards don't clip or reduce contrast further.

---

## 7. Process — do this in order

1. **Audit & manifest.** Before touching anything, produce a manifest mapping every existing screen to the providers/services/repositories/models it depends on. This is what makes it safe to delete the old UI wholesale — new screens reconnect to the same data layer by contract, not by copying old code.
2. **Archive, don't edit.** Move the existing screens/widgets/UI folders (whatever they're called in this project) into a `_legacy/` folder or a separate git branch, and keep only the data/service/model layers in place. Do not edit old files in place — all new UI code is written fresh in new files.
3. Output the design tokens (colors, type scale, radii, shadow spec) as a Flutter `ThemeExtension` file. Show me the file.
4. Build the 8 reusable components from Section 2 in isolation (a components gallery screen is fine for review).
5. For each screen group (A–I), output a short **old layout → new layout** skeleton table (referencing the manifest from Step 1 for its data dependencies) before writing widget code. Wait for confirmation.
6. Implement screens using only the Section 2 components — no new one-off card styles invented per screen unless a pattern genuinely doesn't fit.
7. Run the Section 6 legibility check on every vitals/alert screen before marking it done.

Do not skip step 5. That is the step that was skipped both previous times, which is why every rebuild ended up structurally identical to the original.
