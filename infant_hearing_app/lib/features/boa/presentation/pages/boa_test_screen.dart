import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:infant_hearing_app/core/theme/app_colors.dart';
import 'package:infant_hearing_app/core/theme/app_spacing.dart';
import 'package:infant_hearing_app/core/theme/app_text_styles.dart';
import 'package:infant_hearing_app/core/constants/route_constants.dart';
import '../controllers/boa_controller.dart';
import '../state/boa_state.dart';
import '../../domain/boa_models.dart';
import '../widgets/boa_response_buttons.dart';
import '../widgets/boa_waveform_widget.dart';
import '../../../baby/providers/baby_provider.dart';

class BoaTestScreen extends StatefulWidget {
  const BoaTestScreen({super.key});

  @override
  State<BoaTestScreen> createState() => _BoaTestScreenState();
}

class _BoaTestScreenState extends State<BoaTestScreen>
    with WidgetsBindingObserver {
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Fetch baby age for age-adaptive CV scoring
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final baby = context.read<BabyProvider>().baby;
      if (baby != null) {
        final ageMonths = DateTime.now().difference(baby.dob).inDays ~/ 30;
        context.read<BoaController>().setInfantAge(ageMonths);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final ctrl = context.read<BoaController>();
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        ctrl.onAppPaused();
        break;
      case AppLifecycleState.resumed:
        ctrl.onAppResumed();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BoaController>();
    final state = controller.state;

    // Navigate to result screen when test completes
    if (state.isComplete && !_navigating) {
      _navigating = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(RouteConstants.boaResult);
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Camera preview (fills screen)
          _CameraLayer(controller: controller, state: state),

          // Layer 2: Face alignment overlay (shown before test)
          if (state.isCameraInitialized &&
              state.phase != BoaTestPhase.complete)
            const _FaceGuideOverlay(),

          // Layer 3: Baby-not-detected overlay
          if (!state.isBabyPresent &&
              !state.manualPresenceOverride &&
              state.isCameraInitialized &&
              state.phase == BoaTestPhase.infantDetection)
            _PresenceOverlay(controller: controller),

          // Layer 4: Brightness warning
          if (state.isCameraInitialized && state.baselineMotion == 0.0 &&
              state.phase == BoaTestPhase.infantDetection)
            const Positioned(
              top: 120,
              left: AppSpacing.l,
              right: AppSpacing.l,
              child: _LightingBadge(),
            ),

          // Layer 4b: Noise Floor Monitor
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            right: AppSpacing.l,
            child: _NoiseFloorBadge(noiseDb: state.noiseLevel),
          ),

          // Layer 5: AI detection badge (during active trial only)
          if (state.aiDetection != AiDetectionType.none &&
              state.aiDetection != AiDetectionType.babyDetected &&
              state.aiDetection != AiDetectionType.noBabyDetected &&
              (state.isPlaying || state.phase == BoaTestPhase.awaitingResponse))
            Positioned(
              top: MediaQuery.of(context).padding.top + 68,
              left: AppSpacing.l,
              right: AppSpacing.l,
              child: _AiDetectionBadge(
                type: state.aiDetection,
                strength: state.responseStrength,
              ),
            ),

          // Layer 6: Catch trial indicator
          if (state.isCatchTrial)
            Positioned(
              top: MediaQuery.of(context).padding.top + 68,
              left: AppSpacing.l,
              child: _CatchTrialBadge(),
            ),

          // Layer 6b: CV Debug Overlay (Debug Mode Only)
          if (kDebugMode && state.isCameraInitialized)
            Positioned(
              top: MediaQuery.of(context).padding.top + 100,
              right: AppSpacing.s,
              child: _CvDebugOverlay(state: state),
            ),

          // Layer 7: Controls panel (bottom)
          Align(
            alignment: Alignment.bottomCenter,
            child: _ControlsPanel(
              state: state,
              controller: controller,
            ),
          ),

          // Layer 8: Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(controller: controller),
          ),
        ],
      ),
    );
  }
}

// ── Camera Layer ─────────────────────────────────────────────────────────────

class _CameraLayer extends StatelessWidget {
  final BoaController controller;
  final BoaState state;

  const _CameraLayer({required this.controller, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 56),
              const SizedBox(height: AppSpacing.m),
              Text(
                state.errorMessage!,
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.l),
              ElevatedButton.icon(
                onPressed: controller.initialize,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final cam = controller.cameraController;
    if (cam == null || !cam.value.isInitialized) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    // Use AspectRatio to prevent camera preview stretching
    return Center(
      child: AspectRatio(
        aspectRatio: 1 / cam.value.aspectRatio,
        child: CameraPreview(cam),
      ),
    );
  }
}

// ── Face Guide Overlay ────────────────────────────────────────────────────────

class _FaceGuideOverlay extends StatelessWidget {
  const _FaceGuideOverlay();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ovalW = size.width * 0.55;
    final ovalH = ovalW * 1.35;
    return Positioned(
      top: size.height * 0.12,
      left: (size.width - ovalW) / 2,
      child: Container(
        width: ovalW,
        height: ovalH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ovalW / 2),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
      ),
    );
  }
}

