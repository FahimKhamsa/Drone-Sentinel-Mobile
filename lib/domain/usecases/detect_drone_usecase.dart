// lib/domain/usecases/detect_drone_usecase.dart

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // For compute in TfliteInferenceService

import '../../core/app_constants.dart';
import '../../core/utils/enhanced_audio_utils.dart';
import '../../data/models/drone_detection_result.dart';
import '../../data/services/audio_capture_service.dart';
import '../../data/services/tflite_inference_service.dart';
import '../feature_extraction/browser_fft_extractor.dart'; // Import corrected feature extractor

/// Use case for detecting drones from audio input.
/// Orchestrates audio capture, feature extraction, and TFLite inference.
class DetectDroneUsecase {
  final AudioCaptureService _audioCaptureService;
  final TfliteInferenceService _tfliteInferenceService;
  final AudioFeatureExtractor
  _audioFeatureExtractor; // Instance of your feature extractor

  StreamSubscription<Uint8List>? _audioSubscription;
  StreamController<DroneDetectionResult>? _detectionResultController;

  DetectDroneUsecase(
    this._audioCaptureService,
    this._tfliteInferenceService, {
    AudioFeatureExtractor?
    audioFeatureExtractor, // Optional: dependency injection for extractor
  }) : _audioFeatureExtractor =
           audioFeatureExtractor ??
           BrowserFFTExtractor(); // Use corrected Browser FFT extractor

  /// Starts the drone detection process.
  /// Captures audio, processes it, runs inference, and streams detection results.
  /// Returns a [Stream<DroneDetectionResult>] of real-time detection outcomes.
  Stream<DroneDetectionResult> startDetection() {
    _detectionResultController = StreamController<DroneDetectionResult>();

    // Initialize audio recorder and start capture asynchronously
    _initializeAndStartCapture();

    print('Drone detection started.');
    return _detectionResultController!.stream;
  }

  /// Private method to handle async initialization and audio capture setup
  Future<void> _initializeAndStartCapture() async {
    try {
      // Clean up any existing resources first
      await _cleanupResources();

      // Initialize the recorder
      await _audioCaptureService.initRecorder();

      // Start capturing audio
      final audioStream = await _audioCaptureService.startCapture();

      // Subscribe to the stream and process incoming audio
      _audioSubscription = audioStream.listen(
        (audioBytes) async {
          // Skip processing if controller is closed
          if (_detectionResultController == null ||
              _detectionResultController!.isClosed) {
            return;
          }

          try {
            // 1. Convert raw audio bytes to normalized double samples
            final List<double> rawAudioData =
                EnhancedAudioUtils.convertBytesToDoubles(audioBytes);

            // Skip if audio data is empty or too small
            if (rawAudioData.isEmpty ||
                rawAudioData.length <
                    EnhancedAudioUtils.getOptimalChunkSize()) {
              return;
            }

            // 2. Apply noise reduction for better ML accuracy
            final List<double> cleanAudioData =
                EnhancedAudioUtils.processAudioWithNoiseReduction(rawAudioData);

            // 3. Extract features using corrected Browser FFT (Log-Magnitude Frequency Spectrogram) from the clean audio data
            final Float32List features = _audioFeatureExtractor.extractFeatures(
              cleanAudioData,
              AppConstants.audioSampleRate,
            );

            // 3. Run the inference using the TFLite model
            final DroneDetectionResult result = await _tfliteInferenceService
                .runInference(features);

            // 4. Create enhanced result with audio data for synchronized visualization
            final DroneDetectionResult enhancedResult = DroneDetectionResult(
              isDroneDetected: result.isDroneDetected,
              confidence: result.confidence,
              message: result.message,
              audioSamples: cleanAudioData, // Add audio data for waveform
            );

            // 5. Push the enhanced detection result to the stream
            if (_detectionResultController != null &&
                !_detectionResultController!.isClosed) {
              _detectionResultController!.add(enhancedResult);
            }
          } catch (e) {
            print('Error in detection pipeline: $e');
            if (_detectionResultController != null &&
                !_detectionResultController!.isClosed) {
              _detectionResultController!.add(
                DroneDetectionResult(
                  isDroneDetected: false,
                  confidence: 0.0,
                  message:
                      'Processing Error: ${e.toString().length > 50 ? "${e.toString().substring(0, 50)}..." : e.toString()}',
                ),
              );
            }
          }
        },
        onError: (e) {
          print('Audio stream error: $e');
          if (_detectionResultController != null &&
              !_detectionResultController!.isClosed) {
            _detectionResultController!.add(
              DroneDetectionResult(
                isDroneDetected: false,
                confidence: 0.0,
                message:
                    'Audio Stream Error: ${e.toString().length > 50 ? e.toString().substring(0, 50) + "..." : e.toString()}',
              ),
            );
          }
        },
        onDone: () {
          print('Audio stream completed.');
          if (_detectionResultController != null &&
              !_detectionResultController!.isClosed) {
            _detectionResultController!.close();
          }
        },
      );
    } catch (e) {
      print('Error initializing audio capture: $e');
      if (_detectionResultController != null &&
          !_detectionResultController!.isClosed) {
        _detectionResultController!.add(
          DroneDetectionResult(
            isDroneDetected: false,
            confidence: 0.0,
            message:
                'Initialization Error: ${e.toString().length > 50 ? "${e.toString().substring(0, 50)}..." : e.toString()}',
          ),
        );
      }
    }
  }

  /// Helper method to clean up resources
  Future<void> _cleanupResources() async {
    try {
      await _audioSubscription?.cancel();
      _audioSubscription = null;
      await _audioCaptureService.stopCapture();
      // Give extra time for cleanup
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      print('Error during cleanup: $e');
    }
  }

  /// Stops the drone detection process and cleans up resources.
  Future<void> stopDetection() async {
    await _audioSubscription?.cancel();
    _audioSubscription = null;
    await _audioCaptureService.stopCapture();
    await _audioCaptureService.disposeRecorder();
    if (_detectionResultController != null &&
        !_detectionResultController!.isClosed) {
      await _detectionResultController!.close();
    }
    _detectionResultController = null;
    print('Drone detection stopped.');
  }

  /// Exposes the audio capture service for other parts of the app (e.g., for FFT visualization).
  AudioCaptureService getAudioCaptureService() {
    return _audioCaptureService;
  }
}
