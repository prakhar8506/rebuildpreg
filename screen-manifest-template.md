# Screen Dependency Manifest

Greenfield rebuild — there was no prior Flutter tree in this workspace. Rows record the **new** contract: Hive boxes, Firestore-shaped mirror paths (`users/{id}/…` in the `firestore_mirror` box), and the `AppState` methods each screen reads/writes. Swap `SyncService.flushPending` for `cloud_firestore` later; collection paths stay the same.

### A. Onboarding & Auth
| Screen | Old file path | Providers / controllers / blocs used | Hive box(es) | Firestore path(s) | Notes |
|---|---|---|---|---|---|
| Splash | _(none — greenfield)_ | `AppState.booted`, `signedIn` | `session` | — | Router redirect after boot |
| Onboarding carousel | _(none)_ | `AppState.finishOnboarding` | `session` (`onboardingDone`) | — | Skippable 3-slide mesh + headline |
| Sign in | _(none)_ | `signInEmail`, `signInGoogle`, `signInApple`, `continueGuest` | `users`, `session` | `users/{id}` | Guest always works offline |
| Register (role select) | _(none)_ | `register(role)` | `users`, `settings` | `users/{id}` | Mother / partner / family |
| Forgot password | _(none)_ | `sendPasswordReset` | `users` | — | Local notification demo |
| Pregnancy profile setup | _(none)_ | `saveProfile` | `profiles` | `users/{id}/profile` | 4-step, one question each |
| Edit profile & pregnancy | _(none)_ | `saveProfile`, `updateUserName` | `profiles`, `users` | `users/{id}/profile` | `/setup?edit=1` |
| Settings (theme/language/text size) | _(none)_ | `updateSettings` | `settings` | `users/{id}/settings` | Text scale via `MediaQuery` |
| Account recovery | _(none)_ | `recoverAccount` | `users`, `firestore_mirror` | `users/{id}/profile` | Rehydrates from mirror, else re-entry |
| Sign out | _(none)_ | `signOut` | `session` | — | Settings |
| Delete account | _(none)_ | `deleteAccount` | all user-owned boxes | — | Confirmation dialog |
| Gemini API key entry | _(none)_ | `updateSettings.geminiKey` | `settings` | `users/{id}/settings` | Optional; AI falls back offline |
| Premium paywall | _(none)_ | `unlockPremium` | `settings.premium` | `users/{id}/settings` | Local entitlement, no payments |

### B. Home
| Screen | Old file path | Providers / controllers / blocs used | Hive box(es) | Firestore path(s) | Notes |
|---|---|---|---|---|---|
| Home (daily greeting) | _(none)_ | `firstName`, `currentWeek`, `daysLeft` | `profiles`, `settings` | `users/{id}/profile` | Headline includes live name + week |
| Care pulse widget | _(none)_ | `todayWaterMl`, `medsDueToday`, `nextVisit` | `vitals`, `medicines`, `appointments` | matching user subpaths | Horizontal `VitalStatCard`s |
| Ask Mira entry point | _(none)_ | `sendMira` | `chats` | `users/{id}/miraChat` | `BottomComposerBar` |
| Wellbeing check-in | _(none)_ | `addVital(mood)`, `addJournal` | `vitals`, `journal` | matching | Chip-based, not a form |
| SOS banner | _(none)_ | `settings.sosActive` | `settings` | `users/{id}/settings` | Solid red only when active |
| Android widget sync | _(none)_ | `WidgetSyncService.push` | home_widget prefs | — | `PregCareWidget` |

### C. Week tracker
| Screen | Old file path | Providers / controllers / blocs used | Hive box(es) | Firestore path(s) | Notes |
|---|---|---|---|---|---|
| Week tracker | _(none)_ | `viewingWeek`, `weekContent` | `profiles` (current week) | — | Content from `week_content.dart` |
| What to avoid / clinical | _(none)_ | `weekContent.avoid` | — | — | Pill tab |
| Nutrition/exercise/yoga | _(none)_ | `weekContent.*` | — | — | Glass cards under week |
| FAQs | _(none)_ | `weekContent.faqs` | — | — | Per week |
| Jump to week | _(none)_ | `viewingWeek=` | — | — | Bottom sheet |