// ── Baby Presence Overlay ─────────────────────────────────────────────────────

class _PresenceOverlay extends StatelessWidget {
  final BoaController controller;

  const _PresenceOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.72),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.face_retouching_off_rounded,
                  size: 64, color: AppColors.warning),
              const SizedBox(height: AppSpacing.l),
              Text(
                'Position Infant',
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                "Hold the device so the infant's face is clearly visible within the oval guide.",
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.l),
              OutlinedButton(
                onPressed: () => controller.setManualPresenceOverride(true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.border),
                ),
                child: const Text('Proceed Without Detection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── AI Detection Badge ─────────────────────────────────────────────────────────

class _AiDetectionBadge extends StatelessWidget {
  final AiDetectionType type;
  final ResponseStrength strength;

  const _AiDetectionBadge({required this.type, required this.strength});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    IconData icon;

    switch (type) {
      case AiDetectionType.eyeBlink:
        label = 'Eye Response';
        color = AppColors.success;
        icon = Icons.visibility_rounded;
        break;
      case AiDetectionType.headTurn:
        label = 'Head Turn';
        color = AppColors.primary;
        icon = Icons.rotate_90_degrees_cw_rounded;
        break;
      case AiDetectionType.moroReflex:
        label = 'Startle Reflex';
        color = Colors.orange;
        icon = Icons.bolt_rounded;
        break;
      case AiDetectionType.bodyMovement:
        label = 'Movement';
        color = AppColors.secondary;
        icon = Icons.accessibility_new_rounded;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l, vertical: AppSpacing.s),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          boxShadow: const [
            BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3))
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.m),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('AI VERIFIED: $label',
                    style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w900,
                        fontSize: 8,
                        letterSpacing: 1.0)),
                Text(strength.label,
                    style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Noise Floor Badge ────────────────────────────────────────────────────────

class _NoiseFloorBadge extends StatelessWidget {
  final double noiseDb;
  const _NoiseFloorBadge({required this.noiseDb});

  @override
  Widget build(BuildContext context) {
    final status = _getStatus();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: status.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.graphic_eq_rounded, color: status.color, size: 12),
          const SizedBox(width: 4),
          Text(
            '${noiseDb.toStringAsFixed(0)} dB',
            style: TextStyle(color: status.color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  BoaNoiseStatus _getStatus() {
    if (noiseDb < 35) return BoaNoiseStatus.ideal;
    if (noiseDb < 45) return BoaNoiseStatus.acceptable;
    if (noiseDb < 60) return BoaNoiseStatus.noisy;
    return BoaNoiseStatus.invalid;
  }
}

// ── Catch Trial Badge ─────────────────────────────────────────────────────────

class _CatchTrialBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.science_rounded, color: Colors.white, size: 12),
          SizedBox(width: 4),
          Text('CATCH TRIAL',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── Lighting Badge ────────────────────────────────────────────────────────────

class _LightingBadge extends StatelessWidget {
  const _LightingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.light_mode_rounded, color: Colors.black87, size: 16),
          SizedBox(width: 6),
          Text('Move to a well-lit area',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Controls Panel (bottom sheet) ─────────────────────────────────────────────

class _ControlsPanel extends StatelessWidget {
  final BoaState state;
  final BoaController controller;

  const _ControlsPanel({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isPlaying = state.isPlaying;
    final isAwaiting = state.phase == BoaTestPhase.awaitingResponse;
    final isCalibrating = state.phase == BoaTestPhase.calibration;

    return Container(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.l, AppSpacing.l, AppSpacing.l, bottomPad + AppSpacing.l),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusXL),
          topRight: Radius.circular(AppSpacing.radiusXL),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              spreadRadius: 2)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Waveform (during playback)
          if (isPlaying) ...[
            AudioWaveformWidget(
              isPlaying: true,
              color: AppColors.primary,
              progress: state.playbackProgress,
            ),
            const SizedBox(height: AppSpacing.m),
          ],

          // Level + frequency row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                ),
                child:
                    const Icon(Icons.hearing, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.currentDbLevel.label,
                        style: AppTextStyles.h3),
                    Text(state.currentFrequency.label,
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              if (isPlaying) _ProgressRing(progress: state.playbackProgress),
              if (isAwaiting)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                  ),
                  child: Text(
                    'OBSERVE',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.m),

          // Status / guidance banner
          _GuidanceBanner(state: state),

          const SizedBox(height: AppSpacing.m),

          // Status override message (habituation, timeout)
          if (state.statusOverride != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Text(
                state.statusOverride!,
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
          ],

          // Play button
          if (state.canStartTrial || isCalibrating)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: (state.isCooldownActive || isCalibrating)
                    ? null
                    : () => controller.startTrial(),
                icon: isCalibrating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : state.isCooldownActive
                        ? const Icon(Icons.hourglass_top_rounded, size: 24)
                        : const Icon(Icons.play_arrow_rounded, size: 28),
                label: Text(
                  isCalibrating
                      ? 'Preparing stimulus...'
                      : state.isCooldownActive
                          ? 'Wait...'
                          : 'Play Sound Stimulus',
                  style: AppTextStyles.button.copyWith(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusL)),
                ),
              ),
            ),

          // Response buttons (shown during playing AND awaiting)
          if (state.canRespond) ...[
            const SizedBox(height: AppSpacing.m),
            BoaResponseButtons(onResponse: controller.recordResponse),
          ],
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress;
  const _ProgressRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3.5,
            backgroundColor: AppColors.border,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          Text(
            '${(progress * 3).toStringAsFixed(1)}s',
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _GuidanceBanner extends StatelessWidget {
  final BoaState state;
  const _GuidanceBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    String msg;
    Color color;
    IconData icon;

    switch (state.phase) {
      case BoaTestPhase.idle:
      case BoaTestPhase.infantDetection:
        if (!state.isBabyPresent && !state.manualPresenceOverride) {
          msg = 'Position infant in front of camera';
          color = AppColors.warning;
          icon = Icons.face_rounded;
        } else {
          msg = 'Ready. Tap "Play Sound Stimulus" to begin.';
          color = AppColors.secondary;
          icon = Icons.emoji_emotions_outlined;
        }
        break;
      case BoaTestPhase.baselineLearning:
        msg = 'Calibrating behavior... Keep infant still';
        color = AppColors.primary;
        icon = Icons.analytics_outlined;
        break;
      case BoaTestPhase.noiseCheck:
        msg = 'Checking ambient noise floor...';
        color = AppColors.info;
        icon = Icons.mic_external_on_rounded;
        break;
      case BoaTestPhase.calibration:
        msg = 'Preparing stimulus — keep infant still...';
        color = AppColors.primary;
        icon = Icons.timer_outlined;
        break;
      case BoaTestPhase.playing:
      case BoaTestPhase.catchTrial:
        msg = 'Sound playing — observe infant carefully';
        color = AppColors.primary;
        icon = Icons.volume_up_rounded;
        break;
      case BoaTestPhase.awaitingResponse:
        msg = 'Did the infant respond? Tap a button below.';
        color = AppColors.warning;
        icon = Icons.visibility_outlined;
        break;
      default:
        msg = 'Test complete.';
        color = AppColors.success;
        icon = Icons.check_circle_outline;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m, vertical: AppSpacing.s),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              msg,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top Bar ────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final BoaController controller;
  const _TopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(0, topPad, AppSpacing.s, AppSpacing.s),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.75), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          // FIX: Use context.pop() (GoRouter) not Navigator.pop()
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
            onPressed: () {
              controller.releaseResources().then((_) {
                if (context.mounted) context.pop();
              });
            },
          ),
          Expanded(
            child: Text(
              'BOA Test',
              style: AppTextStyles.h3.copyWith(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white),
            onPressed: controller.toggleCamera,
            tooltip: 'Flip camera',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => _confirmReset(context),
            tooltip: 'Restart test',
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restart Test?'),
        content: const Text('All progress will be cleared.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.reset();
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}

// ── CV Debug Overlay (Debug Mode Only) ────────────────────────────────────────

class _CvDebugOverlay extends StatelessWidget {
  final BoaState state;
  const _CvDebugOverlay({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('CV PIPELINE DEBUG', style: TextStyle(color: Colors.cyan, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          _DebugRow('Face Visibility:', '${(state.presenceConfidence * 100).toInt()}%'),
          _DebugRow('Pose Confidence:', '${(state.poseConfidence * 100).toInt()}%'),
          _DebugRow('Motion Floor:', state.baselineMotion.toStringAsFixed(1)),
          if (state.responseLatencyMs != null)
            _DebugRow('Latency:', '${state.responseLatencyMs}ms', highlight: true),
          if (state.cvExplanation != null && state.cvExplanation!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              state.cvExplanation!,
              style: const TextStyle(color: Colors.amber, fontSize: 10, fontStyle: FontStyle.italic),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _DebugRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _DebugRow(this.label, this.value, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(
            color: highlight ? Colors.amber : Colors.white,
            fontSize: 10,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
          )),
        ],
      ),
    );
  }
}
