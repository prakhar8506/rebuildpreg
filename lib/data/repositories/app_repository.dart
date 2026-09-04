import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../core/ids.dart';
import '../content/guides.dart';
import '../hive/boxes.dart';
import '../models/models.dart';

class AppRepository {
  Box get _session => Boxes.box(Boxes.session);
  Box get _users => Boxes.box(Boxes.users);
  Box get _profiles => Boxes.box(Boxes.profiles);
  Box get _settings => Boxes.box(Boxes.settings);
  Box get _vitals => Boxes.box(Boxes.vitals);
  Box get _meds => Boxes.box(Boxes.medicines);
  Box get _vaccines => Boxes.box(Boxes.vaccines);
  Box get _appts => Boxes.box(Boxes.appointments);
  Box get _reminders => Boxes.box(Boxes.reminders);
  Box get _kicks => Boxes.box(Boxes.kicks);
  Box get _contractions => Boxes.box(Boxes.contractions);
  Box get _lists => Boxes.box(Boxes.checklists);
  Box get _plans => Boxes.box(Boxes.birthPlans);
  Box get _journal => Boxes.box(Boxes.journal);
  Box get _memories => Boxes.box(Boxes.memories);
  Box get _community => Boxes.box(Boxes.community);
  Box get _chats => Boxes.box(Boxes.chats);
  Box get _contacts => Boxes.box(Boxes.contacts);
  Box get _donors => Boxes.box(Boxes.donors);
  Box get _invites => Boxes.box(Boxes.invites);
  Box get _scans => Boxes.box(Boxes.scans);
  Box get _names => Boxes.box(Boxes.names);

  String? get currentUserId => _session.get('userId') as String?;

  bool sessionFlag(String key) => _session.get(key) == true;

  Future<void> setSessionFlag(String key, bool value) async {
    await _session.put(key, value);
  }

  Future<void> setCurrentUser(String? id) async {
    if (id == null) {
      await _session.delete('userId');
    } else {
      await _session.put('userId', id);
    }
  }

  AppUser? userById(String id) {
    final raw = _users.get(id);
    if (raw is Map) return AppUser.fromJson(raw);
    return null;
  }

  AppUser? userByEmail(String email) {
    for (final key in _users.keys) {
      final user = userById(key.toString());
      if (user != null && user.email.toLowerCase() == email.toLowerCase()) {
        return user;
      }
    }
    return null;
  }

  List<AppUser> allUsers() {
    return _users.keys
        .map((k) => userById(k.toString()))
        .whereType<AppUser>()
        .toList();
  }

  Future<void> putUser(AppUser user) async {
    await _users.put(user.id, user.toJson());
    await _markRemote('users/${user.id}', user.toJson());
  }

  Future<void> deleteUser(String id) async {
    await _users.delete(id);
    await _profiles.delete(id);
    await _settings.delete(id);
    await _plans.delete(id);
    _wipeUser(_vitals, id);
    _wipeUser(_meds, id);
    _wipeUser(_vaccines, id);
    _wipeUser(_appts, id);
    _wipeUser(_reminders, id);
    _wipeUser(_kicks, id);
    _wipeUser(_contractions, id);
    _wipeUser(_lists, id);
    _wipeUser(_journal, id);
    _wipeUser(_memories, id);
    _wipeUser(_community, id);
    _wipeUser(_chats, id);
    _wipeUser(_contacts, id);
    _wipeUser(_scans, id);
    _wipeUser(_names, id);
  }

  void _wipeUser(Box box, String userId) {
    final keys = box.keys.where((k) {
      final raw = box.get(k);
      return raw is Map && raw['userId'] == userId;
    }).toList();
    for (final k in keys) {
      box.delete(k);
    }
  }

  PregnancyProfile? profileFor(String userId) {
    final raw = _profiles.get(userId);
    if (raw is Map) return PregnancyProfile.fromJson(raw);
    return null;
  }

  Future<void> putProfile(PregnancyProfile profile) async {
    await _profiles.put(profile.userId, profile.toJson());
    await _markRemote('users/${profile.userId}/profile', profile.toJson());
  }

