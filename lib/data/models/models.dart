enum UserRole { mother, partner, family, doctor, admin, guest }

enum ThemeModePref { system, light, dark }

enum TextSizePref { small, regular, large }

class AppUser {
  AppUser({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.role,
    required this.displayName,
    this.phone = '',
    this.linkedMotherId,
    this.createdAt,
  });

  final String id;
  final String email;
  final String passwordHash;
  final UserRole role;
  final String displayName;
  final String phone;
  final String? linkedMotherId;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'passwordHash': passwordHash,
        'role': role.name,
        'displayName': displayName,
        'phone': phone,
        'linkedMotherId': linkedMotherId,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory AppUser.fromJson(Map map) => AppUser(
        id: map['id'] as String,
        email: map['email'] as String? ?? '',
        passwordHash: map['passwordHash'] as String? ?? '',
        role: UserRole.values.byName(map['role'] as String? ?? 'mother'),
        displayName: map['displayName'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        linkedMotherId: map['linkedMotherId'] as String?,
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'] as String)
            : null,
      );
}

class PregnancyProfile {
  PregnancyProfile({
    required this.userId,
    this.lmp,
    this.dueDate,
    this.currentWeek,
    this.doctorName = '',
    this.hospital = '',
    this.bloodGroup = '',
    this.photoPath,
  });

  final String userId;
  final DateTime? lmp;
  final DateTime? dueDate;
  final int? currentWeek;
  final String doctorName;
  final String hospital;
  final String bloodGroup;
  final String? photoPath;

  bool get isComplete => lmp != null || dueDate != null || currentWeek != null;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'lmp': lmp?.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'currentWeek': currentWeek,
        'doctorName': doctorName,
        'hospital': hospital,
        'bloodGroup': bloodGroup,
        'photoPath': photoPath,
      };

  factory PregnancyProfile.fromJson(Map map) => PregnancyProfile(
        userId: map['userId'] as String,
        lmp: map['lmp'] != null ? DateTime.tryParse(map['lmp'] as String) : null,
        dueDate: map['dueDate'] != null
            ? DateTime.tryParse(map['dueDate'] as String)
            : null,
        currentWeek: map['currentWeek'] as int?,
        doctorName: map['doctorName'] as String? ?? '',
        hospital: map['hospital'] as String? ?? '',
        bloodGroup: map['bloodGroup'] as String? ?? '',
        photoPath: map['photoPath'] as String?,
      );

  PregnancyProfile copyWith({
    DateTime? lmp,
    DateTime? dueDate,
    int? currentWeek,
    String? doctorName,
    String? hospital,
    String? bloodGroup,
    String? photoPath,
  }) {
    return PregnancyProfile(
      userId: userId,
      lmp: lmp ?? this.lmp,
      dueDate: dueDate ?? this.dueDate,
      currentWeek: currentWeek ?? this.currentWeek,
      doctorName: doctorName ?? this.doctorName,
      hospital: hospital ?? this.hospital,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}

class AppSettings {
  AppSettings({
    this.theme = ThemeModePref.light,
    this.language = 'en',
    this.textSize = TextSizePref.regular,
    this.geminiKey = '',
    this.premium = false,
    this.onboardingDone = false,
    this.sosActive = false,
  });

  final ThemeModePref theme;
  final String language;
  final TextSizePref textSize;
  final String geminiKey;
  final bool premium;
  final bool onboardingDone;
  final bool sosActive;

  double get textScale => switch (textSize) {
        TextSizePref.small => 0.9,
        TextSizePref.regular => 1.0,
        TextSizePref.large => 1.2,
      };

  Map<String, dynamic> toJson() => {
        'theme': theme.name,
        'language': language,
        'textSize': textSize.name,
        'geminiKey': geminiKey,
        'premium': premium,
        'onboardingDone': onboardingDone,
        'sosActive': sosActive,
      };

  factory AppSettings.fromJson(Map map) => AppSettings(
        theme: ThemeModePref.values
            .byName(map['theme'] as String? ?? 'light'),
        language: map['language'] as String? ?? 'en',
        textSize: TextSizePref.values
            .byName(map['textSize'] as String? ?? 'regular'),
        geminiKey: map['geminiKey'] as String? ?? '',
        premium: map['premium'] as bool? ?? false,
        onboardingDone: map['onboardingDone'] as bool? ?? false,
        sosActive: map['sosActive'] as bool? ?? false,
      );

  AppSettings copyWith({
    ThemeModePref? theme,
    String? language,
    TextSizePref? textSize,
    String? geminiKey,
    bool? premium,
    bool? onboardingDone,
    bool? sosActive,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      textSize: textSize ?? this.textSize,
      geminiKey: geminiKey ?? this.geminiKey,
      premium: premium ?? this.premium,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      sosActive: sosActive ?? this.sosActive,
    );
  }
}

class VitalLog {
  VitalLog({
    required this.id,
    required this.userId,
    required this.kind,
    required this.value,
    required this.at,
    this.note = '',
    this.extra = const {},
    this.dirty = true,
  });

  final String id;
  final String userId;
  final String kind;
  final double value;
  final DateTime at;
  final String note;
  final Map extra;
  final bool dirty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'kind': kind,
        'value': value,
        'at': at.toIso8601String(),
        'note': note,
        'extra': extra,
        'dirty': dirty,
      };

  factory VitalLog.fromJson(Map map) => VitalLog(
        id: map['id'] as String,
        userId: map['userId'] as String,
        kind: map['kind'] as String,
        value: (map['value'] as num).toDouble(),
        at: DateTime.parse(map['at'] as String),
        note: map['note'] as String? ?? '',
        extra: Map<String, dynamic>.from(map['extra'] as Map? ?? {}),
        dirty: map['dirty'] as bool? ?? false,
      );
}

class Medicine {
  Medicine({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.times,
    this.notes = '',
    this.refillDate,
    this.adherence = const {},
  });

