import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:infant_hearing_app/core/constants/app_language.dart';
import 'package:infant_hearing_app/features/chatbot/services/chat_message.dart';
import 'package:infant_hearing_app/features/chatbot/services/chatbot_knowledge_base.dart';
import 'package:infant_hearing_app/core/config/app_config.dart';

class ChatbotProvider extends ChangeNotifier {
  static const String _apiEndpoint = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-sonnet-4-20250514';
  static const String _apiKey = String.fromEnvironment('ANTHROPIC_API_KEY', defaultValue: '');

  final List<ChatMessage> _messages = [];
  bool _loading = false;
  AppLanguage _language = AppLanguage.english;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _loading;

  // ── Language ─────────────────────────────────────────────────────────────
  void setLanguage(AppLanguage lang) {
    _language = lang;
    // No notifyListeners — language change doesn't change message history
  }

  // ── Send a message (typed or from voice) ─────────────────────────────────
  Future<String> sendMessage(String userText) async {
    if (userText.trim().isEmpty) return '';

    _addMessage(ChatMessage(
      role: MessageRole.user,
      content: userText.trim(),
      timestamp: DateTime.now(),
    ));
    _loading = true;
    notifyListeners();

    final response = await _generateResponse(userText.trim());

    if (response.isEmpty) {
      _loading = false;
      notifyListeners();
      return '';
    }

    _addMessage(ChatMessage(
      role: MessageRole.assistant,
      content: response,
      timestamp: DateTime.now(),
    ));
    _loading = false;
    notifyListeners();
    return response;
  }

  // ── Handle a quick-action button tap ─────────────────────────────────────
  Future<String> handleQuickAction(String intent) async {
    // Show the action label as a user message
    final label = _quickActionLabel(intent);
    _addMessage(ChatMessage(
      role: MessageRole.user,
      content: label,
      timestamp: DateTime.now(),
    ));
    _loading = true;
    notifyListeners();

    final rawResponse = ChatbotKnowledgeBase.responseForIntent(intent, _language);
    final response = ChatbotKnowledgeBase.formatResponse(rawResponse, _language);

    _addMessage(ChatMessage(
      role: MessageRole.assistant,
      content: response,
      timestamp: DateTime.now(),
    ));
    _loading = false;
    notifyListeners();
    return response;
  }

  void clearHistory() {
    _messages.clear();
    notifyListeners();
  }

  // ── Internal: rule-based first, AI fallback ───────────────────────────────
  Future<String> _generateResponse(String input) async {
    // 0. Domain Filter: Enforce child health / infant hearing scope only
    if (!ChatbotKnowledgeBase.isChildHealthQuery(input)) {
      return ChatbotKnowledgeBase.formatResponse(
        ChatbotKnowledgeBase.nonHealthResponse(_language),
        _language,
      );
    }

    // 1. Try rule-based
    final intent = ChatbotKnowledgeBase.detectIntent(input);
    if (intent != null) {
      return ChatbotKnowledgeBase.formatResponse(
        ChatbotKnowledgeBase.responseForIntent(intent, _language),
        _language,
      );
    }

    // TEMP MOCK: Disable AI API call for frontend development if useMocks is enabled
    if (AppConfig.useMocks) {
      await Future.delayed(const Duration(seconds: 1));
      return ChatbotKnowledgeBase.formatResponse(
        ChatbotKnowledgeBase.fallback(_language),
        _language,
      );
    }

    // 2. Try AI API
    if (_apiKey.isNotEmpty) {
      try {
        final apiRes = await _callApi(input);
        return ChatbotKnowledgeBase.formatResponse(apiRes, _language);
      } catch (e) {
        debugPrint('[Chatbot] API error: $e');
      }
    }

    // 3. Offline fallback
    return ChatbotKnowledgeBase.formatResponse(
      ChatbotKnowledgeBase.fallback(_language),
      _language,
    );
  }

