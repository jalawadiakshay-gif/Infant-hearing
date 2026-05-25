import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import 'package:infant_hearing_app/core/localization/app_localizations.dart';
import '../controllers/boa_controller.dart';
import '../state/boa_state.dart';
import '../../domain/boa_models.dart';
import '../widgets/boa_response_buttons.dart';
import '../widgets/waveform_painter.dart';

class BoaTestScreen extends StatefulWidget {
  const BoaTestScreen({super.key});

  @override
  State<BoaTestScreen> createState() => _BoaTestScreenState();
}

class _BoaTestScreenState extends State<BoaTestScreen> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final controller = context.read<BoaController>();
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      controller.releaseResources();
    } else if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) controller.initialize();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BoaController>();
    final state = controller.state;
    final l10n = AppLocalizations.of(context);

    if (state.isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(RouteConstants.boaResult);
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Layer
          Positioned.fill(child: _buildCameraLayer(controller, state, l10n)),

          // 2. Presence Overlay
          if (!state.isBabyPresent && !state.manualPresenceOverride && state.isCameraInitialized)
            Positioned.fill(child: _PresenceOverlay(l10n: l10n, controller: controller)),

          // 3. AI Detection Badge
          if (state.aiDetection != AiDetectionType.none && (state.phase == BoaTestPhase.playing || state.phase == BoaTestPhase.catchTrial))
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              left: AppSpacing.l,
              right: AppSpacing.l,
              child: _AiDetectionBadge(type: state.aiDetection, l10n: l10n),
            ),

          // 4. Catch Trial Indicator
          if (state.isCatchTrial)
             Positioned(
               top: MediaQuery.of(context).padding.top + 120,
               left: AppSpacing.l,
               child: Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(color: Colors.purple.withOpacity(0.8), borderRadius: BorderRadius.circular(4)),
                 child: const Text("CATCH TRIAL (SILENT)", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
               ),
             ),

          // 5. Controls Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: _ControlsPanel(state: state, controller: controller, l10n: l10n),
          ),

          // 6. Top Bar
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: _TopBar(l10n: l10n, controller: controller),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraLayer(BoaController controller, BoaState state, AppLocalizations l10n) {
    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: AppSpacing.m),
              Text(state.errorMessage!, style: AppTextStyles.bodyLarge.copyWith(color: Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.l),
              ElevatedButton(onPressed: controller.initialize, child: Text(l10n.retry)),
            ],
          ),
        ),
      );
    }
    if (controller.cameraController == null || !controller.cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    
    return Center(
      child: CameraPreview(controller.cameraController!),
    );
  }
}

