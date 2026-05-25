import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// A single turn in the conversation.
class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, String> toApiMap() => {'role': role, 'content': content};
}

/// Calls the Claude API (or similar) with a language-enforcing system prompt.
///
/// The [languageInstruction] comes from [LanguageProvider.chatbotLanguageInstruction],
/// ensuring responses are always in the user's selected language.
class ChatbotService extends ChangeNotifier {
  static const String _apiEndpoint =
      'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-sonnet-4-20250514';

  // Replace with your actual API key or inject via env
  static const String _apiKey = String.fromEnvironment(
    'ANTHROPIC_API_KEY',
    defaultValue: '',
  );

  // ─── Offline FAQ fallback ────────────────────────────────────────
  static const Map<String, Map<String, String>> _offlineFaqs = {
    'hearing loss': {
      'en': 'Hearing loss in infants can often be detected early through '
          'screening. If you suspect your child has hearing difficulties, '
          'please visit a qualified audiologist.',
      'hi': 'शिशुओं में सुनने की समस्या जल्दी पकड़ी जा सकती है। '
          'यदि आपको संदेह है, कृपया एक योग्य ऑडियोलॉजिस्ट से मिलें।',
      'kn': 'ಶಿಶುಗಳಲ್ಲಿ ಶ್ರವಣ ನಷ್ಟವನ್ನು ಬೇಗನೆ ಗುರುತಿಸಬಹುದು. '
          'ನಿಮಗೆ ಸಂದೇಹವಿದ್ದರೆ, ಅರ್ಹ ಆಡಿಯಾಲಜಿಸ್ಟ್ ಅನ್ನು ಭೇಟಿ ಮಾಡಿ.',
    },
    'oae': {
      'en': 'OAE (Otoacoustic Emissions) is a painless, quick test that '
          'checks if the inner ear is working properly. It is safe for newborns.',
      'hi': 'OAE परीक्षण दर्दरहित और त्वरित है जो आंतरिक कान की जाँच करता है। '
          'यह नवजात शिशुओं के लिए सुरक्षित है।',
      'kn': 'OAE ಪರೀಕ್ಷೆಯು ನೋವುರಹಿತ ಮತ್ತು ತ್ವರಿತವಾಗಿದ್ದು ಒಳಗಿನ ಕಿವಿ '
          'ಸರಿಯಾಗಿ ಕಾರ್ಯ ನಿರ್ವಹಿಸುತ್ತಿದೆಯೇ ಎಂದು ಪರಿಶೀಲಿಸುತ್ತದೆ.',
    },
    'refer': {
      'en': 'A REFER result means your baby needs a follow-up hearing test '
          'at a clinic. This does not always mean hearing loss — please '
          'visit JNMC Audiology for confirmation.',
      'hi': 'REFER परिणाम का मतलब है कि आपके बच्चे को क्लिनिक में '
          'अनुवर्ती श्रवण परीक्षण की आवश्यकता है।',
      'kn': 'REFER ಫಲಿತಾಂಶ ಎಂದರೆ ನಿಮ್ಮ ಮಗುವಿಗೆ ಕ್ಲಿನಿಕ್‌ನಲ್ಲಿ '
          'ಮುಂದಿನ ಶ್ರವಣ ಪರೀಕ್ಷೆ ಅಗತ್ಯ.',
    },
  };

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _currentLanguageCode = 'en';

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  // ─── Public API ──────────────────────────────────────────────────

  void setLanguage(String code) {
    _currentLanguageCode = code;
  }

  Future<String> sendMessage({
    required String userMessage,
    required String languageInstruction,
  }) async {
    _messages = [
      ..._messages,
      ChatMessage(
        role: 'user',
        content: userMessage,
        timestamp: DateTime.now(),
      ),
    ];
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _callApi(userMessage, languageInstruction);
      _messages = [
        ..._messages,
        ChatMessage(
          role: 'assistant',
          content: response,
          timestamp: DateTime.now(),
        ),
      ];
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      debugPrint('[ChatbotService] API error: $e');
      final fallback = _getOfflineFallback(userMessage);
      _messages = [
        ..._messages,
        ChatMessage(
          role: 'assistant',
          content: fallback,
          timestamp: DateTime.now(),
        ),
      ];
      _isLoading = false;
      notifyListeners();
      return fallback;
    }
  }

  void clearHistory() {
    _messages = [];
    notifyListeners();
  }

  // ─── Internal ────────────────────────────────────────────────────

  Future<String> _callApi(
      String userMessage, String languageInstruction) async {
    if (_apiKey.isEmpty) {
      throw Exception('API key not configured');
    }

    final systemPrompt = '''
You are a helpful assistant for the Baalshravya infant hearing screening app, 
used by caregivers and health workers in rural India.

$languageInstruction

Your role:
- Help caregivers understand screening results
- Explain infant hearing milestones
- Guide users through the app
- Answer questions about hearing loss, OAE, ABR, BOA tests
- Counter misinformation with evidence-based answers

Safety guardrails:
- Never provide specific medical diagnoses
- Never recommend specific medications or dosages
- For clinical decisions, always say: "Please consult the doctor at JNMC Audiology"
- Keep answers short (2-4 sentences) for low-literacy users
''';

    final requestBody = {
      'model': _model,
      'max_tokens': 512,
      'system': systemPrompt,
      'messages': _messages.map((m) => m.toApiMap()).toList(),
    };

    final response = await http
        .post(
          Uri.parse(_apiEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': _apiKey,
            'anthropic-version': '2023-06-01',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['content'][0]['text'] as String;
    } else {
      throw Exception('API error ${response.statusCode}: ${response.body}');
    }
  }

  String _getOfflineFallback(String userMessage) {
    final lower = userMessage.toLowerCase();
    for (final entry in _offlineFaqs.entries) {
      if (lower.contains(entry.key)) {
        return entry.value[_currentLanguageCode] ??
            entry.value['en']!;
      }
    }
    // Generic fallback by language
    switch (_currentLanguageCode) {
      case 'hi':
        return 'मैं अभी इंटरनेट से नहीं जुड़ा हूँ। JNMC ऑडियोलॉजी में डॉक्टर से मिलें।';
      case 'kn':
        return 'ನಾನು ಈಗ ಇಂಟರ್ನೆಟ್‌ಗೆ ಸಂಪರ್ಕಿತನಾಗಿಲ್ಲ. JNMC ಆಡಿಯಾಲಜಿಯಲ್ಲಿ ವೈದ್ಯರನ್ನು ಭೇಟಿ ಮಾಡಿ.';
      default:
        return 'I am currently offline. Please visit the JNMC Audiology department for guidance.';
    }
  }
}
