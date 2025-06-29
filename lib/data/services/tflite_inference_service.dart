// lib/data/services/tflite_inference_service.dart

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';

import '../../core/app_constants.dart';
import '../models/drone_detection_result.dart';
// Change 1: Import the repository instead of using the interpreter directly
import '../repositories/tflite_model_repository.dart';

// This helper class for passing parameters to the isolate remains unchanged.
// class _InferenceParams {
//   final Uint8List audioFeaturesBytes;
//   final List<int> inputShape;
//   final List<int> outputShape;
//   final TensorType outputType;
//   final double threshold;

//   _InferenceParams({
//     required this.audioFeaturesBytes,
//     required this.inputShape,
//     required this.outputShape,
//     required this.outputType,
//     required this.threshold,
//   });
// }

/// Service responsible for running TensorFlow Lite inference on audio features.
class TfliteInferenceService {
  // Change 2: The service now holds a reference to the repository.
  final TfliteModelRepository _modelRepository;

  // Change 3: The constructor now accepts TfliteModelRepository.
  TfliteInferenceService(this._modelRepository);

  /// Runs inference on the provided audio features in a separate isolate.
  Future<DroneDetectionResult> runInference(
    Float32List audioFeatures, {
    double? threshold,
  }) async {
    // Add a guard clause to ensure the model is loaded before proceeding.
    if (!_modelRepository.isLoaded) {
      print("TfliteInferenceService: Model not loaded. Skipping inference.");
      return DroneDetectionResult(
        isDroneDetected: false,
        confidence: 0.0,
        message: 'Model not loaded',
      );
    }

    // Validate input features
    if (audioFeatures.isEmpty) {
      print("TfliteInferenceService: Empty audio features provided.");
      return DroneDetectionResult(
        isDroneDetected: false,
        confidence: 0.0,
        message: 'No audio data',
      );
    }

    // Expected input size: 43 * 232 = 9976
    const int expectedSize = 43 * 232;
    if (audioFeatures.length != expectedSize) {
      print(
        "TfliteInferenceService: Invalid feature size. Expected: $expectedSize, Got: ${audioFeatures.length}",
      );
      return DroneDetectionResult(
        isDroneDetected: false,
        confidence: 0.0,
        message: 'Invalid feature size',
      );
    }

    try {
      // Convert to 4D List<double>: [1, 43, 232, 1]
      // The model expects input shape [1, 43, 232, 1]
      final input = List.generate(1, (_) {
        return List.generate(43, (i) {
          return List.generate(232, (j) {
            final index = i * 232 + j;
            return [audioFeatures[index].toDouble()];
          });
        });
      });

      // Output shape [1, 2] - [no_drone_probability, drone_probability]
      final output = [List.filled(2, 0.0)];

      _modelRepository.runInference(input, output);

      // Implement web version's processAudioPrediction logic
      List<double> scores = output[0]; // [backgroundNoise, fpvDrone]

      // Store the current scores (like web version's lastPredictionScores)
      print(
        'Prediction scores: ${scores.map((s) => s.toStringAsFixed(4)).toList()}',
      );

      // Find the highest scoring label (like web version)
      double maxValue = scores.reduce((a, b) => a > b ? a : b);
      int maxIndex = scores.indexOf(maxValue);

      // Web version labels: ["Background Noise", "FPV Drone"]
      List<String> labels = ["Background Noise", "FPV Drone"];

      // FPV Drone is at index 1 (like web version)
      const int fpvDroneIndex = 1;
      // Use dynamic threshold if provided, otherwise fall back to default
      double confidenceThreshold =
          threshold ?? AppConstants.droneDetectionThreshold;

      bool isDroneDetected = false;

      // Use web version's detection logic:
      // Only consider it a detection if confidence is above threshold
      // and it's the FPV Drone class (index 1)
      if ((maxIndex == fpvDroneIndex &&
          scores[fpvDroneIndex] > confidenceThreshold)) {
        isDroneDetected = true;
        print(
          'Detection triggered: ${labels[maxIndex]} (${maxValue.toStringAsFixed(2)}) > threshold (${confidenceThreshold.toStringAsFixed(2)})',
        );
      }

      // Create message based on detection (like web version's updateUI)
      String message;
      if (isDroneDetected) {
        message =
            'Drone Detected! ${labels[maxIndex]} (${(maxValue * 100).toStringAsFixed(1)}%)';
      } else {
        message =
            'Listening... ${labels[maxIndex]} (${(maxValue * 100).toStringAsFixed(1)}%)';
      }

      return DroneDetectionResult(
        isDroneDetected: isDroneDetected,
        confidence: maxValue, // Use the max confidence like web version
        message: message,
        predictionScores: scores, // Include raw prediction scores
      );
    } catch (e) {
      print('Error during TFLite inference: $e');
      return DroneDetectionResult(
        isDroneDetected: false,
        confidence: 0.0,
        message:
            'Inference Error: ${e.toString().length > 30 ? "${e.toString().substring(0, 30)}..." : e.toString()}',
      );
    }
  }

  /// This static function runs in a separate Isolate.
  /// IT DOES NOT NEED ANY CHANGES, as it is self-contained.
  // static Future<DroneDetectionResult> _performInferenceInBackground(
  //   _InferenceParams params,
  // ) async {
  //   // This logic correctly reloads the model in the background isolate.
  //   Interpreter backgroundInterpreter;
  //   try {
  //     backgroundInterpreter = await Interpreter.fromAsset(
  //       AppConstants.tfliteModelPath,
  //     );
  //   } catch (_) {
  //     final ByteData data = await rootBundle.load(AppConstants.tfliteModelPath);
  //     final buffer = data.buffer.asUint8List();
  //     backgroundInterpreter = await Interpreter.fromBuffer(buffer);
  //   }

  //   final Float32List inputBuffer =
  //       params.audioFeaturesBytes.buffer.asFloat32List();
  //   final input = [inputBuffer.toList()];

  //   final outputBuffer = List.generate(
  //     params.outputShape[0],
  //     (_) => List<double>.filled(params.outputShape[1], 0.0),
  //   );

  //   try {
  //     backgroundInterpreter.run(input, outputBuffer);

  //     print("Output from background inference: $outputBuffer");

  //     final double droneProbability = outputBuffer[0][1];
  //     bool isDroneDetected = droneProbability > params.threshold;

  //     backgroundInterpreter.close();

  //     return DroneDetectionResult(
  //       isDroneDetected: isDroneDetected,
  //       confidence: droneProbability,
  //       message: isDroneDetected ? 'Drone Detected!' : 'No Drone Sound',
  //     );
  //   } catch (e) {
  //     print('Error during TFLite inference in isolate: $e');
  //     backgroundInterpreter.close();
  //     return DroneDetectionResult(
  //       isDroneDetected: false,
  //       confidence: 0.0,
  //       message: 'Inference Error',
  //     );
  //   }
  // }
}
