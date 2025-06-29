// lib/core/utils/enhanced_audio_utils.dart

import 'dart:typed_data';
import 'dart:math' as math;

/// Enhanced audio utilities with noise reduction and smooth processing
class EnhancedAudioUtils {
  // Noise reduction parameters - More aggressive to reduce false positives
  static const double _noiseGateThreshold =
      0.05; // Increased threshold - more audio considered noise
  static const double _noiseReductionFactor =
      0.75; // Increased noise reduction - more aggressive filtering
  static const int _smoothingWindowSize = 7; // Larger window for more smoothing

  // High-pass filter parameters (removes low-frequency noise)
  static const double _highPassCutoff =
      200.0; // Hz - Higher cutoff to remove more low-frequency noise

  // Circular buffer for smoothing - increased history for better filtering
  static final List<List<double>> _audioHistory = [];
  static const int _maxHistorySize = 5; // More history for temporal consistency

  /// Converts bytes to doubles with enhanced processing
  static List<double> convertBytesToDoubles(Uint8List bytes) {
    final ByteData byteData = bytes.buffer.asByteData();
    final List<double> audioData = [];

    // Convert 16-bit PCM to doubles
    for (int i = 0; i < byteData.lengthInBytes; i += 2) {
      final int sample = byteData.getInt16(i, Endian.little);
      audioData.add(sample / 32768.0);
    }

    return audioData;
  }

  /// Low-latency audio processing with minimal noise reduction
  static List<double> processAudioWithNoiseReduction(List<double> rawAudio) {
    if (rawAudio.isEmpty) return rawAudio;

    // Single-pass lightweight processing for minimal latency
    return _applyLightweightProcessing(rawAudio);
  }

  /// Lightweight single-pass audio processing for low latency
  static List<double> _applyLightweightProcessing(List<double> audio) {
    if (audio.length < 2) return audio;

    List<double> processed = List.filled(audio.length, 0.0);

    // Simple high-pass filter combined with noise gate in single pass
    const double sampleRate = 44100.0;
    final double rc = 1.0 / (2.0 * math.pi * _highPassCutoff);
    final double dt = 1.0 / sampleRate;
    final double alpha = rc / (rc + dt);

    processed[0] = audio[0];

    for (int i = 1; i < audio.length; i++) {
      // High-pass filter
      double filtered = alpha * (processed[i - 1] + audio[i] - audio[i - 1]);

      // Noise gate
      double amplitude = filtered.abs();
      if (amplitude < _noiseGateThreshold) {
        filtered *=
            (1.0 -
                _noiseReductionFactor *
                    0.5); // Reduced noise reduction for speed
      }

      processed[i] = filtered;
    }

    // Quick normalization check
    double maxAmplitude = processed.map((s) => s.abs()).reduce(math.max);
    if (maxAmplitude > 0.95) {
      double scaleFactor = 0.95 / maxAmplitude;
      for (int i = 0; i < processed.length; i++) {
        processed[i] *= scaleFactor;
      }
    }

    return processed;
  }

  /// Enhanced audio processing with full noise reduction (for non-latency critical use)
  static List<double> processAudioWithFullNoiseReduction(
    List<double> rawAudio,
  ) {
    if (rawAudio.isEmpty) return rawAudio;

    // Step 1: Apply high-pass filter to remove low-frequency noise
    List<double> filtered = _applyHighPassFilter(rawAudio);

    // Step 2: Apply noise gate
    List<double> gated = _applyNoiseGate(filtered);

    // Step 3: Apply spectral noise reduction
    List<double> denoised = _applySpectralNoiseReduction(gated);

    // Step 4: Apply temporal smoothing
    List<double> smoothed = _applyTemporalSmoothing(denoised);

    // Step 5: Normalize to prevent clipping
    List<double> normalized = _normalizeAudio(smoothed);

    return normalized;
  }

