import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';

class AiService {
  Future<String> complete({
    required String apiKey,
    required String prompt,
    List<ChatMessage> history = const [],
  }) async {
    if (apiKey.trim().isEmpty) {
      return _offlineReply(prompt);
    }
    try {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
      );
      final contents = <Map<String, dynamic>>[
        ...history.map(
          (m) => {
            'role': m.role == 'user' ? 'user' : 'model',
            'parts': [
              {'text': m.text},
            ],
          },
        ),
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
          ],
        },
      ];
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'systemInstruction': {
            'parts': [
              {
                'text':
                    'You are Mira, a calm pregnancy companion for people in India. You are not a doctor. Flag emergencies (bleeding, severe pain, no movement, fluid leak, headache with vision change) and tell the user to seek care. Keep answers warm, short, and practical.',
              },
            ],
          },
          'contents': contents,
        }),
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final text = (((json['candidates'] as List?)?.first
                as Map?)?['content'] as Map?)?['parts'] as List?;
        final part = text?.first as Map?;
        final out = part?['text'] as String?;
        if (out != null && out.trim().isNotEmpty) return out.trim();
      }
      return _offlineReply(prompt);
    } catch (_) {
      return _offlineReply(prompt);
    }
  }

  String _offlineReply(String prompt) {
    final p = prompt.toLowerCase();
    if (p.contains('symptom') || p.contains('normal') || p.contains('pain')) {
      return 'I can sit with this, but I am not a clinician. Mild aches, nausea, and Braxton Hicks are common. Bleeding, fluid leak, a sudden drop in movement, chest pain, or a headache with vision changes is urgent — call your hospital or 108. Add your Gemini key in Settings if you want a fuller read of what you typed.';
    }
    if (p.contains('meal') || p.contains('eat') || p.contains('food')) {
      return 'A steady plate: protein + color + something you can actually keep down. Lemon on dal for iron, a walk after lunch, water you will drink. I can write a week of meals once a Gemini key is saved in Settings.';
    }
    if (p.contains('yoga') || p.contains('wellness')) {
      return 'This week: cat-cow, a supported squat, and side-lying rest. Stop if anything feels sharp. A custom plan needs your Gemini key in Settings.';
    }
    if (p.contains('summary') || p.contains('week')) {
      return 'I can summarize your logs once they are in Care — water, sleep, mood, medicines. With a Gemini key I will write that as a letter, not a spreadsheet.';
    }
    return 'I am Mira. I can talk through symptoms, meals, movement, and your week — and I will always send you to a human when something looks urgent. Add a Gemini API key in Settings for live answers; until then I will stay practical and local.';
  }
}
