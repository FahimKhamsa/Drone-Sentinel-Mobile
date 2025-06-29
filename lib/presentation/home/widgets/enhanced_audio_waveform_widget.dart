// lib/presentation/home/widgets/enhanced_audio_waveform_widget.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Enhanced audio waveform widget with smooth animations and better performance
class EnhancedAudioWaveformWidget extends StatefulWidget {
  final List<double> samples;
  final bool isDetecting;
  final bool isDroneDetected;
  final double confidence;

  const EnhancedAudioWaveformWidget({
    super.key,
    required this.samples,
    required this.isDetecting,
    this.isDroneDetected = false,
    this.confidence = 0.0,
  });

  @override
  State<EnhancedAudioWaveformWidget> createState() =>
      _EnhancedAudioWaveformWidgetState();
}

class _EnhancedAudioWaveformWidgetState
    extends State<EnhancedAudioWaveformWidget>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Glow animation for when detecting
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Pulse animation for drone detection
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
    );

    // Start animations based on initial state
    _updateAnimations();
  }

  @override
  void didUpdateWidget(EnhancedAudioWaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDetecting != widget.isDetecting ||
        oldWidget.isDroneDetected != widget.isDroneDetected) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    if (widget.isDetecting) {
      _glowController.repeat(reverse: true);
    } else {
      _glowController.stop();
      _glowController.reset();
    }

    if (widget.isDroneDetected) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isDroneDetected ? _pulseAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _getBorderColor(), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
                if (widget.isDetecting)
                  BoxShadow(
                    color: _getGlowColor().withOpacity(
                      _glowAnimation.value * 0.5,
                    ),
                    spreadRadius: 4,
                    blurRadius: 15,
                    offset: const Offset(0, 0),
                  ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Stack(
              children: [
                // Main waveform
                CustomPaint(
                  painter: _EnhancedWaveformPainter(
                    samples: widget.samples,
                    waveformColor: _getWaveformColor(),
                    isDetecting: widget.isDetecting,
                    isDroneDetected: widget.isDroneDetected,
                    confidence: widget.confidence,
                    glowIntensity: _glowAnimation.value,
                  ),
                  child: Container(),
                ),

                // Overlay text when no data
                if (widget.samples.isEmpty && !widget.isDetecting)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.graphic_eq,
                          color: Colors.grey.shade400,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start detection to see audio waveform',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                // Confidence indicator
                if (widget.isDetecting && widget.confidence > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(widget.confidence * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: _getConfidenceColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getBorderColor() {
    if (widget.isDroneDetected) {
      return Colors.red.shade400;
    } else if (widget.isDetecting) {
      return Colors.green.shade400;
    } else {
      return Colors.grey.shade600;
    }
  }

  Color _getGlowColor() {
    if (widget.isDroneDetected) {
      return Colors.red.shade400;
    } else {
      return Colors.green.shade400;
    }
  }

  Color _getWaveformColor() {
    if (widget.isDroneDetected) {
      return Colors.red.shade400;
    } else if (widget.isDetecting) {
      return Colors.cyanAccent.shade400;
    } else {
      return Colors.blueGrey.shade300;
    }
  }

  Color _getConfidenceColor() {
    if (widget.confidence > 0.7) {
      return Colors.red.shade400;
    } else if (widget.confidence > 0.4) {
      return Colors.orange.shade400;
    } else {
      return Colors.green.shade400;
    }
  }
}

class _EnhancedWaveformPainter extends CustomPainter {
  final List<double> samples;
  final Color waveformColor;
  final bool isDetecting;
  final bool isDroneDetected;
  final double confidence;
  final double glowIntensity;

  _EnhancedWaveformPainter({
    required this.samples,
    required this.waveformColor,
    required this.isDetecting,
    required this.isDroneDetected,
    required this.confidence,
    required this.glowIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) {
      return;
    }

    final double midY = size.height / 2;
    final double maxAmplitude = size.height * 0.4;

    // Downsample for smooth rendering
    List<double> processedSamples = _downsampleAudio(
      samples,
      (size.width / 1.5).round(),
    );
    final double dx = size.width / processedSamples.length;

    // Create paths
    final Path waveformPath = Path();
    final Path fillPath = Path();
    final List<Offset> points = [];

    // Generate points
    for (int i = 0; i < processedSamples.length; i++) {
      double x = i * dx;
      double normalizedSample = processedSamples[i].clamp(-1.0, 1.0);
      double y = midY - (normalizedSample * maxAmplitude);
      points.add(Offset(x, y));
    }

    // Create smooth curve through points
    if (points.isNotEmpty) {
      waveformPath.moveTo(points[0].dx, points[0].dy);
      fillPath.moveTo(0, midY);
      fillPath.lineTo(points[0].dx, points[0].dy);

      for (int i = 1; i < points.length; i++) {
        if (i == 1) {
          // First control point
          waveformPath.quadraticBezierTo(
            points[i - 1].dx,
            points[i - 1].dy,
            (points[i - 1].dx + points[i].dx) / 2,
            (points[i - 1].dy + points[i].dy) / 2,
          );
          fillPath.quadraticBezierTo(
            points[i - 1].dx,
            points[i - 1].dy,
            (points[i - 1].dx + points[i].dx) / 2,
            (points[i - 1].dy + points[i].dy) / 2,
          );
        } else {
          // Smooth curve
          double cpx = (points[i - 1].dx + points[i].dx) / 2;
          double cpy = (points[i - 1].dy + points[i].dy) / 2;
          waveformPath.quadraticBezierTo(
            points[i - 1].dx,
            points[i - 1].dy,
            cpx,
            cpy,
          );
          fillPath.quadraticBezierTo(
            points[i - 1].dx,
            points[i - 1].dy,
            cpx,
            cpy,
          );
        }
      }

      // Complete fill path
      fillPath.lineTo(size.width, midY);
      fillPath.close();
    }

    // Draw center line
    final Paint centerLinePaint =
        Paint()
          ..color = Colors.grey.shade700
          ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, midY), Offset(size.width, midY), centerLinePaint);

    // Draw fill with gradient
    final Paint fillPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              waveformColor.withOpacity(0.3),
              waveformColor.withOpacity(0.1),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Draw main waveform
    final Paint waveformPaint =
        Paint()
          ..color = waveformColor
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(waveformPath, waveformPaint);

    // Draw glow effect when detecting
    if (isDetecting) {
      final Paint glowPaint =
          Paint()
            ..color = waveformColor.withOpacity(0.3 * glowIntensity)
            ..strokeWidth = 4.0
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
      canvas.drawPath(waveformPath, glowPaint);
    }

    // Draw intensity indicators for drone detection
    if (isDroneDetected && confidence > 0.5) {
      _drawIntensityIndicators(canvas, size, points);
    }
  }

  void _drawIntensityIndicators(Canvas canvas, Size size, List<Offset> points) {
    final Paint indicatorPaint =
        Paint()
          ..color = Colors.red.withOpacity(0.6)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    // Draw warning indicators at peak points
    for (int i = 0; i < points.length; i += 10) {
      if (i < points.length) {
        double amplitude = (points[i].dy - size.height / 2).abs();
        if (amplitude > size.height * 0.2) {
          canvas.drawCircle(points[i], 3.0, indicatorPaint);
        }
      }
    }
  }

  List<double> _downsampleAudio(List<double> samples, int targetLength) {
    if (samples.length <= targetLength) return samples;

    List<double> downsampled = [];
    double ratio = samples.length / targetLength;

    for (int i = 0; i < targetLength; i++) {
      int startIndex = (i * ratio).floor();
      int endIndex = math.min(((i + 1) * ratio).floor(), samples.length);

      // Use RMS for better representation
      double sum = 0;
      for (int j = startIndex; j < endIndex; j++) {
        sum += samples[j] * samples[j];
      }
      double rms = math.sqrt(sum / (endIndex - startIndex));

      // Preserve sign
      double sign = samples[startIndex] >= 0 ? 1 : -1;
      downsampled.add(rms * sign);
    }

    return downsampled;
  }

  @override
  bool shouldRepaint(covariant _EnhancedWaveformPainter oldDelegate) {
    return oldDelegate.samples != samples ||
        oldDelegate.waveformColor != waveformColor ||
        oldDelegate.isDetecting != isDetecting ||
        oldDelegate.isDroneDetected != isDroneDetected ||
        oldDelegate.confidence != confidence ||
        oldDelegate.glowIntensity != glowIntensity;
  }
}
