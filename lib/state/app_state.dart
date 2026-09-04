import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../core/ids.dart';
import '../core/week_math.dart';
import '../data/content/week_content.dart';
import '../data/models/models.dart';
import '../data/repositories/app_repository.dart';
import '../data/services/ai_service.dart';
import '../data/services/notification_service.dart';
import '../data/services/sync_service.dart';
import '../data/services/widget_sync_service.dart';

class AppState extends ChangeNotifier {
  AppState({
    required this.repo,
    required this.sync,
    required this.ai,
    required this.notifications,
    required this.widgetSync,
  });

  final AppRepository repo;
  final SyncService sync;
  final AiService ai;
  final NotificationService notifications;
  final WidgetSyncService widgetSync;

  AppUser? user;
  PregnancyProfile? profile;
  AppSettings settings = AppSettings();
  SyncStatus syncStatus = SyncStatus.synced;
  String? lastError;
  bool booted = false;
  String? pendingOtp;
  String? pendingPhone;

  List<VitalLog> vitals = [];
  List<Medicine> medicines = [];
  List<VaccineItem> vaccines = [];
  List<Appointment> appointments = [];
  List<AppReminder> reminders = [];
  List<KickSession> kicks = [];
  List<Contraction> contractions = [];
  List<CheckItem> hospitalBag = [];
  List<CheckItem> nursery = [];
  List<CheckItem> shop = [];
  List<CheckItem> visitQuestions = [];
  BirthPlan birthPlan = BirthPlan(userId: '');
  List<JournalEntry> journal = [];
  List<MemoryItem> memories = [];
  List<CommunityPost> posts = [];
  List<ChatMessage> chat = [];
  List<EmergencyContact> contacts = [];
  List<BloodDonor> donors = [];
  List<Invite> invites = [];
  List<ScanResult> scans = [];
  List<String> savedNames = [];
  List<AppUser> allUsers = [];

  KickSession? liveKick;
  DateTime? contractionStarted;
  int viewingWeek = 20;
  bool aiBusy = false;

  String get lang => settings.language;
  bool get isDark => settings.theme == ThemeModePref.dark;
  double get textScale => settings.textScale;
  bool get signedIn => user != null;
  bool get needsOnboarding => !settings.onboardingDone;
  bool get needsProfile {
    if (user == null) return false;
    if (user!.role == UserRole.doctor || user!.role == UserRole.admin) {
      return false;
    }
    return profile == null || !profile!.isComplete;
  }

  int get currentWeek {
    if (profile?.lmp != null) return weekFromLmp(profile!.lmp!);
    if (profile?.dueDate != null) return weekFromDue(profile!.dueDate!);
    return (profile?.currentWeek ?? 20).clamp(1, 40);
  }

  DateTime? get dueDate {
    if (profile?.dueDate != null) return profile!.dueDate;
    if (profile?.lmp != null) return dueFromLmp(profile!.lmp!);
    return null;
  }

  int? get daysLeft {
    final due = dueDate;
    if (due == null) return null;
    return daysUntilDue(due);
  }

  WeekContent get weekContent => weekAt(viewingWeek);

  String get firstName {
    final n = user?.displayName ?? '';
    if (n.trim().isEmpty) return lang == 'hi' ? 'वहाँ' : 'there';
    return n.trim().split(' ').first;
  }

  double get todayWaterMl {
    final key = dayKey(DateTime.now());
    return vitals
        .where((v) => v.kind == 'water' && dayKey(v.at) == key)
        .fold(0, (s, v) => s + v.value);
  }

  static const moveKinds = ['move', 'walk', 'yoga', 'stretch', 'swim', 'floor'];

  double _todaySum(String kind) {
    final key = dayKey(DateTime.now());
    return vitals
        .where((v) => v.kind == kind && dayKey(v.at) == key)
        .fold(0, (s, v) => s + v.value);
  }

  double get todayMoveMin {
    final key = dayKey(DateTime.now());
    return vitals
        .where((v) => (moveKinds.contains(v.kind) || v.kind == 'move') && dayKey(v.at) == key)
        .fold(0, (s, v) => s + v.value);
  }

  double get todayMindMin => _todaySum('meditate') + _todaySum('breathe');

  double get todaySleepHr => _todaySum('sleep');

  int get todayMoodCount {
    final key = dayKey(DateTime.now());
    return vitals.where((v) => v.kind == 'mood' && dayKey(v.at) == key).length;
  }