### D. Care & vitals
| Screen | Old file path | Providers / controllers / blocs used | Hive box(es) | Firestore path(s) | Notes |
|---|---|---|---|---|---|
| Care hub | _(none)_ | vitals aggregates | `vitals`, `medicines`, `vaccines`, `appointments` | `users/{id}/…` | Grid of `VitalStatCard` |
| Water intake | _(none)_ | `addVital(water)` | `vitals` | `users/{id}/vitals/{id}` | Presets + custom |
| Weight | _(none)_ | `addVital(weight)` | `vitals` | same | Opaque numerals |
| Blood pressure | _(none)_ | `addVital(bp_sys)` + `extra.dia` | `vitals` | same | Solid ink |
| Blood sugar / glucose | _(none)_ | `addVital(glucose)` | `vitals` | same | |
| Sleep | _(none)_ | `addVital(sleep)` | `vitals` | same | |
| Symptoms | _(none)_ | `addVital(symptom)` | `vitals` | same | Severity stored |
| Mood calendar | _(none)_ | `addVital(mood)` | `vitals` | same | Color dots on chips |
| Medicine scheduler | _(none)_ | `saveMed`, `toggleDose` | `medicines` | `users/{id}/medicines/{id}` | Timeline + glass chips |
| Vaccination schedule | _(none)_ | `saveVaccine` | `vaccines` | `users/{id}/vaccines/{id}` | Seeded defaults |
| Appointments | _(none)_ | `saveAppt` | `appointments`, `reminders` | matching | |
| Pregnancy calendar | _(none)_ | appts + vaccines + week | those boxes | — | Combined rail |
| Reminders list | _(none)_ | `saveReminder` | `reminders` | `users/{id}/reminders/{id}` | |
| Health reports hub | _(none)_ | `vitals` counts | `vitals` | — | |
| Insights | _(none)_ | aggregates | `vitals` | — | Charts stay on opaque cards |

### E. Baby & labor
| Screen | Old file path | Providers / controllers / blocs used | Hive box(es) | Firestore path(s) | Notes |
|---|---|---|---|---|---|
| Kick counter | _(none)_ | `startKick`, `tapKick`, `endKick` | `kicks` | `users/{id}/kicks/{id}` | Gradient ring target |
| Contraction timer | _(none)_ | `startContraction`, `endContraction` | `contractions` | `users/{id}/contractions/{id}` | |
| Hospital bag | _(none)_ | `toggleCheck`, `addCheck` | `checklists` | `users/{id}/checklists/{id}` | Pill checkboxes |
| Birth plan + export | _(none)_ | `savePlan`, `share_plus` | `birth_plans` | `users/{id}/birthPlan` | |
| Baby names + AI | _(none)_ | `saveName`, `generatePlan('names')` | `saved_names` | `users/{id}/babyNames` | Card swipe |
| Shopping/nursery list | _(none)_ | same as bag | `checklists` | same | `listId=nursery` |

### F. Daily life & memories
| Screen | Old file path | Providers / controllers / blocs used | Hive box(es) | Firestore path(s) | Notes |
|---|---|---|---|---|---|
| Nutrition guide | _(none)_ | static `nutritionGuide` | — | — | |
| Exercise/prenatal movement | _(none)_ | static `exerciseGuide` | — | — | |
| Journal | _(none)_ | `addJournal` | `journal` | `users/{id}/journal/{id}` | Quote cards + waveform |
| Memories | _(none)_ | `addMemory` | `memories` | `users/{id}/memories/{id}` | 2×2 photoOverlay |
| Community feed | _(none)_ | `addPost` | `community` | `community/{id}` | |
| Community post detail | _(none)_ | `addComment` | `community` | `community/{id}` | Same card language |

### G. AI
| Screen | Old file path | Providers / controllers / blocs used | Hive box(es) | Firestore path(s) | Notes |
|---|---|---|---|---|---|
| Ask Mira chat | _(none)_ | `sendMira`, `AiService` | `chats` | `users/{id}/miraChat` | Gemini if key set |
| Symptom checker | _(none)_ | `sendMira` | `chats` | same | Conversational chips |
| Weekly meal plan | _(none)_ | `generatePlan('meal')` | — | — | Swipeable glass |
| Yoga/wellness plan | _(none)_ | `generatePlan('yoga')` | — | — | |
| Weekly summary | _(none)_ | `generatePlan('summary')` | `vitals` (read) | — | |
| Prescription scan | _(none)_ | `saveScan`, camera | `scans` | `users/{id}/scans/{id}` | Overlay result |
| Lab report analysis | _(none)_ | `saveScan` | `scans` | same | |

### H. People & safety
| Screen | Old file path | Providers / controllers / blocs used | Hive box(es) | Firestore path(s) | Notes |
|---|---|---|---|---|---|
| Partner/family invite | _(none)_ | `createInvite`, `acceptInvite` | `invites`, `users` | `invites/{id}` | Shared glance card |
| Emergency SOS | _(none)_ | `toggleSos`, `addContact`, `tel:108` | `contacts`, `settings` | `users/{id}/contacts/{id}` | Solid alert surface |
| Blood donor directory | _(none)_ | `donors()` | `donors` | — | Seeded cities |
| Doctor portal | _(none)_ | `allUsers` | `users` | — | Dense glass rows |
| Doctor patient detail | _(none)_ | `repo.vitalsFor`, `profileFor` | `profiles`, `vitals` | `users/{id}/…` | |
| Admin console | _(none)_ | `allUsers`, `posts`, `donors` | those boxes | — | |

### I. System
| Screen | Old file path | Providers / controllers / blocs used | Hive box(es) | Firestore path(s) | Notes |
|---|---|---|---|---|---|
| Push notifications | _(none)_ | `NotificationService` | — | — | Meds, visits, SOS |
| Offline sync indicator | _(none)_ | `SyncStatus` | `firestore_mirror` | pending flags | App-bar `SyncPill` |