  /// High-pass filter to remove low-frequency noise
  static List<double> _applyHighPassFilter(List<double> audio) {
    if (audio.length < 2) return audio;

    // Simple high-pass filter (first-order)
    const double sampleRate = 44100.0;
    final double rc = 1.0 / (2.0 * math.pi * _highPassCutoff);
    final double dt = 1.0 / sampleRate;
    final double alpha = rc / (rc + dt);

    List<double> filtered = List.filled(audio.length, 0.0);
    filtered[0] = audio[0];

    for (int i = 1; i < audio.length; i++) {
      filtered[i] = alpha * (filtered[i - 1] + audio[i] - audio[i - 1]);
    }

    return filtered;
  }

  /// Noise gate - reduces audio below threshold
  static List<double> _applyNoiseGate(List<double> audio) {
    return audio.map((sample) {
      double amplitude = sample.abs();
      if (amplitude < _noiseGateThreshold) {
        return sample * (1.0 - _noiseReductionFactor);
      }
      return sample;
    }).toList();
  }

  /// Spectral noise reduction using moving average
  static List<double> _applySpectralNoiseReduction(List<double> audio) {
    if (audio.length < _smoothingWindowSize) return audio;

    List<double> denoised = List.filled(audio.length, 0.0);

    for (int i = 0; i < audio.length; i++) {
      double sum = 0.0;
      int count = 0;

      int start = math.max(0, i - _smoothingWindowSize ~/ 2);
      int end = math.min(audio.length, i + _smoothingWindowSize ~/ 2 + 1);

      for (int j = start; j < end; j++) {
        sum += audio[j];
        count++;
      }

      double average = sum / count;
      double difference = audio[i] - average;

      // Reduce noise while preserving signal
      if (difference.abs() < _noiseGateThreshold) {
        denoised[i] = average + difference * (1.0 - _noiseReductionFactor);
      } else {
        denoised[i] = audio[i];
      }
    }

    return denoised;
  }

  /// Temporal smoothing across frames
  static List<double> _applyTemporalSmoothing(List<double> audio) {
    // Add current audio to history
    _audioHistory.add(List.from(audio));

    // Keep only recent history
    if (_audioHistory.length > _maxHistorySize) {
      _audioHistory.removeAt(0);
    }

    // If we don't have enough history, return current audio
    if (_audioHistory.length < 2) return audio;

    // Apply temporal smoothing
    List<double> smoothed = List.filled(audio.length, 0.0);

    for (int i = 0; i < audio.length; i++) {
      double sum = 0.0;
      double weightSum = 0.0;

      for (int j = 0; j < _audioHistory.length; j++) {
        if (i < _audioHistory[j].length) {
          double weight =
              (j + 1).toDouble(); // More recent frames have higher weight
          sum += _audioHistory[j][i] * weight;
          weightSum += weight;
        }
      }

      smoothed[i] = weightSum > 0 ? sum / weightSum : 0.0;
    }

    return smoothed;
  }

  /// Normalize audio to prevent clipping
  static List<double> _normalizeAudio(List<double> audio) {
    if (audio.isEmpty) return audio;

    double maxAmplitude = audio.map((s) => s.abs()).reduce(math.max);

    if (maxAmplitude > 0.95) {
      double scaleFactor = 0.95 / maxAmplitude;
      return audio.map((s) => s * scaleFactor).toList();
    }

    return audio;
  }