  final String id;
  final String userId;
  final String name;
  final String dosage;
  final List<String> times;
  final String notes;
  final DateTime? refillDate;
  final Map<String, bool> adherence;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'dosage': dosage,
        'times': times,
        'notes': notes,
        'refillDate': refillDate?.toIso8601String(),
        'adherence': adherence,
      };

  factory Medicine.fromJson(Map map) => Medicine(
        id: map['id'] as String,
        userId: map['userId'] as String,
        name: map['name'] as String,
        dosage: map['dosage'] as String? ?? '',
        times: List<String>.from(map['times'] as List? ?? const []),
        notes: map['notes'] as String? ?? '',
        refillDate: map['refillDate'] != null
            ? DateTime.tryParse(map['refillDate'] as String)
            : null,
        adherence: Map<String, bool>.from(map['adherence'] as Map? ?? {}),
      );
}

class VaccineItem {
  VaccineItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.dueWeek,
    this.done = false,
    this.at,
  });

  final String id;
  final String userId;
  final String name;
  final int dueWeek;
  final bool done;
  final DateTime? at;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'dueWeek': dueWeek,
        'done': done,
        'at': at?.toIso8601String(),
      };

  factory VaccineItem.fromJson(Map map) => VaccineItem(
        id: map['id'] as String,
        userId: map['userId'] as String,
        name: map['name'] as String,
        dueWeek: map['dueWeek'] as int? ?? 1,
        done: map['done'] as bool? ?? false,
        at: map['at'] != null ? DateTime.tryParse(map['at'] as String) : null,
      );
}

class Appointment {
  Appointment({
    required this.id,
    required this.userId,
    required this.title,
    required this.at,
    this.place = '',
    this.notes = '',
    this.remind = true,
  });

  final String id;
  final String userId;
  final String title;
  final DateTime at;
  final String place;
  final String notes;
  final bool remind;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'at': at.toIso8601String(),
        'place': place,
        'notes': notes,
        'remind': remind,
      };

  factory Appointment.fromJson(Map map) => Appointment(
        id: map['id'] as String,
        userId: map['userId'] as String,
        title: map['title'] as String,
        at: DateTime.parse(map['at'] as String),
        place: map['place'] as String? ?? '',
        notes: map['notes'] as String? ?? '',
        remind: map['remind'] as bool? ?? true,
      );
}

class AppReminder {
  AppReminder({
    required this.id,
    required this.userId,
    required this.title,
    required this.at,
    this.kind = 'general',
  });

