class GuideItem {
  const GuideItem({
    required this.title,
    required this.body,
    required this.tag,
  });

  final String title;
  final String body;
  final String tag;
}

const nutritionGuide = <GuideItem>[
  GuideItem(
    title: 'Iron that actually absorbs',
    tag: 'Minerals',
    body:
        'Pair dal, spinach, or fortified cereal with lemon, amla, or orange. Tea and coffee right after a meal block iron — wait an hour.',
  ),
  GuideItem(
    title: 'Protein without the food noise',
    tag: 'Meals',
    body:
        'Aim for a palm of protein at each meal: eggs, paneer, curd, fish, tofu, or a handful of nuts if dinner is late.',
  ),
  GuideItem(
    title: 'Nausea plate',
    tag: 'First trimester',
    body:
        'Cold, dry, and pale often wins: toast, banana, salted crackers, coconut water. Eat before the empty-stomach wave.',
  ),
  GuideItem(
    title: 'What to skip',
    tag: 'Safety',
    body:
        'Alcohol, high-mercury fish, unpasteurized milk, raw eggs, and undercooked meat. Limit caffeine to about one small coffee.',
  ),
  GuideItem(
    title: 'Hydration that is not boring',
    tag: 'Water',
    body:
        'A squeeze of lime, a pinch of salt on hot days, coconut water after a walk. Pale straw-colored urine is the check.',
  ),
];

const exerciseGuide = <GuideItem>[
  GuideItem(
    title: 'The conversational rule',
    tag: 'Pace',
    body:
        'If you can speak a full sentence, the pace is right. Heat, dizziness, or pelvic pressure that feels sharp means stop.',
  ),
  GuideItem(
    title: 'Walks after meals',
    tag: 'Glucose',
    body:
        'Ten minutes after lunch and dinner helps blood sugar and reflux more than one long session you will skip.',
  ),
  GuideItem(
    title: 'Pelvic floor, both ways',
    tag: 'Core',
    body:
        'Lift on an exhale, then fully let go. The release is the part most people skip, and it matters for birth and after.',
  ),
  GuideItem(
    title: 'Strength that stays kind',
    tag: 'Strength',
    body:
        'Sit-to-stand, wall push-ups, band rows. Skip breath-holding and any move that cones the belly.',
  ),
  GuideItem(
    title: 'When to call instead of stretch',
    tag: 'Red flags',
    body:
        'Bleeding, fluid leak, regular painful contractions, chest pain, or a sudden drop in movement — that is a clinician, not a yoga video.',
  ),
];

const defaultHospitalBag = <Map<String, String>>[
  {'group': 'For you', 'label': 'ID and insurance / hospital file'},
  {'group': 'For you', 'label': 'Birth notes and this app on offline mode'},
  {'group': 'For you', 'label': 'Soft going-home clothes and nursing bra'},
  {'group': 'For you', 'label': 'Toiletries, lip balm, hair tie'},
  {'group': 'For you', 'label': 'Phone charger and long cable'},
  {'group': 'For baby', 'label': 'Going-home outfit and hat'},
  {'group': 'For baby', 'label': 'Approved car seat installed'},
  {'group': 'For partner', 'label': 'Snacks, water, change of shirt'},
];

const defaultNursery = <Map<String, String>>[
  {'group': 'Sleep', 'label': 'Flat, firm crib mattress'},
  {'group': 'Sleep', 'label': 'Fitted sheets, no loose blankets'},
  {'group': 'Feeding', 'label': 'Bottles or nursing pillow'},
  {'group': 'Feeding', 'label': 'Burp cloths'},
  {'group': 'Care', 'label': 'Diapers and a simple ointment'},
  {'group': 'Care', 'label': 'Rear-facing car seat'},
  {'group': 'Clothes', 'label': 'Onesies in the next size up'},
];

const defaultShop = <Map<String, String>>[
  {'group': 'Now', 'label': 'Prenatal vitamin you can keep down'},
  {'group': 'Now', 'label': 'Soft waistband pants and two nursing bras'},
  {'group': 'Now', 'label': 'Pillow that actually supports the side-sleep'},
  {'group': 'Later', 'label': 'Approved rear-facing car seat'},
  {'group': 'Later', 'label': 'Flat crib mattress and two fitted sheets'},
  {'group': 'Later', 'label': 'Going-home outfit in newborn and 0–3'},
  {'group': 'Pharmacy', 'label': 'Iron, calcium, or thyroid fill as prescribed'},
  {'group': 'Pharmacy', 'label': 'Thermometer and a simple pain plan from your clinic'},
];

const defaultVisitQuestions = <Map<String, String>>[
  {'group': 'Every visit', 'label': 'What should I watch for before the next visit?'},
  {'group': 'Every visit', 'label': 'Which medicines and vitamins stay, change, or stop?'},
  {'group': 'Every visit', 'label': 'Is baby’s growth on the curve you expect?'},
  {'group': 'Second trimester', 'label': 'When is the anatomy scan, and what does it look for?'},
  {'group': 'Second trimester', 'label': 'Do I need Tdap, flu, or a glucose test soon?'},
  {'group': 'Third trimester', 'label': 'When should I call about reduced movement?'},
  {'group': 'Third trimester', 'label': 'What is the plan if I go past my due date?'},
  {'group': 'Third trimester', 'label': 'Who do I call at night, and what belongs in the bag?'},
];

