import 'dart:async';
import 'package:flutter/foundation.dart'; // For compute in isolate for FFT
import 'package:flutter/material.dart';
import '../../core/app_constants.dart';
import '../../core/utils/enhanced_audio_utils.dart';
import '../../core/utils/detection_state_manager.dart';
import '../../core/services/drone_warning_service.dart';
import '../../data/models/drone_detection_result.dart';
import '../../domain/usecases/detect_drone_usecase.dart';

/// ViewModel for the HomeScreen, managing UI state and logic.
class HomeViewModel extends ChangeNotifier {
  final DetectDroneUsecase _detectDroneUsecase;
  final DroneWarningService _droneWarningService;
  final DetectionStateManager _detectionStateManager = DetectionStateManager();

  bool _isDetecting = false;
  String _detectionMessage = 'Press Start to listen';
  bool _isDroneDetected = false;
  bool _previousDroneDetected =
      false; // Track previous state to detect new detections
  double _detectionConfidence = 0.0;
  List<double> _audioFrequencies = []; // Data for frequency visualization
  List<double> _samples = []; // Data for waveform visualization
  bool _isLoading = false;
  List<double> _predictionScores = [0.0, 0.0]; // [backgroundNoise, fpvDrone]
  BuildContext? _currentContext; // Store context for showing warning modal

  StreamSubscription<DroneDetectionResult>? _detectionSubscription;
  StreamSubscription<Uint8List>? _audioStreamForFftSubscription;

  // Constructor with dependency injection
  HomeViewModel(this._detectDroneUsecase, this._droneWarningService) {
    // Set up detection state manager callback
    _detectionStateManager.setStateChangeCallback((
      isDroneDetected,
      confidence,
      message,
    ) {
      // Check if this is a new drone detection (transition from false to true)
      if (isDroneDetected &&
          !_previousDroneDetected &&
          _currentContext != null) {
        // Trigger warning modal with sound
        _droneWarningService.showDroneWarning(_currentContext!);
      }

      // Update previous state for next comparison
      _previousDroneDetected = _isDroneDetected;

      _isDroneDetected = isDroneDetected;
      _detectionConfidence = confidence;
      _detectionMessage = message;

      // Don't call notifyListeners() here - we'll do it in the audio stream
      // to ensure perfect synchronization with waveform updates
    });
  }

  // Getters for UI to observe
  bool get isDetecting => _isDetecting;
  String get detectionMessage => _detectionMessage;
  bool get isDroneDetected => _isDroneDetected;
  double get detectionConfidence => _detectionConfidence;
  List<double> get audioFrequencies => _audioFrequencies;
  List<double> get samples => _samples;
  bool get isLoading => _isLoading;
  List<double> get predictionScores => _predictionScores;

  /// Initializes the ViewModel.
  void initialize() {
    // You might start listening to audio stream for FFT here if it's separate from ML.
    // For now, it's integrated with toggleDetection.
  }

  /// Set the current context for showing warning modals
  void setContext(BuildContext context) {
    _currentContext = context;
  }

  /// Updates the detection threshold used for determining drone detection
  void updateDetectionThreshold(double threshold) {
    // Update the detection state manager with the new threshold
    _detectionStateManager.updateThreshold(threshold);
    // Update the usecase with the new threshold
    _detectDroneUsecase.updateDetectionThreshold(threshold);
  }

  /// Toggles the drone detection process (Start/Pause).
  Future<void> toggleDetection() async {
    // Prevent multiple simultaneous toggle attempts
    if (_isLoading) return;

    if (_isDetecting) {
      // If currently detecting, stop it
      _isLoading = true;
      notifyListeners();

      try {
        await _detectDroneUsecase.stopDetection();
        await _audioStreamForFftSubscription?.cancel();
        _audioStreamForFftSubscription = null;

        // Clear audio processing history for clean restart
        EnhancedAudioUtils.clearHistory();

        // Reset detection state manager
        _detectionStateManager.reset();

        _isDetecting = false;
        _detectionMessage = 'Detection Paused';
        _isDroneDetected = false;
        _previousDroneDetected = false; // Reset previous state
        _detectionConfidence = 0.0;
        _audioFrequencies = [];
        _samples = [];
      } catch (e) {
        _detectionMessage = 'Error stopping detection: $e';
        print('Error stopping detection: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      // Starting detection
      _isLoading = true;
      _detectionMessage = 'Initializing...';
      _isDroneDetected = false;
      _detectionConfidence = 0.0;
      _audioFrequencies = [];
      _samples = [];
      notifyListeners();

      try {
        // Start the detection stream
        _detectionSubscription = _detectDroneUsecase.startDetection().listen(
          (result) {
            // Process through detection state manager for smoothing and persistence
            _detectionStateManager.processPrediction(
              result.isDroneDetected,
              result.confidence,
            );

            // Update prediction scores from the model
            if (result.predictionScores != null && _isDetecting) {
              _predictionScores = result.predictionScores!;
            }

            // Update waveform data from the same source as detection
            if (result.audioSamples != null && _isDetecting) {
              _samples = result.audioSamples!;

              // Compute FFT for frequency visualization
              _computeFrequenciesFromSamples(result.audioSamples!);
            }

            // Single synchronized UI update for both detection state and waveform
            if (_isDetecting) {
              notifyListeners();
            }
          },
          onError: (e) {
            _detectionMessage = 'Detection Error: $e';
            _isDroneDetected = false;
            _detectionConfidence = 0.0;
            _isDetecting = false;
            _isLoading = false;
            notifyListeners();
            print('Detection stream error: $e');
          },
          onDone: () {
            _isDetecting = false;
            _detectionMessage = 'Detection Finished';
            _isDroneDetected = false;
            _detectionConfidence = 0.0;
            _isLoading = false;
            notifyListeners();
          },
        );

        _isDetecting = true;
        _detectionMessage = 'Listening for drones...';
      } catch (e) {
        _detectionMessage = 'Failed to start detection: $e';
        _isDroneDetected = false;
        _detectionConfidence = 0.0;
        _isDetecting = false;
        print('Error starting detection: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Computes frequency data from audio samples for visualization (low-latency)
  void _computeFrequenciesFromSamples(List<double> audioSamples) {
    try {
      // Use low-latency FFT for faster processing
      _audioFrequencies = EnhancedAudioUtils.performLowLatencyFft(
        audioSamples,
        AppConstants.audioSampleRate,
      );
    } catch (e) {
      print('Error computing frequencies: $e');
      _audioFrequencies = [];
    }
  }

  /// Disposes of resources when the ViewModel is no longer needed.
  @override
  void dispose() {
    _detectionSubscription?.cancel();
    _audioStreamForFftSubscription?.cancel();
    _detectDroneUsecase.stopDetection();
    _detectionStateManager.dispose();
    super.dispose();
  }
}
