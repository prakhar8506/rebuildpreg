# Pregnancy App — Functional Requirements (Scope Lock)

This is the functional contract for the rebuild. It exists so the visual rewrite in `cursor-rebuild-prompt.md` cannot silently drop or change behavior. Every checkbox below must still be true after the UI/UX rebuild — regardless of how the layout changes. Use this as the source of truth during QA (see `qa-checklist.md`).

## A. Onboarding & Auth
- [ ] Splash screen shown on cold start, routes to onboarding (first run) or auth/home
- [ ] Onboarding carousel: multi-slide intro, skippable
- [ ] Sign in via: email/password, Google, Apple, phone OTP, guest mode
- [ ] Register with role selection: mother / partner / family
- [ ] Forgot password flow (email reset link)
- [ ] Pregnancy profile setup: LMP/due date, current week, doctor name, hospital, blood group — required before Home is fully usable
- [ ] Edit profile & pregnancy details post-onboarding
- [ ] Settings: theme, language (English/Hindi), text size
- [ ] Account recovery path if local pregnancy data is unreachable/corrupted (re-sync from Firestore or manual re-entry)
- [ ] Sign out
- [ ] Delete account (with confirmation + data removal)
- [ ] Optional: user can enter their own Gemini API key for AI features
- [ ] Premium paywall gate (local entitlement check, no live payment integration yet)

## B. Home
- [ ] Daily greeting personalized by name + current week, with a week-relevant photo/collage
- [ ] Daily affirmation, nutrition tip, myth/fact, and a mood-lift item — rotates daily
- [ ] Today's care pulse: water progress, medicines due, next appointment — pulled from live logs
- [ ] Entry point to Ask Mira chat
- [ ] Wellbeing check-in entry ("how I'm feeling")
- [ ] SOS banner appears only when an active alert/emergency condition exists
- [ ] Android home-screen widget stays in sync with in-app data

## C. Week tracker
- [ ] Baby size, development milestones, and body changes shown per week, 1–40
- [ ] "What to avoid" / clinical guidance content per week
- [ ] Nutrition, exercise, and prenatal yoga guidance specific to the current week
- [ ] FAQs per week
- [ ] User can jump to any week and return to the current week

## D. Care & vitals
- [ ] Care hub aggregates vitals, medicines, visits, and emergency access
- [ ] Water intake logging: preset glass sizes + custom amount, running daily total
- [ ] Weight logging with trend chart over time
- [ ] Blood pressure logging with history
- [ ] Blood sugar/glucose logging with history
- [ ] Sleep logging
- [ ] Symptom logging with severity + history
- [ ] Mood calendar (daily mood entries, calendar view)
- [ ] Medicine scheduler: doses, adherence tracking, refill reminders
- [ ] Vaccination schedule tracking
- [ ] Appointments list with add/edit/reminder
- [ ] Pregnancy calendar combining milestones + visits
- [ ] Reminders list (all reminder types in one place)
- [ ] Health reports hub (exportable/viewable logs)
- [ ] Insights view summarizing logged vitals

## E. Baby & labor
- [ ] Kick/movement counter with session history
- [ ] Contraction timer (duration + frequency tracking)
- [ ] Hospital bag checklist (add/check items)
- [ ] Birth plan builder, exportable as a report
- [ ] Baby name browsing + AI-generated name ideas
- [ ] Shopping/nursery checklist

## F. Daily life & memories
- [ ] Nutrition guide (browsable content)
- [ ] Exercise/prenatal movement guide
- [ ] Journal: free-text entries, dated
- [ ] Memories: photo and video storage, organized/browsable
- [ ] Community: post creation, feed, and post detail/comments

## G. AI
- [ ] Ask Mira: conversational chat interface
- [ ] Symptom checker ("is this normal?") flow
- [ ] Weekly AI-generated meal plan
- [ ] Weekly AI-generated yoga/wellness plan
- [ ] Weekly summary generated from the user's logged data
- [ ] Prescription scan (camera capture + parsing)
- [ ] Lab report analysis (upload/scan + interpretation)

## H. People & safety
- [ ] Partner/family invite flow with shared read access to tracking data
- [ ] Emergency SOS action, including ambulance (108) dialing and emergency contact list
- [ ] Nearby blood donor directory (location-based)
- [ ] Doctor portal: doctor-facing login and patient detail view
- [ ] Admin console (internal/admin-facing)

## I. System
- [ ] Push notifications for reminders, alerts, and updates
- [ ] Offline-first storage: reads/writes work offline via Hive, sync to Firestore when online

---

Every checkbox here must map 1:1 to a screen in `cursor-rebuild-prompt.md` Section 4. If a rebuilt screen can't satisfy its checklist item, that's a regression, not an acceptable simplification — flag it instead of silently dropping it.
