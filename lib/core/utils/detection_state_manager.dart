// lib/core/utils/detection_state_manager.dart

import 'dart:async';

import 'package:drone_detector/core/app_constants.dart';

/// Manages detection state with smoothing, persistence, and hysteresis
class DetectionStateManager {
  // Configuration parameters
  static const int _historySize = 5; // Number of recent predictions to keep
  static const double _detectionThreshold =
      AppConstants.droneDetectionThreshold; // Threshold to trigger detection
  static const double _clearThreshold =
      0.2; // Threshold to clear detection (hysteresis)
  static const Duration _minDetectionDuration = Duration(
    seconds: 1,
  ); // Minimum time to show detection
  static const Duration _maxDetectionDuration = Duration(
    seconds: 2,
  ); // Maximum time to show detection without new evidence

  // State variables
  final List<double> _confidenceHistory = [];
  bool _isCurrentlyDetected = false;
  DateTime? _lastDetectionTime;
  DateTime? _detectionStartTime;
  Timer? _detectionClearTimer;

  // Callbacks
  Function(bool isDroneDetected, double confidence, String message)?
  _onStateChanged;

  /// Sets the callback for state changes
  void setStateChangeCallback(
    Function(bool isDroneDetected, double confidence, String message) callback,
  ) {
    _onStateChanged = callback;
  }

  /// Processes a new prediction and updates the detection state
  void processPrediction(bool isDroneDetected, double confidence) {
    // Add to history
    _confidenceHistory.add(confidence);
    if (_confidenceHistory.length > _historySize) {
      _confidenceHistory.removeAt(0);
    }

    // Calculate smoothed confidence
    double smoothedConfidence = _calculateSmoothedConfidence();

    // Update detection state with hysteresis
    _updateDetectionState(smoothedConfidence);

    // Update last detection time if drone detected
    if (isDroneDetected && confidence > _detectionThreshold) {
      _lastDetectionTime = DateTime.now();
      if (_detectionStartTime == null) {
        _detectionStartTime = DateTime.now();
      }
    }

    // Determine display state
    bool shouldShowDetection = _shouldShowDetection();
    String message = _generateMessage(shouldShowDetection, smoothedConfidence);

    // Notify callback
    _onStateChanged?.call(shouldShowDetection, smoothedConfidence, message);
  }

  /// Calculates smoothed confidence from recent history
  double _calculateSmoothedConfidence() {
    if (_confidenceHistory.isEmpty) return 0.0;

    // Use weighted average with more recent predictions having higher weight
    double weightedSum = 0.0;
    double totalWeight = 0.0;

    for (int i = 0; i < _confidenceHistory.length; i++) {
      double weight = (i + 1).toDouble(); // More recent = higher weight
      weightedSum += _confidenceHistory[i] * weight;
      totalWeight += weight;
    }

    return weightedSum / totalWeight;
  }

  /// Updates the internal detection state using hysteresis
  void _updateDetectionState(double smoothedConfidence) {
    if (!_isCurrentlyDetected && smoothedConfidence > _detectionThreshold) {
      // Start detection
      _isCurrentlyDetected = true;
      _detectionStartTime = DateTime.now();
      _cancelClearTimer();
    } else if (_isCurrentlyDetected && smoothedConfidence < _clearThreshold) {
      // Consider clearing detection, but with delay
      _scheduleClearDetection();
    } else if (_isCurrentlyDetected &&
        smoothedConfidence > _detectionThreshold) {
      // Reinforce detection - cancel any pending clear
      _cancelClearTimer();
    }
  }

  /// Determines if detection should be shown to user
  bool _shouldShowDetection() {
    if (!_isCurrentlyDetected) return false;

    DateTime now = DateTime.now();

    // Always show for minimum duration
    if (_detectionStartTime != null) {
      Duration timeSinceStart = now.difference(_detectionStartTime!);
      if (timeSinceStart < _minDetectionDuration) {
        return true;
      }
    }

    // Show if we had recent detection evidence
    if (_lastDetectionTime != null) {
      Duration timeSinceLastDetection = now.difference(_lastDetectionTime!);
      if (timeSinceLastDetection < _maxDetectionDuration) {
        return true;
      }
    }

    return false;
  }

  /// Schedules clearing of detection state
  void _scheduleClearDetection() {
    _cancelClearTimer();

    // Only clear after minimum duration has passed
    DateTime now = DateTime.now();
    Duration remainingMinTime = Duration.zero;

    if (_detectionStartTime != null) {
      Duration timeSinceStart = now.difference(_detectionStartTime!);
      if (timeSinceStart < _minDetectionDuration) {
        remainingMinTime = _minDetectionDuration - timeSinceStart;
      }
    }

    _detectionClearTimer = Timer(
      remainingMinTime + Duration(milliseconds: 500),
      () {
        _clearDetection();
      },
    );
  }

  /// Cancels any pending clear timer
  void _cancelClearTimer() {
    _detectionClearTimer?.cancel();
    _detectionClearTimer = null;
  }

  /// Clears the detection state
  void _clearDetection() {
    _isCurrentlyDetected = false;
    _detectionStartTime = null;
    _lastDetectionTime = null;
    _cancelClearTimer();
  }

  /// Generates appropriate message for current state
  String _generateMessage(bool shouldShowDetection, double confidence) {
    if (shouldShowDetection) {
      return 'FPV Drone Detected!';
    } else {
      return 'Listening for drones...';
    }
  }

  /// Gets current detection statistics
  Map<String, dynamic> getDetectionStats() {
    DateTime now = DateTime.now();

    return {
      'isDetected': _shouldShowDetection(),
      'smoothedConfidence': _calculateSmoothedConfidence(),
      'detectionDuration':
          _detectionStartTime != null
              ? now.difference(_detectionStartTime!).inSeconds
              : 0,
      'timeSinceLastDetection':
          _lastDetectionTime != null
              ? now.difference(_lastDetectionTime!).inSeconds
              : null,
      'historySize': _confidenceHistory.length,
    };
  }

  /// Resets all detection state
  void reset() {
    _confidenceHistory.clear();
    _clearDetection();
  }

  /// Disposes resources
  void dispose() {
    _cancelClearTimer();
    reset();
  }
}