  Future<String> _callApi(String userInput) async {
    final systemPrompt = '''
You are a helpful assistant for Baalshravya, an infant hearing screening app used in rural India.
${_languageInstruction()}
CRITICAL RULE: You MUST ONLY answer questions related to infant hearing, child health, baby development milestones, screening tests (OAE, ABR, BOA), and ear care.
If the user asks about ANYTHING unrelated to child health or hearing (such as general knowledge, coding, sports, politics, movies, or finance), you MUST politely refuse to answer and state: "I am a specialized child health and hearing screening assistant. I can only answer questions related to infant hearing and child health."

Your role:
- Answer questions about infant hearing loss, OAE, ABR, BOA tests.
- Explain hearing milestones for babies 0–12 months.
- Guide caregivers after screening results.
- Counter misinformation with evidence-based answers.
Safety: Never diagnose. Never recommend medications. For clinical decisions, say: "Please consult the JNMC Audiology department."
Keep answers to 3–4 sentences maximum for low-literacy users.
''';

    final apiMessages = [
      ..._messages
          .where((m) => m.type == MessageType.text)
          .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.content}),
      {'role': 'user', 'content': userInput},
    ];

    final response = await http.post(
      Uri.parse(_apiEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': 400,
        'system': systemPrompt,
        'messages': apiMessages,
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['content'][0]['text'] as String;
    }
    throw Exception('API ${response.statusCode}');
  }

  String _languageInstruction() {
    switch (_language) {
      case AppLanguage.hindi:
        return 'Respond ONLY in Hindi (हिंदी).';
      case AppLanguage.kannada:
        return 'Respond ONLY in Kannada (ಕನ್ನಡ).';
      case AppLanguage.english:
        return 'Respond ONLY in English.';
      case AppLanguage.marathi:
        return 'Respond ONLY in Marathi (मराठी).';
    }
  }

  String _quickActionLabel(String intent) {
    switch (_language) {
      case AppLanguage.hindi:
        switch (intent) {
          case ChatbotKnowledgeBase.intentMilestones:        return 'श्रवण मील के पत्थर';
          case ChatbotKnowledgeBase.intentSymptoms:          return 'लक्षण जांचें';
          case ChatbotKnowledgeBase.intentBookScreening:     return 'स्क्रीनिंग बुक करें';
          case ChatbotKnowledgeBase.intentQuestionnaireHelp: return 'प्रश्नावली सहायता';
          default: return intent;
        }
      case AppLanguage.marathi:
        switch (intent) {
          case ChatbotKnowledgeBase.intentMilestones:        return 'श्रवण टप्पे';
          case ChatbotKnowledgeBase.intentSymptoms:          return 'लक्षणे तपासा';
          case ChatbotKnowledgeBase.intentBookScreening:     return 'तपासणी बुक करा';
          case ChatbotKnowledgeBase.intentQuestionnaireHelp: return 'प्रश्नावली मदत';
          default: return intent;
        }
      case AppLanguage.kannada:
        switch (intent) {
          case ChatbotKnowledgeBase.intentMilestones:        return 'ಶ್ರವಣ ಮೈಲಿಗಲ್ಲುಗಳು';
          case ChatbotKnowledgeBase.intentSymptoms:          return 'ಲಕ್ಷಣಗಳನ್ನು ಪರಿಶೀಲಿಸಿ';
          case ChatbotKnowledgeBase.intentBookScreening:     return 'ಸ್ಕ್ರೀನಿಂಗ್ ಬುಕ್ ಮಾಡಿ';
          case ChatbotKnowledgeBase.intentQuestionnaireHelp: return 'ಪ್ರಶ್ನಾವಳಿ ಸಹಾಯ';
          default: return intent;
        }
      case AppLanguage.english:
        switch (intent) {
          case ChatbotKnowledgeBase.intentMilestones:        return 'Hearing Milestones';
          case ChatbotKnowledgeBase.intentSymptoms:          return 'Check Symptoms';
          case ChatbotKnowledgeBase.intentBookScreening:     return 'Book Screening';
          case ChatbotKnowledgeBase.intentQuestionnaireHelp: return 'Questionnaire Help';
          default: return intent;
        }
    }
  }

  void _addMessage(ChatMessage msg) => _messages.add(msg);
}