class _PresenceOverlay extends StatelessWidget {
  final AppLocalizations l10n;
  final BoaController controller;
  const _PresenceOverlay({required this.l10n, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scrim,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.face_retouching_off_rounded, color: Colors.white, size: 64),
            const SizedBox(height: AppSpacing.l),
            Text(
              l10n.aiPositionBaby,
              style: AppTextStyles.h3.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Ensure infant's face is clearly visible to begin testing",
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            ElevatedButton(
              onPressed: () {
                controller.setManualPresenceOverride(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Proceed Anyway (Clinician Override)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiDetectionBadge extends StatelessWidget {
  final AiDetectionType type;
  final AppLocalizations l10n;
  const _AiDetectionBadge({required this.type, required this.l10n});

  @override
  Widget build(BuildContext context) {
    String label = '';
    Color color = AppColors.success;
    IconData icon = Icons.auto_awesome;

    switch (type) {
      case AiDetectionType.eyeBlink: label = l10n.aiEyeBlink; break;
      case AiDetectionType.headTurn: label = l10n.aiHeadTurn; break;
      case AiDetectionType.moroReflex: 
        label = "Startle/Moro Reflex Detected"; 
        color = Colors.orange;
        icon = Icons.bolt_rounded;
        break;
      case AiDetectionType.bodyMovement:
        label = "Body Movement Detected";
        icon = Icons.accessibility_new_rounded;
        break;
      default: return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9), 
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: AppSpacing.s),
            Text(label, style: AppTextStyles.button.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ControlsPanel extends StatelessWidget {
  final BoaState state;
  final BoaController controller;
  final AppLocalizations l10n;
  const _ControlsPanel({required this.state, required this.controller, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isPlaying = state.phase == BoaTestPhase.playing || state.phase == BoaTestPhase.catchTrial;

    return Container(
      padding: EdgeInsets.fromLTRB(AppSpacing.l, AppSpacing.l, AppSpacing.l, bottomPadding + AppSpacing.l),
      decoration: const BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.only(topLeft: Radius.circular(AppSpacing.radiusXL), topRight: Radius.circular(AppSpacing.radiusXL)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPlaying) ...[
            const AudioWaveform(isPlaying: true, color: AppColors.primary),
            const SizedBox(height: AppSpacing.m),
          ],
          Row(
            children: [
              Container(padding: const EdgeInsets.all(AppSpacing.s), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(AppSpacing.radiusM)), child: const Icon(Icons.hearing, color: AppColors.primary, size: 20)),
              const SizedBox(width: AppSpacing.m),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(state.currentDbLevel.label, style: AppTextStyles.h3), Text(state.currentFrequency.label, style: AppTextStyles.caption)])),
              if (isPlaying) _PlaybackIndicator(progress: state.playbackProgress),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          _GuidanceBanner(state: state, l10n: l10n),
          const SizedBox(height: AppSpacing.l),
          if (state.canPlay) 
            SizedBox(
              width: double.infinity, 
              height: 56, 
              child: ElevatedButton.icon(
                onPressed: state.isCooldownActive ? null : () => controller.startTrial(), 
                icon: state.isCooldownActive 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.play_arrow_rounded, size: 28), 
                label: Text(
                  state.isCooldownActive ? "Wait (Cooldown)..." : l10n.boaStartTest,
                  style: AppTextStyles.button.copyWith(fontSize: 18)
                ), 
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, 
                  foregroundColor: Colors.white, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusL))
                )
              )
            ),
          if (state.canRespond) BoaResponseButtons(onResponse: controller.recordResponse),
        ],
      ),
    );
  }
}

class _PlaybackIndicator extends StatelessWidget {
  final double progress;
  const _PlaybackIndicator({required this.progress});
  @override
  Widget build(BuildContext context) {
    return Container(width: 48, height: 48, padding: const EdgeInsets.all(4), child: Stack(alignment: Alignment.center, children: [CircularProgressIndicator(value: progress, strokeWidth: 4, backgroundColor: AppColors.border, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary)), Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))]));
  }
}

class _GuidanceBanner extends StatelessWidget {
  final BoaState state;
  final AppLocalizations l10n;
  const _GuidanceBanner({required this.state, required this.l10n});
  @override
  Widget build(BuildContext context) {
    String msg = ''; Color color = AppColors.secondary; IconData icon = Icons.info_outline;
    switch (state.phase) {
      case BoaTestPhase.idle: 
      case BoaTestPhase.infantDetection:
        msg = l10n.preCheckInfantAlert; icon = Icons.emoji_emotions_outlined; break;
      case BoaTestPhase.playing: 
      case BoaTestPhase.catchTrial:
        msg = l10n.boaPlaying; color = AppColors.primary; icon = Icons.volume_up_rounded; break;
      case BoaTestPhase.awaitingResponse: msg = l10n.boaResponse; color = AppColors.warning; icon = Icons.visibility_outlined; break;
      default: msg = l10n.done;
    }
    return Container(padding: const EdgeInsets.all(AppSpacing.m), decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(AppSpacing.radiusM)), child: Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: AppSpacing.m), Expanded(child: Text(msg, style: AppTextStyles.bodyMedium.copyWith(color: color, fontWeight: FontWeight.bold)))]));
  }
}

class _TopBar extends StatelessWidget {
  final AppLocalizations l10n;
  final BoaController controller;
  const _TopBar({required this.l10n, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s, vertical: AppSpacing.s),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              l10n.boaTest,
              style: AppTextStyles.h3.copyWith(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white),
            onPressed: controller.toggleCamera,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => _confirmReset(context),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.retry),
        content: const Text('Restart current test? All progress will be cleared.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              controller.reset();
              Navigator.pop(context);
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