  AppSettings settingsFor(String userId) {
    final raw = _settings.get(userId);
    if (raw is Map) return AppSettings.fromJson(raw);
    return AppSettings();
  }

  Future<void> putSettings(String userId, AppSettings settings) async {
    await _settings.put(userId, settings.toJson());
    await _markRemote('users/$userId/settings', settings.toJson());
  }

  List<T> _owned<T>(Box box, String userId, T Function(Map) parse) {
    return box.keys
        .map((k) {
          final raw = box.get(k);
          if (raw is Map && raw['userId'] == userId) return parse(raw);
          return null;
        })
        .whereType<T>()
        .toList();
  }

  List<VitalLog> vitalsFor(String userId, {String? kind}) {
    final all = _owned(_vitals, userId, VitalLog.fromJson);
    all.sort((a, b) => b.at.compareTo(a.at));
    if (kind == null) return all;
    return all.where((v) => v.kind == kind).toList();
  }

  Future<void> putVital(VitalLog log) async {
    await _vitals.put(log.id, log.toJson());
    await _markRemote('users/${log.userId}/vitals/${log.id}', log.toJson());
  }

  List<Medicine> medsFor(String userId) =>
      _owned(_meds, userId, Medicine.fromJson);

  Future<void> putMed(Medicine med) async {
    await _meds.put(med.id, med.toJson());
    await _markRemote('users/${med.userId}/medicines/${med.id}', med.toJson());
  }

  Future<void> deleteMed(String id) async => _meds.delete(id);

  List<VaccineItem> vaccinesFor(String userId) {
    var items = _owned(_vaccines, userId, VaccineItem.fromJson);
    if (items.isEmpty) {
      items = defaultVaccines
          .map(
            (v) => VaccineItem(
              id: newId(),
              userId: userId,
              name: v['name'] as String,
              dueWeek: v['dueWeek'] as int,
            ),
          )
          .toList();
      for (final item in items) {
        _vaccines.put(item.id, item.toJson());
      }
    }
    items.sort((a, b) => a.dueWeek.compareTo(b.dueWeek));
    return items;
  }

  Future<void> putVaccine(VaccineItem item) async {
    await _vaccines.put(item.id, item.toJson());
    await _markRemote(
      'users/${item.userId}/vaccines/${item.id}',
      item.toJson(),
    );
  }

  List<Appointment> apptsFor(String userId) {
    final all = _owned(_appts, userId, Appointment.fromJson);
    all.sort((a, b) => a.at.compareTo(b.at));
    return all;
  }

  Future<void> putAppt(Appointment appt) async {
    await _appts.put(appt.id, appt.toJson());
    await _markRemote(
      'users/${appt.userId}/appointments/${appt.id}',
      appt.toJson(),
    );
  }

  Future<void> deleteAppt(String id) async => _appts.delete(id);

  List<AppReminder> remindersFor(String userId) {
    final all = _owned(_reminders, userId, AppReminder.fromJson);
    all.sort((a, b) => a.at.compareTo(b.at));
    return all;
  }

  Future<void> putReminder(AppReminder reminder) async {
    await _reminders.put(reminder.id, reminder.toJson());
    await _markRemote(
      'users/${reminder.userId}/reminders/${reminder.id}',
      reminder.toJson(),
    );
  }

  List<KickSession> kicksFor(String userId) {
    final all = _owned(_kicks, userId, KickSession.fromJson);
    all.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return all;
  }

  Future<void> putKick(KickSession session) async {
    await _kicks.put(session.id, session.toJson());
    await _markRemote(
      'users/${session.userId}/kicks/${session.id}',
      session.toJson(),
    );
  }

  List<Contraction> contractionsFor(String userId) {
    final all = _owned(_contractions, userId, Contraction.fromJson);
    all.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return all;
  }

  Future<void> putContraction(Contraction c) async {
    await _contractions.put(c.id, c.toJson());
    await _markRemote(
      'users/${c.userId}/contractions/${c.id}',
      c.toJson(),
    );
  }

  List<CheckItem> listFor(String userId, String listId) =>
      _owned(_lists, userId, CheckItem.fromJson)
          .where((i) => i.listId == listId)
          .toList();