  final String id;
  final String userId;
  final String title;
  final DateTime at;
  final String kind;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'at': at.toIso8601String(),
        'kind': kind,
      };

  factory AppReminder.fromJson(Map map) => AppReminder(
        id: map['id'] as String,
        userId: map['userId'] as String,
        title: map['title'] as String,
        at: DateTime.parse(map['at'] as String),
        kind: map['kind'] as String? ?? 'general',
      );
}

class KickSession {
  KickSession({
    required this.id,
    required this.userId,
    required this.startedAt,
    required this.kicks,
    this.endedAt,
  });

  final String id;
  final String userId;
  final DateTime startedAt;
  final int kicks;
  final DateTime? endedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'startedAt': startedAt.toIso8601String(),
        'kicks': kicks,
        'endedAt': endedAt?.toIso8601String(),
      };

  factory KickSession.fromJson(Map map) => KickSession(
        id: map['id'] as String,
        userId: map['userId'] as String,
        startedAt: DateTime.parse(map['startedAt'] as String),
        kicks: map['kicks'] as int? ?? 0,
        endedAt: map['endedAt'] != null
            ? DateTime.tryParse(map['endedAt'] as String)
            : null,
      );
}

class Contraction {
  Contraction({
    required this.id,
    required this.userId,
    required this.startedAt,
    required this.seconds,
  });

  final String id;
  final String userId;
  final DateTime startedAt;
  final int seconds;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'startedAt': startedAt.toIso8601String(),
        'seconds': seconds,
      };

  factory Contraction.fromJson(Map map) => Contraction(
        id: map['id'] as String,
        userId: map['userId'] as String,
        startedAt: DateTime.parse(map['startedAt'] as String),
        seconds: map['seconds'] as int? ?? 0,
      );
}

class CheckItem {
  CheckItem({
    required this.id,
    required this.userId,
    required this.listId,
    required this.label,
    this.done = false,
    this.group = 'General',
  });

  final String id;
  final String userId;
  final String listId;
  final String label;
  final bool done;
  final String group;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'listId': listId,
        'label': label,
        'done': done,
        'group': group,
      };

  factory CheckItem.fromJson(Map map) => CheckItem(
        id: map['id'] as String,
        userId: map['userId'] as String,
        listId: map['listId'] as String,
        label: map['label'] as String,
        done: map['done'] as bool? ?? false,
        group: map['group'] as String? ?? 'General',
      );
}

class BirthPlan {
  BirthPlan({
    required this.userId,
    this.place = '',
    this.support = '',
    this.pain = '',
    this.feeding = '',
    this.notes = '',
  });

  final String userId;
  final String place;
  final String support;
  final String pain;
  final String feeding;
  final String notes;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'place': place,
        'support': support,
        'pain': pain,
        'feeding': feeding,
        'notes': notes,
      };

  factory BirthPlan.fromJson(Map map) => BirthPlan(
        userId: map['userId'] as String,
        place: map['place'] as String? ?? '',
        support: map['support'] as String? ?? '',
        pain: map['pain'] as String? ?? '',
        feeding: map['feeding'] as String? ?? '',
        notes: map['notes'] as String? ?? '',
      );
}

class JournalEntry {
  JournalEntry({
    required this.id,
    required this.userId,
    required this.body,
    required this.at,
    this.voiceNote = false,
  });

  final String id;
  final String userId;
  final String body;
  final DateTime at;
  final bool voiceNote;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'body': body,
        'at': at.toIso8601String(),
        'voiceNote': voiceNote,
      };

  factory JournalEntry.fromJson(Map map) => JournalEntry(
        id: map['id'] as String,
        userId: map['userId'] as String,
        body: map['body'] as String? ?? '',
        at: DateTime.parse(map['at'] as String),
        voiceNote: map['voiceNote'] as bool? ?? false,
      );
}

class MemoryItem {
  MemoryItem({
    required this.id,
    required this.userId,
    required this.path,
    required this.kind,
    required this.at,
    this.label = '',
  });

