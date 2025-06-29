// lib/data/services/audio_capture_service.dart

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import '../../core/app_constants.dart';

class AudioCaptureService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  StreamController<Uint8List>? _audioStreamController;
  bool _isInitialized = false;
  bool _isInitializing = false;

  Future<void> initRecorder() async {
    if (_isInitialized) {
      print('Recorder already open.');
      return;
    }

    if (_isInitializing) {
      // Wait for ongoing initialization to complete
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }

    _isInitializing = true;
    try {
      await _recorder.openRecorder();
      _isInitialized = true;
      print('Recorder opened.');
    } catch (e) {
      print('Error opening recorder: $e');
      _isInitialized = false;
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  Future<Stream<Uint8List>> startCapture() async {
    // First, ensure any previous recording is completely stopped
    await stopCapture();

    // Ensure recorder is initialized
    if (!_isInitialized) {
      print('Recorder not initialized. Attempting to initialize...');
      await initRecorder();
    }

    // Double-check recorder state
    if (_recorder.isRecording) {
      print('Recorder still recording after stop. Force stopping...');
      try {
        await _recorder.stopRecorder();
        // Wait a bit for the recorder to fully stop
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        print('Error force stopping recorder: $e');
      }
    }

    // Create new stream controller
    _audioStreamController = StreamController<Uint8List>.broadcast();

    try {
      await _recorder.startRecorder(
        toStream: _audioStreamController!.sink,
        codec: Codec.pcm16,
        numChannels: AppConstants.audioChannels,
        sampleRate: AppConstants.audioSampleRate,
      );

      print('Recorder started successfully.');
      return _audioStreamController!.stream;
    } catch (e) {
      print('Error starting recorder: $e');
      if (_audioStreamController != null && !_audioStreamController!.isClosed) {
        await _audioStreamController!.close();
        _audioStreamController = null;
      }
      rethrow;
    }
  }

  Future<void> stopCapture() async {
    try {
      if (_recorder.isRecording) {
        await _recorder.stopRecorder();
        print('Recorder stopped.');
        // Give the recorder time to fully stop
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      print('Error stopping recorder: $e');
      // Continue with cleanup even if stop failed
    }

    try {
      if (_audioStreamController != null && !_audioStreamController!.isClosed) {
        await _audioStreamController!.close();
        _audioStreamController = null;
        print('Audio stream controller closed.');
      }
    } catch (e) {
      print('Error closing stream controller: $e');
      _audioStreamController = null; // Force null even if close failed
    }
  }

  Future<void> disposeRecorder() async {
    await stopCapture();

    if (_isInitialized) {
      await _recorder.closeRecorder();
      _isInitialized = false;
      print('Recorder closed.');
    } else {
      print('Recorder was not open.');
    }
  }

  bool get isRecording => _recorder.isRecording;
  bool get isOpen => _recorder.isRecording || _recorder.isPaused;
}
