// lib/core/app_constants.dart

/// Defines application-wide constants.
class AppConstants {
  // TensorFlow Lite Model Configuration
  static const String tfliteModelPath = 'assets/models/model.tflite';

  // Audio Recording Configuration
  static const int audioSampleRate =
      44100; // Hz - Match web version (16kHz for speech/audio models)
  static const int audioChannels = 1; // Mono audio
  // Buffer size in samples. This determines how often audio data is processed.
  // Smaller values mean more real-time, but higher CPU usage.
  // Larger values mean more latency, but less CPU usage.
  // This value should be carefully chosen based on your model's expected input chunk size
  // and real-time performance requirements. For example, if your model processes 1-second chunks,
  // this buffer size should correspond to that (sampleRate * 1 second).
  static const int audioBufferSize =
      44100; // Example: 1 second of audio at 16kHz (match web version)

  // Drone Detection Threshold
  // The probability threshold above which a sound is classified as a drone.
  // This value should be tuned based on your model's performance and desired sensitivity.
  // Increased to 0.92 to reduce false positives - only very confident detections
  static const double droneDetectionThreshold = 0.8;
}