  /// Low-latency FFT for ML model processing
  static List<double> performLowLatencyFft(
    List<double> audioData,
    int sampleRate,
  ) {
    if (audioData.isEmpty) return [];

    // Use smaller FFT size for lower latency (512 instead of 2048)
    int fftSize = math.min(512, _nextPowerOfTwo(audioData.length));

    // Pad or truncate to FFT size
    List<double> paddedAudio = List.filled(fftSize, 0.0);
    int copyLength = math.min(audioData.length, fftSize);
    for (int i = 0; i < copyLength; i++) {
      paddedAudio[i] = audioData[i];
    }

    // Skip windowing for speed (minimal impact on ML model)
    // Perform simplified FFT (magnitude spectrum)
    List<double> magnitudes = _computeMagnitudeSpectrum(paddedAudio);

    // Convert to dB scale (required for ML model)
    List<double> dbMagnitudes = List.filled(magnitudes.length, 0.0);
    for (int i = 0; i < magnitudes.length; i++) {
      dbMagnitudes[i] =
          20.0 * math.log(math.max(magnitudes[i], 1e-10)) / math.ln10;
    }

    // Quick normalization for ML model
    if (dbMagnitudes.isNotEmpty) {
      double maxDb = dbMagnitudes.reduce(math.max);
      double minDb = dbMagnitudes.reduce(math.min);
      double range = maxDb - minDb;

      if (range > 0) {
        for (int i = 0; i < dbMagnitudes.length; i++) {
          dbMagnitudes[i] = (dbMagnitudes[i] - minDb) / range;
        }
      }
    }

    return dbMagnitudes;
  }

  /// Enhanced FFT for frequency visualization (higher quality, slower)
  static List<double> performEnhancedFft(
    List<double> audioData,
    int sampleRate,
  ) {
    if (audioData.isEmpty) return [];

    // Use a power-of-2 FFT size for better performance
    int fftSize = _nextPowerOfTwo(math.min(audioData.length, 2048));

    // Pad or truncate to FFT size
    List<double> paddedAudio = List.filled(fftSize, 0.0);
    int copyLength = math.min(audioData.length, fftSize);
    for (int i = 0; i < copyLength; i++) {
      paddedAudio[i] = audioData[i];
    }

    // Apply window function to reduce spectral leakage
    List<double> windowedAudio = _applyHannWindow(paddedAudio);

    // Perform simplified FFT (magnitude spectrum)
    List<double> magnitudes = _computeMagnitudeSpectrum(windowedAudio);

    // Convert to dB scale for better visualization
    List<double> dbMagnitudes =
        magnitudes.map((mag) {
          return 20.0 * math.log(math.max(mag, 1e-10)) / math.ln10;
        }).toList();

    // Normalize for visualization
    if (dbMagnitudes.isNotEmpty) {
      double maxDb = dbMagnitudes.reduce(math.max);
      double minDb = dbMagnitudes.reduce(math.min);
      double range = maxDb - minDb;

      if (range > 0) {
        dbMagnitudes = dbMagnitudes.map((db) => (db - minDb) / range).toList();
      }
    }

    return dbMagnitudes;
  }

  /// Apply Hann window to reduce spectral leakage
  static List<double> _applyHannWindow(List<double> audio) {
    int n = audio.length;
    return List.generate(n, (i) {
      double window = 0.5 * (1.0 - math.cos(2.0 * math.pi * i / (n - 1)));
      return audio[i] * window;
    });
  }

  /// Compute magnitude spectrum (simplified FFT)
  static List<double> _computeMagnitudeSpectrum(List<double> audio) {
    int n = audio.length;
    int halfN = n ~/ 2;
    List<double> magnitudes = List.filled(halfN, 0.0);

    for (int k = 0; k < halfN; k++) {
      double real = 0.0;
      double imag = 0.0;

      for (int i = 0; i < n; i++) {
        double angle = -2.0 * math.pi * k * i / n;
        real += audio[i] * math.cos(angle);
        imag += audio[i] * math.sin(angle);
      }

      magnitudes[k] = math.sqrt(real * real + imag * imag);
    }

    return magnitudes;
  }

  /// Find next power of 2
  static int _nextPowerOfTwo(int n) {
    int power = 1;
    while (power < n) {
      power *= 2;
    }
    return power;
  }

  /// Get optimal chunk size for low-latency processing
  static int getOptimalChunkSize() {
    return 512; // Optimized for minimal latency (~11.6ms at 44.1kHz)
  }

  /// Clear audio history (call when stopping detection)
  static void clearHistory() {
    _audioHistory.clear();
  }
}
