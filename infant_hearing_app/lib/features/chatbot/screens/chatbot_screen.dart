import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import 'package:infant_hearing_app/core/providers/language_provider.dart';
import 'package:infant_hearing_app/core/services/tts_service.dart';
import 'package:infant_hearing_app/features/chatbot/providers/chatbot_provider.dart';
import 'package:infant_hearing_app/features/chatbot/services/speech_service.dart';
import 'package:infant_hearing_app/features/chatbot/widgets/chat_bubble.dart';
import 'package:infant_hearing_app/features/chatbot/widgets/chat_input_bar.dart';
import 'package:infant_hearing_app/features/chatbot/widgets/quick_action_bar.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  TtsService? _tts;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _tts = context.read<TtsService>();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tts?.stop(); 
    if (mounted) {
      context.read<SpeechService>().stopListening();
    }
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive || 
        state == AppLifecycleState.detached) {
      _tts?.stop();
      if (mounted) {
        context.read<SpeechService>().stopListening();
      }
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    if (!mounted) return;
    final chatbot = context.read<ChatbotProvider>();
    final lang = context.read<LanguageProvider>();
    final tts = context.read<TtsService>();

    chatbot.setLanguage(lang.language);
    final response = await chatbot.sendMessage(text);

    if (!mounted) return;
    if (response.isNotEmpty && chatbot.messages.isNotEmpty) {
      await tts.speak(response, messageId: chatbot.messages.last.timestamp.toString());
    }
    _scrollToBottom();
  }

  Future<void> _handleQuickAction(String intent) async {
    if (!mounted) return;
    final chatbot = context.read<ChatbotProvider>();
    final lang = context.read<LanguageProvider>();
    final tts = context.read<TtsService>();

    chatbot.setLanguage(lang.language);
    final response = await chatbot.handleQuickAction(intent);

    if (!mounted) return;
    if (response.isNotEmpty && chatbot.messages.isNotEmpty) {
      await tts.speak(response, messageId: chatbot.messages.last.timestamp.toString());
    }
    _scrollToBottom();
  }

  Future<void> _toggleMic() async {
    if (!mounted) return;
    final speech = context.read<SpeechService>();
    final lang = context.read<LanguageProvider>();
    final tts = context.read<TtsService>();

    if (speech.isListening) {
      await speech.stopListening();
      return;
    }

    await tts.stop();

    await speech.startListening(
      sttLocale: lang.sttLocale,
      onResult: (words, isFinal) {
        _controller.text = words;
        if (isFinal && words.isNotEmpty) _send();
      },
    );
  }

  void _confirmClear(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusL)),
        title: Text(l10n.chatbot, style: AppTextStyles.h3),
        content: Text(l10n.chatbotClearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel, style: AppTextStyles.button.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context.read<TtsService>().stop();
              context.read<ChatbotProvider>().clearHistory();
              Navigator.pop(ctx);
            },
            child: Text(l10n.submit, style: AppTextStyles.button.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chatbot = context.watch<ChatbotProvider>();
    final speech = context.watch<SpeechService>();
    final tts = context.watch<TtsService>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 36,
                height: 36,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.chatbot, style: AppTextStyles.h3),
                Text(
                  tts.isSpeaking
                      ? l10n.chatbotNarrating
                      : tts.isPaused
                          ? 'Paused'
                          : speech.isListening
                              ? l10n.chatbotListening
                              : l10n.chatbotReady,
                  style: AppTextStyles.caption.copyWith(
                    color: tts.isSpeaking || tts.isPaused || speech.isListening ? AppColors.primary : AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (tts.isSpeaking)
            IconButton(
              icon: const Icon(Icons.stop_circle_rounded, color: AppColors.error),
              onPressed: () => tts.stop(),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmClear(context, l10n),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.s),
          QuickActionBar(onTap: _handleQuickAction),
          const SizedBox(height: AppSpacing.s),
          const Divider(height: 1),

          Expanded(
            child: chatbot.messages.isEmpty
                ? _EmptyState(l10n: l10n)
                : ListView.builder(
                    controller: _scroll,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.l),
                    itemCount: chatbot.messages.length + (chatbot.isLoading ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i == chatbot.messages.length) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.l),
                          child: _TypingIndicator(),
                        );
                      }
                      final msg = chatbot.messages[i];
                      final msgId = msg.timestamp.toString();
                      final isThisSpeaking = tts.isSpeaking && tts.currentMessageId == msgId;
                      final isThisPaused = tts.isPaused && tts.currentMessageId == msgId;

                      return ChatBubble(
                        message: msg,
                        isSpeaking: isThisSpeaking,
                        isPaused: isThisPaused,
                        onSpeak: msg.isAssistant ? () => tts.speak(msg.content, messageId: msgId) : null,
                        onPause: isThisSpeaking ? () => tts.pause() : null,
                        onResume: isThisPaused ? () => tts.resume() : null,
                        onStop: (isThisSpeaking || isThisPaused) ? () => tts.stop() : null,
                      );
                    },
                  ),
          ),

          const Divider(height: 1),
          SafeArea(
            child: ChatInputBar(
              controller: _controller,
              isListening: speech.isListening,
              isSttAvailable: speech.isAvailable,
              onSend: _send,
              onMicToggle: _toggleMic,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxxl, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.forum_outlined, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.chatbotWelcome,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              l10n.chatbotWelcomeSub,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.m, top: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusL),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            SizedBox(width: 4),
            _Dot(delay: 200),
            SizedBox(width: 4),
            _Dot(delay: 400),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.textHint),
      ),
    );
  }
}
