import 'package:go_router/go_router.dart';

import '../data/content/guides.dart';
import '../data/models/models.dart';
import '../state/app_state.dart';
import '../ui/entry_gate/entry_gate_screen.dart';
import '../ui/screens/ai_screens.dart';
import '../ui/screens/auth_screens.dart';
import '../ui/screens/baby_screens.dart';
import '../ui/screens/care_screens.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/life_screens.dart';
import '../ui/screens/mind_body_screens.dart';
import '../ui/screens/people_screens.dart';
import '../ui/screens/studio_screens.dart';
import '../ui/screens/system_screens.dart';
import '../ui/screens/week_screen.dart';
import '../ui/shell/app_shell.dart';

GoRouter createRouter(AppState app) {
  return GoRouter(
    initialLocation: '/auth',
    refreshListenable: app,
    redirect: (context, state) {
      final loc = state.uri.path;
      if (!app.booted) {
        return (loc == '/auth' || loc == '/splash') ? null : '/auth';
      }
      const open = {
        '/auth',
        '/splash',
        '/register',
        '/forgot',
        '/otp',
        '/recover',
        '/auth/pro',
      };
      if (!app.signedIn) {
        if (loc == '/splash' || loc == '/onboarding') return '/auth';
        if (open.contains(loc)) return null;
        return '/auth';
      }
      if (app.user?.role == UserRole.doctor &&
          !loc.startsWith('/doctor') &&
          loc != '/settings') {
        return '/doctor';
      }
      if (app.user?.role == UserRole.admin &&
          !loc.startsWith('/admin') &&
          loc != '/settings') {
        return '/admin';
      }
      if (app.needsProfile && loc != '/setup' && loc != '/paywall') {
        return '/setup';
      }
      if (loc == '/splash' || loc == '/onboarding' || loc == '/auth') {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const EntryGateScreen()),
      GoRoute(path: '/auth', builder: (_, __) => const EntryGateScreen()),
      GoRoute(path: '/auth/pro', builder: (_, __) => const ProAuthScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot', builder: (_, __) => const ForgotScreen()),
      GoRoute(path: '/otp', builder: (_, __) => const OtpScreen()),
      GoRoute(path: '/recover', builder: (_, __) => const RecoverScreen()),
      GoRoute(
        path: '/setup',
        builder: (_, state) => ProfileSetupScreen(
          editing: state.uri.queryParameters['edit'] == '1',
        ),
      ),
      GoRoute(path: '/paywall', builder: (_, __) => const PaywallScreen()),
      GoRoute(path: '/gallery', builder: (_, __) => const GalleryScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/week', builder: (_, __) => const WeekScreen()),
          GoRoute(path: '/care', builder: (_, __) => const CareHubScreen()),
          GoRoute(path: '/more', builder: (_, __) => const MoreScreen()),
        ],
      ),
      GoRoute(path: '/care/water', builder: (_, __) => const WaterScreen()),
      GoRoute(path: '/care/weight', builder: (_, __) => const WeightScreen()),
      GoRoute(path: '/care/bp', builder: (_, __) => const BpScreen()),
      GoRoute(path: '/care/glucose', builder: (_, __) => const GlucoseScreen()),
      GoRoute(path: '/care/sleep', builder: (_, __) => const SleepScreen()),
      GoRoute(path: '/care/symptoms', builder: (_, __) => const SymptomsScreen()),
      GoRoute(path: '/care/mood', builder: (_, __) => const MoodScreen()),
      GoRoute(path: '/care/meds', builder: (_, __) => const MedsScreen()),
      GoRoute(path: '/care/vaccines', builder: (_, __) => const VaccinesScreen()),
      GoRoute(path: '/care/visits', builder: (_, __) => const VisitsScreen()),
      GoRoute(path: '/care/calendar', builder: (_, __) => const CalendarScreen()),
      GoRoute(path: '/care/reminders', builder: (_, __) => const RemindersScreen()),
      GoRoute(path: '/care/reports', builder: (_, __) => const ReportsScreen()),
      GoRoute(path: '/care/insights', builder: (_, __) => const InsightsScreen()),
      GoRoute(path: '/baby', builder: (_, __) => const BabyHubScreen()),
      GoRoute(path: '/baby/kicks', builder: (_, __) => const KickScreen()),
      GoRoute(path: '/baby/contractions', builder: (_, __) => const ContractionScreen()),
      GoRoute(
        path: '/baby/bag',
        builder: (_, __) => const ChecklistScreen(listId: 'hospital', title: 'Hospital bag'),
      ),
      GoRoute(path: '/baby/plan', builder: (_, __) => const BirthPlanScreen()),
      GoRoute(path: '/baby/names', builder: (_, __) => const NamesScreen()),
      GoRoute(
        path: '/baby/nursery',
        builder: (_, __) => const ChecklistScreen(listId: 'nursery', title: 'Nursery'),
      ),
      GoRoute(path: '/life', builder: (_, __) => const LifeHubScreen()),
      GoRoute(
        path: '/life/nutrition',
        builder: (_, __) => const GuideScreen(title: 'Nutrition', items: nutritionGuide),
      ),
      GoRoute(
        path: '/life/exercise',
        builder: (_, __) => const GuideScreen(title: 'Movement', items: exerciseGuide),
      ),
      GoRoute(path: '/life/journal', builder: (_, __) => const JournalScreen()),
      GoRoute(path: '/life/memories', builder: (_, __) => const MemoriesScreen()),
      GoRoute(path: '/life/community', builder: (_, __) => const CommunityScreen()),
      GoRoute(
        path: '/life/community/:id',
        builder: (_, state) => CommunityDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(path: '/life/wellbeing', builder: (_, __) => const WellbeingScreen()),
      GoRoute(path: '/life/breathe', builder: (_, __) => const BreatheScreen()),
      GoRoute(path: '/life/meditate', builder: (_, __) => const MeditationScreen()),
      GoRoute(path: '/life/activity', builder: (_, __) => const ActivityStudioScreen()),
      GoRoute(path: '/life/floor', builder: (_, __) => const PelvicFloorScreen()),
      GoRoute(path: '/life/cravings', builder: (_, __) => const CravingsScreen()),
      GoRoute(path: '/life/belly', builder: (_, __) => const BellyTapeScreen()),
      GoRoute(path: '/life/food', builder: (_, __) => const FoodSafetyScreen()),
      GoRoute(
        path: '/life/shop',
        builder: (_, __) => const ChecklistScreen(listId: 'shop', title: 'Shopping'),
      ),
      GoRoute(
        path: '/life/questions',
        builder: (_, __) => const ChecklistScreen(listId: 'visitq', title: 'Visit questions'),
      ),
      GoRoute(path: '/plan', builder: (_, __) => const TodayPlanScreen()),
      GoRoute(
        path: '/legal/privacy',
        builder: (_, __) => const LegalScreen(title: 'Privacy', body: kPrivacyBody),
      ),
      GoRoute(
        path: '/legal/disclaimer',
        builder: (_, __) => const LegalScreen(title: 'Medical note', body: kDisclaimerBody),
      ),
      GoRoute(path: '/legal/export', builder: (_, __) => const ExportCareScreen()),
      GoRoute(path: '/mira', builder: (_, __) => const MiraChatScreen()),
      GoRoute(path: '/mira/plans', builder: (_, __) => const MiraPlansScreen()),
      GoRoute(path: '/mira/symptoms', builder: (_, __) => const SymptomCheckerScreen()),
      GoRoute(path: '/mira/scan', builder: (_, __) => const ScanScreen(kind: 'rx')),
      GoRoute(path: '/mira/lab', builder: (_, __) => const ScanScreen(kind: 'lab')),
      GoRoute(path: '/people', builder: (_, __) => const PeopleHubScreen()),
      GoRoute(path: '/people/invite', builder: (_, __) => const InviteScreen()),
      GoRoute(path: '/people/sos', builder: (_, __) => const SosScreen()),
      GoRoute(path: '/people/donors', builder: (_, __) => const DonorsScreen()),
      GoRoute(path: '/doctor', builder: (_, __) => const DoctorPortalScreen()),
      GoRoute(
        path: '/doctor/:id',
        builder: (_, state) => DoctorPatientScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(path: '/admin', builder: (_, __) => const AdminScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
  );
}
