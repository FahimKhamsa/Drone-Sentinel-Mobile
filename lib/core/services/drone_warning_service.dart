import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import 'language_service.dart';

class DroneWarningService extends ChangeNotifier {
  static final DroneWarningService _instance = DroneWarningService._internal();
  factory DroneWarningService() => _instance;
  DroneWarningService._internal();

  FlutterSoundPlayer? _soundPlayer;
  bool _isModalVisible = false;
  bool _isPlaying = false;
  Timer? _soundTimer;
  BuildContext? _currentContext;

  // Cached audio buffers
  Uint8List? _englishAlarm;
  Uint8List? _otherAlarm;
  Uint8List? _activeAlarmBuffer;

  bool get isModalVisible => _isModalVisible;
  bool get isPlaying => _isPlaying;

  /// Initialize the sound player and load audio buffers
  Future<void> initialize() async {
    try {
      _soundPlayer = FlutterSoundPlayer();
      await _soundPlayer!.openPlayer();

      _englishAlarm = await _loadAssetToBuffer('assets/audio/alarm-en.mp3');
      _otherAlarm = await _loadAssetToBuffer('assets/audio/alarm-uk.mp3');

      print('DroneWarningService initialized');
    } catch (e) {
      print('Error initializing sound player: $e');
    }
  }

  /// Load an asset into memory as a buffer
  Future<Uint8List> _loadAssetToBuffer(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    return byteData.buffer.asUint8List();
  }

  /// Show modal and start alert sound concurrently
  Future<void> showDroneWarning(BuildContext context) async {
    if (_isModalVisible) return;

    _isModalVisible = true;
    _currentContext = context;
    notifyListeners();

    // Play alert in background
    _startWarningAlerts(context); // fire-and-forget (no await)

    // Show modal immediately
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (BuildContext dialogContext) => _buildWarningDialog(dialogContext),
      ).then((_) {
        _closeWarning();
      });
    }
  }

  Widget _buildWarningDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.red, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              localizations.droneDetectionWarning,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber, color: Colors.orange, size: 64),
          const SizedBox(height: 16),
          Text(
            localizations.droneDetectedWarningMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(localizations.close),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  /// Start alert sound and haptic loop
  Future<void> _startWarningAlerts(BuildContext context) async {
    if (_isPlaying || _soundPlayer == null) return;

    try {
      _isPlaying = true;
      notifyListeners();

      final languageService = Provider.of<LanguageService>(
        context,
        listen: false,
      );
      _activeAlarmBuffer =
          languageService.isEnglish ? _englishAlarm : _otherAlarm;

      if (_activeAlarmBuffer == null) {
        print('Alarm buffer is null. Sound cannot play.');
        return;
      }

      // Play initial sound once
      try {
        await _soundPlayer!.startPlayer(
          fromDataBuffer: _activeAlarmBuffer!,
          codec: Codec.mp3,
        );
        await HapticFeedback.heavyImpact();
      } catch (e) {
        print('Error playing initial sound: $e');
        await _fallbackHaptics();
      }

      // Loop playback every 2 seconds
      _soundTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        if (!_isModalVisible) {
          timer.cancel();
          return;
        }

        try {
          if (_soundPlayer!.isPlaying) {
            await _soundPlayer!.stopPlayer();
            await Future.delayed(const Duration(milliseconds: 100));
          }

          await _soundPlayer!.startPlayer(
            fromDataBuffer: _activeAlarmBuffer!,
            codec: Codec.mp3,
          );

          await HapticFeedback.heavyImpact();
        } catch (e) {
          print('Error during looped playback: $e');
          await _fallbackHaptics();
        }
      });
    } catch (e) {
      print('Failed to start warning alerts: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> _fallbackHaptics() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      print('Fallback haptics failed: $e');
    }
  }

  /// Stop sound and cleanup
  void _closeWarning() {
    _isModalVisible = false;
    _isPlaying = false;
    _currentContext = null;

    _soundTimer?.cancel();
    _soundTimer = null;

    if (_soundPlayer?.isPlaying == true) {
      _soundPlayer!.closePlayer().catchError((e) {
        print('Error stopping player: $e');
      });
      initialize(); // Reinitialize to reset player state
    }

    notifyListeners();
  }

  /// External close (e.g. button)
  void forceCloseWarning() {
    if (_isModalVisible && _currentContext != null) {
      Navigator.of(_currentContext!).pop();
    }
    _closeWarning();
  }

  @override
  void dispose() {
    _closeWarning();
    _soundPlayer?.closePlayer().catchError((e) {
      print('Error closing player: $e');
    });
    _soundPlayer = null;
    super.dispose();
  }
}
