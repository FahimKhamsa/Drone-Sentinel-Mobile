// lib/presentation/home/widgets/sound_detection_dashboard_widget.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class SoundDetectionDashboardWidget extends StatelessWidget {
  final bool isDetecting;
  final bool isDroneDetected;
  final double detectionConfidence;
  final double detectionThreshold;
  final ValueChanged<double> onThresholdChanged;
  final List<double> samples;
  final List<double> audioFrequencies;
  final List<double> predictionScores;

  const SoundDetectionDashboardWidget({
    super.key,
    required this.isDetecting,
    required this.isDroneDetected,
    required this.detectionConfidence,
    required this.detectionThreshold,
    required this.onThresholdChanged,
    required this.samples,
    required this.audioFrequencies,
    required this.predictionScores,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dashboard Header
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.dashboard,
                  color: AppColors.textColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.detectionDashboard,
                style: const TextStyle(
                  color: AppColors.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Listening Status
          if (isDetecting) ...[
            Center(
              child: Text(
                AppLocalizations.of(context)!.listeningForSounds,
                style: const TextStyle(
                  color: AppColors.successColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // System Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(color: AppColors.primaryColor, width: 4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.radio_button_checked,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.systemStatus,
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Monitoring For
                _buildStatusItem(
                  context,
                  AppLocalizations.of(context)!.monitoringFor,
                  AppLocalizations.of(context)!.backgroundNoiseFpvDrone,
                  Icons.search,
                  AppColors.textSecondaryColor,
                ),
                const SizedBox(height: 12),

                // Microphone Status
                _buildStatusItem(
                  context,
                  AppLocalizations.of(context)!.microphone,
                  AppLocalizations.of(context)!.connected,
                  Icons.mic,
                  AppColors.successColor,
                ),
                const SizedBox(height: 12),

                // Model Status
                _buildStatusItem(
                  context,
                  AppLocalizations.of(context)!.model,
                  AppLocalizations.of(context)!.loaded,
                  Icons.memory,
                  AppColors.successColor,
                ),
                const SizedBox(height: 12),

                // Detection Status
                _buildStatusItem(
                  context,
                  AppLocalizations.of(context)!.detectionStatus,
                  isDetecting
                      ? AppLocalizations.of(context)!.listening
                      : AppLocalizations.of(context)!.waitingForSounds,
                  Icons.hearing,
                  isDetecting
                      ? AppColors.successColor
                      : AppColors.textSecondaryColor,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Loading Model Status
          if (!isDetecting) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    color: AppColors.textSecondaryColor,
                    width: 4,
                  ),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.loadingSoundDetectionModel,
                style: const TextStyle(
                  color: AppColors.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Detection Controls (when listening)
          if (isDetecting) ...[
            // Detection Threshold
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(color: AppColors.primaryColor, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.tune,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${AppLocalizations.of(context)!.detectionThreshold}:',
                        style: const TextStyle(
                          color: AppColors.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${detectionThreshold.toInt()}%',
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primaryColor,
                      inactiveTrackColor: AppColors.textSecondaryColor,
                      thumbColor: Colors.white,
                      overlayColor: AppColors.primaryColor.withOpacity(0.2),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                    ),
                    child: Slider(
                      value: detectionThreshold,
                      min: 0,
                      max: 100,
                      onChanged: onThresholdChanged,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.moreDetections,
                        style: const TextStyle(
                          color: AppColors.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.higherAccuracy,
                        style: const TextStyle(
                          color: AppColors.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Sound Detection Meter
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(color: AppColors.primaryColor, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.graphic_eq,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.soundDetectionMeter,
                        style: const TextStyle(
                          color: AppColors.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Circular Meter - Show actual drone prediction percentage
                  Center(
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: CustomPaint(
                        painter: CircularMeterPainter(
                          percentage:
                              predictionScores.length > 1
                                  ? (predictionScores[1] * 100)
                                  : 0.0,
                          isDroneDetected: isDroneDetected,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${predictionScores.length > 1 ? (predictionScores[1] * 100).toStringAsFixed(1) : "0.0"}%',
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)!.listening,
                                style: const TextStyle(
                                  color: AppColors.textSecondaryColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Detection Bars - Use actual prediction scores from model
                  _buildDetectionBar(
                    context,
                    AppLocalizations.of(context)!.backgroundNoise,
                    predictionScores.isNotEmpty
                        ? (predictionScores[0] * 100)
                        : 0.0,
                    predictionScores.isNotEmpty
                        ? (predictionScores[0] >
                            (predictionScores.length > 1
                                ? predictionScores[1]
                                : 0.0))
                        : false,
                  ),
                  const SizedBox(height: 8),
                  _buildDetectionBar(
                    context,
                    AppLocalizations.of(context)!.fpvDrone,
                    predictionScores.length > 1
                        ? (predictionScores[1] * 100)
                        : 0.0,
                    isDroneDetected,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionBar(
    BuildContext context,
    String label,
    double percentage,
    bool isActive,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textColor, fontSize: 14),
          ),
        ),
        Expanded(
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage / 100,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color:
                          isActive
                              ? AppColors.primaryColor
                              : AppColors.textSecondaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 50,
          child: Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              color:
                  isActive
                      ? AppColors.primaryColor
                      : AppColors.textSecondaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class CircularMeterPainter extends CustomPainter {
  final double percentage;
  final bool isDroneDetected;

  CircularMeterPainter({
    required this.percentage,
    required this.isDroneDetected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background arc
    final backgroundPaint =
        Paint()
          ..color = AppColors.backgroundColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    // Progress arc
    final progressPaint =
        Paint()
          ..color =
              isDroneDetected
                  ? AppColors.primaryColor
                  : AppColors.textSecondaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

    final sweepAngle = (percentage / 100) * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
