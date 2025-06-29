// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Drone Detector';

  @override
  String get supportBanner => 'Work in progress, click here for support';

  @override
  String get droneSentinelTitle => 'Drone Sentinel';

  @override
  String get droneSentinelSubtitle => 'Advanced AI-Powered Drone Detection';

  @override
  String get startListening => 'Start Listening';

  @override
  String get stopListening => 'Stop Listening';

  @override
  String get loading => 'Loading...';

  @override
  String get aboutTitle => 'About Drone Sentinel';

  @override
  String get aboutDescription =>
      'Drone Sentinel uses advanced AI technology to detect drone sounds in real-time. Our machine learning model analyzes audio patterns to identify potential drone activity with high accuracy.';

  @override
  String get detectionDashboard => 'Detection Dashboard';

  @override
  String get detectionThreshold => 'Detection Threshold';

  @override
  String get droneDetected => 'DRONE DETECTED!';

  @override
  String get noDroneDetected => 'No Drone Detected';

  @override
  String get confidence => 'Confidence';

  @override
  String get audioWaveform => 'Audio Waveform';

  @override
  String get frequencyAnalysis => 'Frequency Analysis';

  @override
  String get predictionScores => 'Prediction Scores';

  @override
  String get errorTitle => 'Error';

  @override
  String get initializationError => 'Initialization Error';

  @override
  String get permissionDenied => 'Permission Denied';

  @override
  String get microphonePermissionRequired =>
      'Microphone permission is required to use this app.';

  @override
  String get modelLoadError =>
      'Failed to load TensorFlow Lite model. Please check the model path and file.';

  @override
  String get ok => 'OK';

  @override
  String get soundDetectionMeter => 'Sound Detection Meter';

  @override
  String get listeningForSounds => 'Listening for sounds...';

  @override
  String get listening => 'Listening...';

  @override
  String get systemStatus => 'System Status';

  @override
  String get monitoringFor => 'Monitoring For';

  @override
  String get backgroundNoiseFpvDrone => 'Background Noise, FPV Drone';

  @override
  String get microphone => 'Microphone';

  @override
  String get connected => 'Connected';

  @override
  String get model => 'Model';

  @override
  String get loaded => 'Loaded';

  @override
  String get detectionStatus => 'Detection Status';

  @override
  String get waitingForSounds => 'Waiting for sounds...';

  @override
  String get loadingSoundDetectionModel => 'Loading sound detection model...';

  @override
  String get moreDetections => 'More Detections';

  @override
  String get higherAccuracy => 'Higher Accuracy';

  @override
  String get backgroundNoise => 'Background Noise';

  @override
  String get fpvDrone => 'FPV Drone';
}