const defaultVaccines = <Map<String, dynamic>>[
  {'name': 'Tdap (whooping cough)', 'dueWeek': 28},
  {'name': 'Influenza (in season)', 'dueWeek': 16},
  {'name': 'COVID booster if offered', 'dueWeek': 20},
  {'name': 'Hepatitis B (if indicated)', 'dueWeek': 12},
];

const babyNameSeed = <Map<String, String>>[
  {'name': 'Aanya', 'origin': 'Sanskrit', 'note': 'Grace'},
  {'name': 'Ira', 'origin': 'Sanskrit', 'note': 'Earth, the wind'},
  {'name': 'Mira', 'origin': 'Sanskrit', 'note': 'Wonder, limit'},
  {'name': 'Noor', 'origin': 'Arabic / Persian', 'note': 'Light'},
  {'name': 'Veda', 'origin': 'Sanskrit', 'note': 'Knowledge'},
  {'name': 'Zara', 'origin': 'Arabic / Hebrew', 'note': 'Bloom, dawn'},
  {'name': 'Arin', 'origin': 'Sanskrit', 'note': 'Enlightened'},
  {'name': 'Kabir', 'origin': 'Arabic / Indian', 'note': 'Great'},
  {'name': 'Reyansh', 'origin': 'Sanskrit', 'note': 'Ray of light'},
  {'name': 'Sami', 'origin': 'Arabic', 'note': 'Elevated'},
  {'name': 'Dev', 'origin': 'Sanskrit', 'note': 'Divine'},
  {'name': 'Lina', 'origin': 'Arabic / Latin', 'note': 'Tender'},
];

const donorSeed = <Map<String, dynamic>>[
  {
    'name': 'Anika Shah',
    'bloodGroup': 'O+',
    'city': 'Mumbai',
    'phone': '9876500001',
    'lat': 19.07,
    'lng': 72.87,
  },
  {
    'name': 'Rahul Mehta',
    'bloodGroup': 'A+',
    'city': 'Delhi',
    'phone': '9876500002',
    'lat': 28.61,
    'lng': 77.20,
  },
  {
    'name': 'Fatima Khan',
    'bloodGroup': 'B+',
    'city': 'Hyderabad',
    'phone': '9876500003',
    'lat': 17.38,
    'lng': 78.48,
  },
  {
    'name': 'Priya Nair',
    'bloodGroup': 'O-',
    'city': 'Bengaluru',
    'phone': '9876500004',
    'lat': 12.97,
    'lng': 77.59,
  },
  {
    'name': 'Aarav Joshi',
    'bloodGroup': 'AB+',
    'city': 'Pune',
    'phone': '9876500005',
    'lat': 18.52,
    'lng': 73.85,
  },
];

class DailyCard {
  const DailyCard({
    required this.kind,
    required this.title,
    required this.body,
  });

  final String kind;
  final String title;
  final String body;
}

const dailyDeck = <DailyCard>[
  DailyCard(
    kind: 'affirmation',
    title: 'You are already doing the work',
    body: 'Rest is not a reward you earn after a perfect day. It is part of growing a person.',
  ),
  DailyCard(
    kind: 'nutrition',
    title: 'A lemon with your dal',
    body: 'Vitamin C helps the iron in lunch actually land. One squeeze is enough.',
  ),
  DailyCard(
    kind: 'myth',
    title: 'Myth: you must eat for two',
    body: 'Fact: hunger and a balanced plate matter more than doubling portions. Extra need is modest until later weeks.',
  ),
  DailyCard(
    kind: 'smile',
    title: 'A tiny joke for a long afternoon',
    body: 'The baby already has a favorite song: the kettle, the corridor, and your laugh in the other room.',
  ),
  DailyCard(
    kind: 'affirmation',
    title: 'This body is improvising beautifully',
    body: 'Swelling, hunger, and a new walk are not failures of discipline. They are adaptation.',
  ),
  DailyCard(
    kind: 'nutrition',
    title: 'Protein before noon',
    body: 'Eggs, curd, or leftovers from dinner keep the mid-morning crash quieter.',
  ),
  DailyCard(
    kind: 'myth',
    title: 'Myth: heartburn means a hairy baby',
    body: 'Fact: heartburn is hormones plus a rising uterus. It is annoying, not a fortune-telling tool.',
  ),
  DailyCard(
    kind: 'smile',
    title: 'Kick translation',
    body: '3 a.m. solo: “I found the ribs.” You: “Wonderful. Please file a report in the morning.”',
  ),
];

DailyCard dailyFor(DateTime day) {
  final i = day.difference(DateTime(day.year)).inDays % dailyDeck.length;
  return dailyDeck[i];
}

List<DailyCard> dailySetFor(DateTime day) {
  final start = day.difference(DateTime(day.year)).inDays;
  return [
    dailyDeck[start % dailyDeck.length],
    dailyDeck[(start + 2) % dailyDeck.length],
    dailyDeck[(start + 4) % dailyDeck.length],
    dailyDeck[(start + 6) % dailyDeck.length],
  ];
}