  Future<void> putCheck(CheckItem item) async {
    await _lists.put(item.id, item.toJson());
    await _markRemote(
      'users/${item.userId}/checklists/${item.id}',
      item.toJson(),
    );
  }

  Future<void> ensureDefaultLists(String userId) async {
    if (listFor(userId, 'hospital').isEmpty) {
      for (final row in defaultHospitalBag) {
        await putCheck(
          CheckItem(
            id: newId(),
            userId: userId,
            listId: 'hospital',
            label: row['label']!,
            group: row['group']!,
          ),
        );
      }
    }
    if (listFor(userId, 'nursery').isEmpty) {
      for (final row in defaultNursery) {
        await putCheck(
          CheckItem(
            id: newId(),
            userId: userId,
            listId: 'nursery',
            label: row['label']!,
            group: row['group']!,
          ),
        );
      }
    }
    if (listFor(userId, 'shop').isEmpty) {
      for (final row in defaultShop) {
        await putCheck(
          CheckItem(
            id: newId(),
            userId: userId,
            listId: 'shop',
            label: row['label']!,
            group: row['group']!,
          ),
        );
      }
    }
    if (listFor(userId, 'visitq').isEmpty) {
      for (final row in defaultVisitQuestions) {
        await putCheck(
          CheckItem(
            id: newId(),
            userId: userId,
            listId: 'visitq',
            label: row['label']!,
            group: row['group']!,
          ),
        );
      }
    }
  }

  BirthPlan planFor(String userId) {
    final raw = _plans.get(userId);
    if (raw is Map) return BirthPlan.fromJson(raw);
    return BirthPlan(userId: userId);
  }

  Future<void> putPlan(BirthPlan plan) async {
    await _plans.put(plan.userId, plan.toJson());
    await _markRemote('users/${plan.userId}/birthPlan', plan.toJson());
  }

  List<JournalEntry> journalFor(String userId) {
    final all = _owned(_journal, userId, JournalEntry.fromJson);
    all.sort((a, b) => b.at.compareTo(a.at));
    return all;
  }

  Future<void> putJournal(JournalEntry entry) async {
    await _journal.put(entry.id, entry.toJson());
    await _markRemote(
      'users/${entry.userId}/journal/${entry.id}',
      entry.toJson(),
    );
  }

  List<MemoryItem> memoriesFor(String userId) {
    final all = _owned(_memories, userId, MemoryItem.fromJson);
    all.sort((a, b) => b.at.compareTo(a.at));
    return all;
  }

  Future<void> putMemory(MemoryItem item) async {
    await _memories.put(item.id, item.toJson());
    await _markRemote(
      'users/${item.userId}/memories/${item.id}',
      item.toJson(),
    );
  }

  List<CommunityPost> posts() {
    final all = _community.keys
        .map((k) {
          final raw = _community.get(k);
          if (raw is Map) return CommunityPost.fromJson(raw);
          return null;
        })
        .whereType<CommunityPost>()
        .toList();
    all.sort((a, b) => b.at.compareTo(a.at));
    return all;
  }

  Future<void> putPost(CommunityPost post) async {
    await _community.put(post.id, post.toJson());
    await _markRemote('community/${post.id}', post.toJson());
  }