  final String id;
  final String userId;
  final String path;
  final String kind;
  final DateTime at;
  final String label;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'path': path,
        'kind': kind,
        'at': at.toIso8601String(),
        'label': label,
      };

  factory MemoryItem.fromJson(Map map) => MemoryItem(
        id: map['id'] as String,
        userId: map['userId'] as String,
        path: map['path'] as String,
        kind: map['kind'] as String? ?? 'photo',
        at: DateTime.parse(map['at'] as String),
        label: map['label'] as String? ?? '',
      );
}

class CommunityPost {
  CommunityPost({
    required this.id,
    required this.userId,
    required this.author,
    required this.body,
    required this.at,
    this.imagePath,
    this.comments = const [],
  });

  final String id;
  final String userId;
  final String author;
  final String body;
  final DateTime at;
  final String? imagePath;
  final List<Map<String, String>> comments;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'author': author,
        'body': body,
        'at': at.toIso8601String(),
        'imagePath': imagePath,
        'comments': comments,
      };

  factory CommunityPost.fromJson(Map map) => CommunityPost(
        id: map['id'] as String,
        userId: map['userId'] as String,
        author: map['author'] as String? ?? '',
        body: map['body'] as String? ?? '',
        at: DateTime.parse(map['at'] as String),
        imagePath: map['imagePath'] as String?,
        comments: (map['comments'] as List? ?? [])
            .map((e) => Map<String, String>.from(e as Map))
            .toList(),
      );
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.at,
  });

  final String id;
  final String role;
  final String text;
  final DateTime at;

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'text': text,
        'at': at.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map map) => ChatMessage(
        id: map['id'] as String,
        role: map['role'] as String,
        text: map['text'] as String,
        at: DateTime.parse(map['at'] as String),
      );
}

class EmergencyContact {
  EmergencyContact({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
  });

  final String id;
  final String userId;
  final String name;
  final String phone;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'phone': phone,
      };

  factory EmergencyContact.fromJson(Map map) => EmergencyContact(
        id: map['id'] as String,
        userId: map['userId'] as String,
        name: map['name'] as String,
        phone: map['phone'] as String,
      );
}

class BloodDonor {
  BloodDonor({
    required this.id,
    required this.name,
    required this.bloodGroup,
    required this.city,
    required this.phone,
    this.lat = 0,
    this.lng = 0,
  });

  final String id;
  final String name;
  final String bloodGroup;
  final String city;
  final String phone;
  final double lat;
  final double lng;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bloodGroup': bloodGroup,
        'city': city,
        'phone': phone,
        'lat': lat,
        'lng': lng,
      };

  factory BloodDonor.fromJson(Map map) => BloodDonor(
        id: map['id'] as String,
        name: map['name'] as String,
        bloodGroup: map['bloodGroup'] as String,
        city: map['city'] as String,
        phone: map['phone'] as String,
        lat: (map['lat'] as num?)?.toDouble() ?? 0,
        lng: (map['lng'] as num?)?.toDouble() ?? 0,
      );
}

class Invite {
  Invite({
    required this.id,
    required this.motherId,
    required this.code,
    required this.role,
    this.acceptedBy,
  });

  final String id;
  final String motherId;
  final String code;
  final String role;
  final String? acceptedBy;

  Map<String, dynamic> toJson() => {
        'id': id,
        'motherId': motherId,
        'code': code,
        'role': role,
        'acceptedBy': acceptedBy,
      };

  factory Invite.fromJson(Map map) => Invite(
        id: map['id'] as String,
        motherId: map['motherId'] as String,
        code: map['code'] as String,
        role: map['role'] as String,
        acceptedBy: map['acceptedBy'] as String?,
      );
}

class ScanResult {
  ScanResult({
    required this.id,
    required this.userId,
    required this.kind,
    required this.summary,
    required this.at,
    this.imagePath,
  });

  final String id;
  final String userId;
  final String kind;
  final String summary;
  final DateTime at;
  final String? imagePath;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'kind': kind,
        'summary': summary,
        'at': at.toIso8601String(),
        'imagePath': imagePath,
      };

  factory ScanResult.fromJson(Map map) => ScanResult(
        id: map['id'] as String,
        userId: map['userId'] as String,
        kind: map['kind'] as String,
        summary: map['summary'] as String,
        at: DateTime.parse(map['at'] as String),
        imagePath: map['imagePath'] as String?,
      );
}