  double get moveRing => (todayMoveMin / 20).clamp(0, 1);
  double get mindRing => ((todayMindMin / 10) + (todayMoodCount > 0 ? 0.35 : 0)).clamp(0, 1);
  double get restRing => (todaySleepHr / 8).clamp(0, 1);

  List<double> weekMoveMinutes() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
      final key = dayKey(day);
      return vitals
          .where((v) => (moveKinds.contains(v.kind) || v.kind == 'move') && dayKey(v.at) == key)
          .fold(0.0, (s, v) => s + v.value);
    });
  }

  Future<void> logMove({
    required String note,
    required double minutes,
    String feel = '',
  }) async {
    await addVital(
      kind: 'move',
      value: minutes,
      note: note,
      extra: feel.isEmpty ? const {} : {'feel': feel},
    );
  }

  Future<void> logMind({required String kind, required double minutes}) async {
    await addVital(kind: kind, value: minutes);
  }

  List<Medicine> get medsDueToday {
    return medicines.where((m) => m.times.isNotEmpty).toList();
  }

  Appointment? get nextVisit {
    final now = DateTime.now();
    final upcoming = appointments.where((a) => a.at.isAfter(now)).toList();
    if (upcoming.isEmpty) return null;
    return upcoming.first;
  }

  String t(String key) => SWrap.t(key, lang);

  Future<void> boot() async {
    await repo.seedCommunityIfEmpty();
    if (repo.sessionFlag('onboardingDone')) {
      settings = settings.copyWith(onboardingDone: true);
    }
    final id = repo.currentUserId;
    if (id != null) {
      user = repo.userById(id);
      if (user != null) await _hydrate(user!.id);
    }
    donors = repo.donors();
    posts = repo.posts();
    allUsers = repo.allUsers();
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    booted = true;
    notifyListeners();
    unawaited(refreshSync());
  }

  Future<void> _hydrate(String userId) async {
    profile = repo.profileFor(userId);
    settings = repo.settingsFor(userId);
    vitals = repo.vitalsFor(userId);
    medicines = repo.medsFor(userId);
    vaccines = repo.vaccinesFor(userId);
    appointments = repo.apptsFor(userId);
    reminders = repo.remindersFor(userId);
    kicks = repo.kicksFor(userId);
    contractions = repo.contractionsFor(userId);
    await repo.ensureDefaultLists(userId);
    _reloadLists(userId);
    birthPlan = repo.planFor(userId);
    journal = repo.journalFor(userId);
    memories = repo.memoriesFor(userId);
    chat = repo.chatFor(userId);
    contacts = repo.contactsFor(userId);
    invites = repo.invitesForMother(userId);
    scans = repo.scansFor(userId);
    savedNames = repo.savedNames(userId);
    viewingWeek = currentWeek;
    posts = repo.posts();
    allUsers = repo.allUsers();
    await _pushWidget();
  }

  Future<void> refreshSync() async {
    syncStatus = await sync.syncNow();
    notifyListeners();
  }

  String _hash(String raw) => sha256.convert(utf8.encode(raw)).toString();

  Future<AppUser> _startSession(AppUser next) async {
    user = next;
    await repo.setCurrentUser(next.id);
    await _hydrate(next.id);
    notifyListeners();
    return next;
  }

  Future<bool> signInEmail(String email, String password) async {
    lastError = null;
    final found = repo.userByEmail(email.trim());
    if (found == null || found.passwordHash != _hash(password)) {
      lastError = 'Email or password is not right.';
      notifyListeners();
      return false;
    }
    await _startSession(found);
    return true;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String phone = '',
  }) async {
    lastError = null;
    if (repo.userByEmail(email.trim()) != null) {
      lastError = 'That email already has a space here.';
      notifyListeners();
      return false;
    }
    final next = AppUser(
      id: newId(),
      email: email.trim(),
      passwordHash: _hash(password),
      role: role,
      displayName: name.trim(),
      phone: phone,
      createdAt: DateTime.now(),
    );
    await repo.putUser(next);
    await repo.putSettings(next.id, AppSettings(onboardingDone: true));
    await _startSession(next);
    return true;
  }

  Future<void> continueGuest() async {
    final next = AppUser(
      id: newId(),
      email: 'guest-${DateTime.now().millisecondsSinceEpoch}@local',
      passwordHash: '',
      role: UserRole.guest,
      displayName: lang == 'hi' ? 'अतिथि' : 'Guest',
      createdAt: DateTime.now(),
    );
    await repo.putUser(next);
    await repo.putSettings(next.id, AppSettings(onboardingDone: true));
    await _startSession(next);
  }

  Future<bool> signInGoogle() async {
    try {
      final google = GoogleSignIn.instance;
      await google.initialize();
      final account = await google.authenticate();
      final email = account.email;
      var found = repo.userByEmail(email);
      found ??= AppUser(
        id: newId(),
        email: email,
        passwordHash: _hash('google:$email'),
        role: UserRole.mother,
        displayName: account.displayName ?? email.split('@').first,
        createdAt: DateTime.now(),
      );
      await repo.putUser(found);
      await repo.putSettings(
        found.id,
        repo.settingsFor(found.id).copyWith(onboardingDone: true),
      );
      await _startSession(found);
      return true;
    } catch (e) {
      lastError = 'Google sign-in needs a client ID in this build.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInApple() async {
    try {
      final cred = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final email = cred.email ?? 'apple-${cred.userIdentifier}@privaterelay';
      var found = repo.userByEmail(email);
      final name = [
        cred.givenName,
        cred.familyName,
      ].whereType<String>().join(' ');
      found ??= AppUser(
        id: newId(),
        email: email,
        passwordHash: _hash('apple:${cred.userIdentifier}'),
        role: UserRole.mother,
        displayName: name.isEmpty ? 'Apple' : name,
        createdAt: DateTime.now(),
      );
      await repo.putUser(found);
      await repo.putSettings(
        found.id,
        repo.settingsFor(found.id).copyWith(onboardingDone: true),
      );
      await _startSession(found);
      return true;
    } catch (e) {
      lastError = 'Apple sign-in is available on a signed iOS device.';
      notifyListeners();
      return false;
    }
  }

  Future<String> sendOtp(String phone) async {
    pendingPhone = phone;
    pendingOtp = '123456';
    notifyListeners();
    return pendingOtp!;
  }

  Future<bool> verifyOtp(String code) async {
    if (code.trim() != pendingOtp || pendingPhone == null) {
      lastError = 'That code is not right. Demo code is 123456.';
      notifyListeners();
      return false;
    }
    final email = '${pendingPhone}@otp.local';
    var found = repo.userByEmail(email);
    found ??= AppUser(
      id: newId(),
      email: email,
      passwordHash: _hash('otp:$pendingPhone'),
      role: UserRole.mother,
      displayName: pendingPhone!,
      phone: pendingPhone!,
      createdAt: DateTime.now(),
    );
    await repo.putUser(found);
    await repo.putSettings(
      found.id,
      repo.settingsFor(found.id).copyWith(onboardingDone: true),
    );
    await _startSession(found);
    return true;
  }

  Future<bool> sendPasswordReset(String email) async {
    final found = repo.userByEmail(email.trim());
    if (found == null) {
      lastError = 'No account uses that email.';
      notifyListeners();
      return false;
    }
    await notifications.ping(
      id: 21,
      title: 'Reset link',
      body: 'A reset path is ready for $email (local demo).',
    );
    return true;
  }

  Future<void> finishOnboarding() async {
    settings = settings.copyWith(onboardingDone: true);
    await repo.setSessionFlag('onboardingDone', true);
    if (user != null) await repo.putSettings(user!.id, settings);
    notifyListeners();
  }

  Future<void> saveProfile(PregnancyProfile next) async {
    profile = next;
    await repo.putProfile(next);
    viewingWeek = currentWeek;
    await refreshSync();
    await _pushWidget();
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    if (user == null) return;
    final next = AppUser(
      id: user!.id,
      email: user!.email,
      passwordHash: user!.passwordHash,
      role: user!.role,
      displayName: name,
      phone: user!.phone,
      linkedMotherId: user!.linkedMotherId,
      createdAt: user!.createdAt,
    );
    user = next;
    await repo.putUser(next);
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings next) async {
    settings = next;
    if (user != null) await repo.putSettings(user!.id, next);
    notifyListeners();
  }

  Future<void> signOut() async {
    user = null;
    profile = null;
    settings = AppSettings();
    await repo.setCurrentUser(null);
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    final id = user?.id;
    if (id != null) await repo.deleteUser(id);
    await signOut();
  }

  Future<bool> recoverAccount(String email) async {
    final found = repo.userByEmail(email.trim());
    if (found == null) {
      lastError = 'Nothing to recover for that email.';
      notifyListeners();
      return false;
    }
    await _startSession(found);
    final restored = await repo.restoreFromRemote(found.id);
    await _hydrate(found.id);
    if (!restored && (profile == null || !profile!.isComplete)) {
      lastError = 'Session restored. Re-enter pregnancy dates if they are gone.';
    }
    notifyListeners();
    return true;
  }

  Future<void> unlockPremium() async {
    await updateSettings(settings.copyWith(premium: true));
  }

  Future<void> addVital({
    required String kind,
    required double value,
    String note = '',
    Map extra = const {},
  }) async {
    if (user == null) return;
    final log = VitalLog(
      id: newId(),
      userId: user!.id,
      kind: kind,
      value: value,
      at: DateTime.now(),
      note: note,
      extra: extra,
    );
    await repo.putVital(log);
    vitals = repo.vitalsFor(user!.id);
    await refreshSync();
    await _pushWidget();
    notifyListeners();
  }

  static const ritualKeys = ['sip', 'walk', 'vitamin', 'rest'];

  bool ritualDone(String key) {
    final today = dayKey(DateTime.now());
    return vitals.any((v) => v.kind == 'ritual_$key' && dayKey(v.at) == today);
  }

  int get ritualDoneCount => ritualKeys.where(ritualDone).length;

  Future<void> completeRitual(String key) async {
    if (ritualDone(key)) return;
    if (key == 'sip') await addVital(kind: 'water', value: 250);
    await addVital(kind: 'ritual_$key', value: 1, note: key);
  }

  String exportSnapshot() {
    final moodToday = vitals.where((v) => v.kind == 'mood' && dayKey(v.at) == dayKey(DateTime.now()));
    return [
      'Mira care export',
      'Name: ${user?.displayName ?? 'Guest'}',
      'Week: $currentWeek',
      'Water today: ${todayWaterMl.round()} ml',
      'Move today: ${todayMoveMin.round()} min',
      'Mind today: ${todayMindMin.round()} min',
      'Mood logs: ${moodToday.length}',
      'Medicines: ${medicines.length}',
      'Visits: ${appointments.length}',
      'Journal notes: ${journal.length}',
      'Exported: ${DateTime.now().toIso8601String()}',
      '',
      'This file is a local summary. Mira is not a medical device.',
    ].join('\n');
  }

  Future<void> saveMed(Medicine med) async {
    await repo.putMed(med);
    medicines = repo.medsFor(user!.id);
    await notifications.ping(
      id: med.id.hashCode,
      title: 'Medicine',
      body: '${med.name} ${med.dosage}',
    );
    notifyListeners();
  }

  Future<void> toggleDose(Medicine med, String slot) async {
    final key = '${dayKey(DateTime.now())}-$slot';
    final next = Map<String, bool>.from(med.adherence);
    next[key] = !(next[key] ?? false);
    await saveMed(
      Medicine(
        id: med.id,
        userId: med.userId,
        name: med.name,
        dosage: med.dosage,
        times: med.times,
        notes: med.notes,
        refillDate: med.refillDate,
        adherence: next,
      ),
    );
  }

  Future<void> saveVaccine(VaccineItem item) async {
    await repo.putVaccine(item);
    vaccines = repo.vaccinesFor(user!.id);
    notifyListeners();
  }

  Future<void> saveAppt(Appointment appt) async {
    await repo.putAppt(appt);
    appointments = repo.apptsFor(user!.id);
    if (appt.remind) {
      await notifications.ping(
        id: appt.id.hashCode,
        title: appt.title,
        body: appt.place.isEmpty ? 'Appointment saved' : appt.place,
      );
      await repo.putReminder(
        AppReminder(
          id: newId(),
          userId: user!.id,
          title: appt.title,
          at: appt.at,
          kind: 'visit',
        ),
      );
      reminders = repo.remindersFor(user!.id);
    }
    await _pushWidget();
    notifyListeners();
  }

  Future<void> saveReminder(AppReminder reminder) async {
    await repo.putReminder(reminder);
    reminders = repo.remindersFor(user!.id);
    await notifications.ping(
      id: reminder.id.hashCode,
      title: reminder.title,
      body: 'Reminder saved',
    );
    notifyListeners();
  }

  Future<void> startKick() async {
    if (user == null) return;
    liveKick = KickSession(
      id: newId(),
      userId: user!.id,
      startedAt: DateTime.now(),
      kicks: 0,
    );
    notifyListeners();
  }

  Future<void> tapKick() async {
    if (liveKick == null) return;
    liveKick = KickSession(
      id: liveKick!.id,
      userId: liveKick!.userId,
      startedAt: liveKick!.startedAt,
      kicks: liveKick!.kicks + 1,
    );
    notifyListeners();
  }

  Future<void> endKick() async {
    if (liveKick == null) return;
    final done = KickSession(
      id: liveKick!.id,
      userId: liveKick!.userId,
      startedAt: liveKick!.startedAt,
      kicks: liveKick!.kicks,
      endedAt: DateTime.now(),
    );
    await repo.putKick(done);
    kicks = repo.kicksFor(user!.id);
    liveKick = null;
    notifyListeners();
  }

  void startContraction() {
    contractionStarted = DateTime.now();
    notifyListeners();
  }

  Future<void> endContraction() async {
    if (contractionStarted == null || user == null) return;
    final seconds = DateTime.now().difference(contractionStarted!).inSeconds;
    await repo.putContraction(
      Contraction(
        id: newId(),
        userId: user!.id,
        startedAt: contractionStarted!,
        seconds: seconds,
      ),
    );
    contractions = repo.contractionsFor(user!.id);
    contractionStarted = null;
    notifyListeners();
  }

  Future<void> toggleCheck(CheckItem item) async {
    await repo.putCheck(
      CheckItem(
        id: item.id,
        userId: item.userId,
        listId: item.listId,
        label: item.label,
        done: !item.done,
        group: item.group,
      ),
    );
    _reloadLists(user!.id);
    notifyListeners();
  }

  Future<void> addCheck({
    required String listId,
    required String label,
    String group = 'Added',
  }) async {
    await repo.putCheck(
      CheckItem(
        id: newId(),
        userId: user!.id,
        listId: listId,
        label: label,
        group: group,
      ),
    );
    _reloadLists(user!.id);
    notifyListeners();
  }

  List<CheckItem> checksFor(String listId) {
    return switch (listId) {
      'hospital' => hospitalBag,
      'nursery' => nursery,
      'shop' => shop,
      'visitq' => visitQuestions,
      _ => const [],
    };
  }

  void _reloadLists(String userId) {
    hospitalBag = repo.listFor(userId, 'hospital');
    nursery = repo.listFor(userId, 'nursery');
    shop = repo.listFor(userId, 'shop');
    visitQuestions = repo.listFor(userId, 'visitq');
  }

  Future<void> savePlan(BirthPlan plan) async {
    birthPlan = plan;
    await repo.putPlan(plan);
    notifyListeners();
  }

  Future<void> addJournal(String body, {bool voice = false}) async {
    await repo.putJournal(
      JournalEntry(
        id: newId(),
        userId: user!.id,
        body: body,
        at: DateTime.now(),
        voiceNote: voice,
      ),
    );
    journal = repo.journalFor(user!.id);
    notifyListeners();
  }

  Future<void> addMemory({
    required String path,
    required String kind,
    String label = '',
  }) async {
    await repo.putMemory(
      MemoryItem(
        id: newId(),
        userId: user!.id,
        path: path,
        kind: kind,
        at: DateTime.now(),
        label: label,
      ),
    );
    memories = repo.memoriesFor(user!.id);
    notifyListeners();
  }

  Future<void> addPost(String body, {String? imagePath}) async {
    await repo.putPost(
      CommunityPost(
        id: newId(),
        userId: user!.id,
        author: user?.displayName ?? 'You',
        body: body,
        at: DateTime.now(),
        imagePath: imagePath,
      ),
    );
    posts = repo.posts();
    notifyListeners();
  }

  Future<void> addComment(CommunityPost post, String text) async {
    final comments = [
      ...post.comments,
      {'author': user?.displayName ?? 'You', 'body': text},
    ];
    await repo.putPost(
      CommunityPost(
        id: post.id,
        userId: post.userId,
        author: post.author,
        body: post.body,
        at: post.at,
        imagePath: post.imagePath,
        comments: comments,
      ),
    );
    posts = repo.posts();
    notifyListeners();
  }

  Future<void> sendMira(String text) async {
    if (user == null) return;
    chat = [
      ...chat,
      ChatMessage(id: newId(), role: 'user', text: text, at: DateTime.now()),
    ];
    aiBusy = true;
    notifyListeners();
    final reply = await ai.complete(
      apiKey: settings.geminiKey,
      prompt: text,
      history: chat,
    );
    chat = [
      ...chat,
      ChatMessage(id: newId(), role: 'model', text: reply, at: DateTime.now()),
    ];
    await repo.putChat(user!.id, chat);
    aiBusy = false;
    notifyListeners();
  }

  Future<String> generatePlan(String kind) async {
    aiBusy = true;
    notifyListeners();
    final logs = vitals.take(12).map((v) => '${v.kind}:${v.value}').join(', ');
    final prompt = switch (kind) {
      'meal' =>
        'Write a 7-day pregnancy meal plan for week $currentWeek in India. Short, warm, practical.',
      'yoga' =>
        'Write a gentle prenatal wellness plan for week $currentWeek. No unsafe poses.',
      'summary' =>
        'Write a weekly letter summarizing these logs: $logs. Week $currentWeek.',
      'names' =>
        'Suggest 8 baby names (mix of Indian and global) with a one-word meaning.',
      _ => kind,
    };
    final out = await ai.complete(apiKey: settings.geminiKey, prompt: prompt);
    aiBusy = false;
    notifyListeners();
    return out;
  }

  Future<void> saveScan({
    required String kind,
    required String summary,
    String? imagePath,
  }) async {
    await repo.putScan(
      ScanResult(
        id: newId(),
        userId: user!.id,
        kind: kind,
        summary: summary,
        at: DateTime.now(),
        imagePath: imagePath,
      ),
    );
    scans = repo.scansFor(user!.id);
    notifyListeners();
  }

  Future<void> addContact(String name, String phone) async {
    await repo.putContact(
      EmergencyContact(
        id: newId(),
        userId: user!.id,
        name: name,
        phone: phone,
      ),
    );
    contacts = repo.contactsFor(user!.id);
    notifyListeners();
  }

  Future<Invite> createInvite(String role) async {
    final invite = Invite(
      id: newId(),
      motherId: user!.id,
      code: newId().substring(0, 6).toUpperCase(),
      role: role,
    );
    await repo.putInvite(invite);
    invites = repo.invitesForMother(user!.id);
    notifyListeners();
    return invite;
  }

  Future<bool> acceptInvite(String code) async {
    final invite = repo.inviteByCode(code.trim().toUpperCase());
    if (invite == null || user == null) {
      lastError = 'That invite code is not found.';
      notifyListeners();
      return false;
    }
    final next = AppUser(
      id: user!.id,
      email: user!.email,
      passwordHash: user!.passwordHash,
      role: invite.role == 'partner' ? UserRole.partner : UserRole.family,
      displayName: user!.displayName,
      phone: user!.phone,
      linkedMotherId: invite.motherId,
      createdAt: user!.createdAt,
    );
    user = next;
    await repo.putUser(next);
    await repo.putInvite(
      Invite(
        id: invite.id,
        motherId: invite.motherId,
        code: invite.code,
        role: invite.role,
        acceptedBy: user!.id,
      ),
    );
    profile = repo.profileFor(invite.motherId) ?? profile;
    notifyListeners();
    return true;
  }

  Future<void> toggleSos([bool? value]) async {
    settings = settings.copyWith(sosActive: value ?? !settings.sosActive);
    if (user != null) await repo.putSettings(user!.id, settings);
    if (settings.sosActive) {
      await notifications.ping(
        id: 108,
        title: 'SOS is on',
        body: 'Emergency banner is visible. 108 is one tap away.',
        urgent: true,
      );
    }
    notifyListeners();
  }

  Future<void> saveName(String name) async {
    if (savedNames.contains(name)) {
      savedNames = [...savedNames]..remove(name);
    } else {
      savedNames = [...savedNames, name];
    }
    await repo.putSavedNames(user!.id, savedNames);
    notifyListeners();
  }

  void setViewingWeek(int week) {
    viewingWeek = week.clamp(1, 40);
    notifyListeners();
  }

  Future<void> _pushWidget() async {
    await widgetSync.push(
      greeting: 'Hi $firstName',
      weekLabel: 'Week $currentWeek',
      water: '${todayWaterMl.round()} ml',
      nextVisit: nextVisit?.title ?? 'No visit yet',
    );
  }
}

class SWrap {
  static String t(String key, String lang) {
    const en = {
      'appName': 'Mira',
      'skip': 'Skip',
      'continue': 'Continue',
      'composerHint': 'Share with Mira…',
    };
    const hi = {
      'appName': 'मीरा',
      'skip': 'छोड़ें',
      'continue': 'आगे',
      'composerHint': 'मीरा से साझा करें…',
    };
    return (lang == 'hi' ? hi : en)[key] ?? key;
  }
}