  List<ChatMessage> chatFor(String userId) {
    final raw = _chats.get(userId);
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((m) => ChatMessage.fromJson(m))
          .toList();
    }
    return [];
  }

  Future<void> putChat(String userId, List<ChatMessage> messages) async {
    await _chats.put(userId, messages.map((m) => m.toJson()).toList());
    await _markRemote(
      'users/$userId/miraChat',
      messages.map((m) => m.toJson()).toList(),
    );
  }

  List<EmergencyContact> contactsFor(String userId) =>
      _owned(_contacts, userId, EmergencyContact.fromJson);

  Future<void> putContact(EmergencyContact c) async {
    await _contacts.put(c.id, c.toJson());
    await _markRemote('users/${c.userId}/contacts/${c.id}', c.toJson());
  }

  Future<void> deleteContact(String id) async => _contacts.delete(id);

  List<BloodDonor> donors() {
    var all = _donors.keys
        .map((k) {
          final raw = _donors.get(k);
          if (raw is Map) return BloodDonor.fromJson(raw);
          return null;
        })
        .whereType<BloodDonor>()
        .toList();
    if (all.isEmpty) {
      all = donorSeed
          .map(
            (d) => BloodDonor(
              id: newId(),
              name: d['name'] as String,
              bloodGroup: d['bloodGroup'] as String,
              city: d['city'] as String,
              phone: d['phone'] as String,
              lat: (d['lat'] as num).toDouble(),
              lng: (d['lng'] as num).toDouble(),
            ),
          )
          .toList();
      for (final d in all) {
        _donors.put(d.id, d.toJson());
      }
    }
    return all;
  }

  List<Invite> invitesForMother(String motherId) {
    return _invites.keys
        .map((k) {
          final raw = _invites.get(k);
          if (raw is Map && raw['motherId'] == motherId) {
            return Invite.fromJson(raw);
          }
          return null;
        })
        .whereType<Invite>()
        .toList();
  }

  Invite? inviteByCode(String code) {
    for (final key in _invites.keys) {
      final raw = _invites.get(key);
      if (raw is Map && raw['code'] == code) {
        return Invite.fromJson(raw);
      }
    }
    return null;
  }

  Future<void> putInvite(Invite invite) async {
    await _invites.put(invite.id, invite.toJson());
    await _markRemote('invites/${invite.id}', invite.toJson());
  }

  List<ScanResult> scansFor(String userId) {
    final all = _owned(_scans, userId, ScanResult.fromJson);
    all.sort((a, b) => b.at.compareTo(a.at));
    return all;
  }

  Future<void> putScan(ScanResult scan) async {
    await _scans.put(scan.id, scan.toJson());
    await _markRemote('users/${scan.userId}/scans/${scan.id}', scan.toJson());
  }

  List<String> savedNames(String userId) {
    final raw = _names.get(userId);
    if (raw is List) return raw.cast<String>();
    return [];
  }

  Future<void> putSavedNames(String userId, List<String> names) async {
    await _names.put(userId, names);
    await _markRemote('users/$userId/babyNames', names);
  }

  Future<void> seedCommunityIfEmpty() async {
    if (_community.isNotEmpty) return;
    await putPost(
      CommunityPost(
        id: newId(),
        userId: 'seed',
        author: 'Leela, week 22',
        body:
            'First real kick during a work call. I muted myself and cried into a glass of water. Sharing so someone else feels less alone.',
        at: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    );
    await putPost(
      CommunityPost(
        id: newId(),
        userId: 'seed',
        author: 'Nisha, week 31',
        body:
            'Hospital bag is a running joke in this house. I packed the charger and forgot the file. Twice.',
        at: DateTime.now().subtract(const Duration(days: 1)),
      ),
    );
  }

  Future<void> _markRemote(String path, Object data) async {
    final remote = Boxes.box(Boxes.remote);
    await remote.put(path, {
      'path': path,
      'data': jsonDecode(jsonEncode(data)),
      'updatedAt': DateTime.now().toIso8601String(),
      'pending': true,
    });
  }

  Future<int> flushPending() async {
    final remote = Boxes.box(Boxes.remote);
    var n = 0;
    for (final key in remote.keys) {
      final raw = remote.get(key);
      if (raw is Map && raw['pending'] == true) {
        raw['pending'] = false;
        raw['syncedAt'] = DateTime.now().toIso8601String();
        await remote.put(key, raw);
        n++;
      }
    }
    return n;
  }

  Future<bool> restoreFromRemote(String userId) async {
    final remote = Boxes.box(Boxes.remote);
    final profilePath = 'users/$userId/profile';
    final raw = remote.get(profilePath);
    if (raw is Map && raw['data'] is Map) {
      await putProfile(
        PregnancyProfile.fromJson(Map<String, dynamic>.from(raw['data'] as Map)),
      );
      return true;
    }
    return false;
  }

  int pendingCount() {
    final remote = Boxes.box(Boxes.remote);
    return remote.keys.where((k) {
      final raw = remote.get(k);
      return raw is Map && raw['pending'] == true;
    }).length;
  }
}
