import 'package:hive_flutter/hive_flutter.dart';

class Boxes {
  Boxes._();

  static const session = 'session';
  static const users = 'users';
  static const profiles = 'profiles';
  static const settings = 'settings';
  static const vitals = 'vitals';
  static const medicines = 'medicines';
  static const vaccines = 'vaccines';
  static const appointments = 'appointments';
  static const reminders = 'reminders';
  static const kicks = 'kicks';
  static const contractions = 'contractions';
  static const checklists = 'checklists';
  static const birthPlans = 'birth_plans';
  static const journal = 'journal';
  static const memories = 'memories';
  static const community = 'community';
  static const chats = 'chats';
  static const contacts = 'contacts';
  static const donors = 'donors';
  static const invites = 'invites';
  static const scans = 'scans';
  static const remote = 'firestore_mirror';
  static const names = 'saved_names';

  static const all = [
    session,
    users,
    profiles,
    settings,
    vitals,
    medicines,
    vaccines,
    appointments,
    reminders,
    kicks,
    contractions,
    checklists,
    birthPlans,
    journal,
    memories,
    community,
    chats,
    contacts,
    donors,
    invites,
    scans,
    remote,
    names,
  ];

  static Future<void> openAll() async {
    for (final name in all) {
      await Hive.openBox(name);
    }
  }

  static Box box(String name) => Hive.box(name);
}
