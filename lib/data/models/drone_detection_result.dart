// lib/data/models/drone_detection_result.dart

/// Represents the result of a drone detection inference.
class DroneDetectionResult {
  /// True if a drone sound is detected, false otherwise.
  final bool isDroneDetected;

  /// The confidence score (probability) of the detection, usually between 0.0 and 1.0.
  final double confidence;

  /// A human-readable message describing the detection.
  final String message;

  /// Optional audio samples for synchronized waveform visualization
  final List<double>? audioSamples;

  /// Raw prediction scores from the model [backgroundNoise, fpvDrone]
  final List<double>? predictionScores;

  DroneDetectionResult({
    required this.isDroneDetected,
    required this.confidence,
    required this.message,
    this.audioSamples,
    this.predictionScores,
  });

  @override
  String toString() {
    return 'DroneDetectionResult(isDroneDetected: $isDroneDetected, confidence: ${confidence.toStringAsFixed(2)}, message: "$message")';
  }
}
