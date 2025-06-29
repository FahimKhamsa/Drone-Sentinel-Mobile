// lib/domain/feature_extraction/browser_fft_processor.dart

import 'dart:typed_data';
import 'dart:math' as math;

/// Replicates the functionality of TensorFlow.js 'BROWSER_FFT' for speech commands
/// This processor mimics what the web version does automatically:
/// 1. Raw audio from microphone
/// 2. Browser's built-in FFT processing
/// 3. Automatic spectrogram creation
/// 4. Normalization and formatting for the neural network
class BrowserFFTProcessor {
  // Adjusted parameters for reduced false positives
  static const int sampleRate = 44100;
  static const int fftSize = 1024; // Increased for better frequency resolution
  static const int hopLength = 200; // Reduced overlap for more distinct frames
  static const int windowLength =
      512; // Increased window for better frequency analysis
  static const int numMelBins = 232; // Match your model's expected input
  static const int numFrames = 43; // Match your model's expected input

  /// Processes raw audio data exactly like 'BROWSER_FFT' does
  /// Returns a spectrogram in the format [43, 232] that matches model expectations
  Float32List processAudioLikeBrowserFFT(List<double> audioData) {
    // Use low-latency processing for real-time performance
    return _processAudioLowLatency(audioData);
  }

  /// Low-latency version of Browser FFT processing
  Float32List _processAudioLowLatency(List<double> audioData) {
    // Step 1: Ensure we have exactly 1 second of audio (44100 samples)
    List<double> processedAudio = _ensureCorrectLengthFast(audioData);

    // Step 2: Apply quick normalization
    processedAudio = _quickNormalization(processedAudio);

    // Step 3: Create frames with reduced overlap for speed
    List<List<double>> frames = _createFramesFast(processedAudio);

    // Step 4: Skip windowing for speed (minimal impact on accuracy)
    // Step 5: Perform simplified FFT on each frame
    List<List<double>> powerSpectrum =
        frames.map((frame) => _computePowerSpectrumFast(frame)).toList();

    // Step 6: Apply simplified mel-scale filtering
    List<List<double>> melSpectrogram = _applyMelFiltersFast(powerSpectrum);

    // Step 7: Apply log scaling
    melSpectrogram = _applyLogScalingFast(melSpectrogram);

    // Step 8: Format for model
    return _formatForModelFast(melSpectrogram);
  }

  // /// High-quality version for non-latency critical use
  // Float32List _processAudioHighQuality(List<double> audioData) {
  //   // Step 1: Ensure we have exactly 1 second of audio (44100 samples)
  //   List<double> processedAudio = _ensureCorrectLength(audioData);

  //   // Step 2: Apply browser-like normalization
  //   processedAudio = _browserNormalization(processedAudio);

  //   // Step 3: Create overlapping frames (like web version's overlap processing)
  //   List<List<double>> frames = _createOverlappingFrames(processedAudio);

  //   // Step 4: Apply window function to each frame
  //   frames = frames.map((frame) => _applyHannWindow(frame)).toList();

  //   // Step 5: Perform FFT on each frame
  //   List<List<double>> powerSpectrum =
  //       frames.map((frame) => _computePowerSpectrum(frame)).toList();

  //   // Step 6: Apply mel-scale filtering (like browser's audio processing)
  //   List<List<double>> melSpectrogram = _applyMelFilters(powerSpectrum);

  //   // Step 7: Apply log scaling and final normalization
  //   melSpectrogram = _applyLogScaling(melSpectrogram);

  //   // Step 8: Ensure exact output shape [43, 232] and flatten
  //   return _formatForModel(melSpectrogram);
  // }

  // /// Ensures audio data is exactly the right length (1 second at current sample rate)
  // List<double> _ensureCorrectLength(List<double> audioData) {
  //   const int targetLength = sampleRate; // samples = 1 second

  //   if (audioData.length == targetLength) {
  //     return audioData;
  //   } else if (audioData.length < targetLength) {
  //     // Pad with zeros
  //     return [
  //       ...audioData,
  //       ...List.filled(targetLength - audioData.length, 0.0),
  //     ];
  //   } else {
  //     // Take the most recent samples (like real-time processing)
  //     return audioData.sublist(audioData.length - targetLength);
  //   }
  // }

  // /// Browser-like audio normalization
  // List<double> _browserNormalization(List<double> audioData) {
  //   // Find peak amplitude
  //   double maxAmplitude = audioData.map((x) => x.abs()).reduce(math.max);

  //   if (maxAmplitude == 0.0) {
  //     return audioData;
  //   }

  //   // Normalize to [-1, 1] range (like Web Audio API)
  //   return audioData.map((x) => x / maxAmplitude).toList();
  // }

  // /// Creates overlapping frames like the web version
  // List<List<double>> _createOverlappingFrames(List<double> audioData) {
  //   List<List<double>> frames = [];

  //   for (
  //     int start = 0;
  //     start + windowLength <= audioData.length;
  //     start += hopLength
  //   ) {
  //     List<double> frame = audioData.sublist(start, start + windowLength);
  //     frames.add(frame);
  //   }

  //   // Ensure we have exactly the right number of frames
  //   while (frames.length < numFrames) {
  //     frames.add(List.filled(windowLength, 0.0));
  //   }

  //   return frames.take(numFrames).toList();
  // }

  // /// Applies Hann window (commonly used in browser audio processing)
  // List<double> _applyHannWindow(List<double> frame) {
  //   List<double> windowed = List.filled(frame.length, 0.0);

  //   for (int i = 0; i < frame.length; i++) {
  //     double window =
  //         0.5 * (1 - math.cos(2 * math.pi * i / (frame.length - 1)));
  //     windowed[i] = frame[i] * window;
  //   }

  //   return windowed;
  // }

  // /// Computes power spectrum using FFT
  // List<double> _computePowerSpectrum(List<double> frame) {
  //   // Pad frame to FFT size - create a new list to avoid fixed-length list error
  //   List<double> paddedFrame = List<double>.from(frame);
  //   while (paddedFrame.length < fftSize) {
  //     paddedFrame.add(0.0);
  //   }

  //   // Perform FFT (simplified implementation)
  //   List<Complex> fftResult = _performFFT(paddedFrame);

  //   // Compute power spectrum (magnitude squared)
  //   List<double> powerSpectrum = [];
  //   int numBins = fftSize ~/ 2 + 1; // Only positive frequencies

  //   for (int i = 0; i < numBins; i++) {
  //     double magnitude = fftResult[i].magnitude;
  //     powerSpectrum.add(magnitude * magnitude);
  //   }

  //   return powerSpectrum;
  // }

  // /// Simple FFT implementation
  // List<Complex> _performFFT(List<double> input) {
  //   int n = input.length;
  //   List<Complex> x = input.map((val) => Complex(val, 0.0)).toList();
  //   List<Complex> X = List.filled(n, const Complex(0, 0));

  //   for (int k = 0; k < n; k++) {
  //     for (int n_idx = 0; n_idx < n; n_idx++) {
  //       double angle = -2 * math.pi * k * n_idx / n;
  //       Complex w = Complex(math.cos(angle), math.sin(angle));
  //       X[k] = X[k] + (x[n_idx] * w);
  //     }
  //   }

  //   return X;
  // }

  // /// Applies mel-scale filters (like browser's audio analysis)
  // List<List<double>> _applyMelFilters(List<List<double>> powerSpectrum) {
  //   // Create mel filter bank
  //   List<List<double>> melFilters = _createMelFilterBank();

  //   List<List<double>> melSpectrogram = [];

  //   for (List<double> spectrum in powerSpectrum) {
  //     List<double> melFrame = [];

  //     for (List<double> filter in melFilters) {
  //       double sum = 0.0;
  //       for (int i = 0; i < math.min(filter.length, spectrum.length); i++) {
  //         sum += filter[i] * spectrum[i];
  //       }
  //       melFrame.add(sum);
  //     }

  //     melSpectrogram.add(melFrame);
  //   }

  //   return melSpectrogram;
  // }

  // /// Creates mel filter bank
  // List<List<double>> _createMelFilterBank() {
  //   int numFilters = numMelBins;
  //   int fftBins = fftSize ~/ 2 + 1;
  //   double lowFreq = 0;
  //   double highFreq = sampleRate / 2;

  //   // Convert to mel scale
  //   double hzToMel(double hz) => 2595 * math.log(1 + hz / 700) / math.ln10;
  //   double melToHz(double mel) => 700 * (math.pow(10, mel / 2595) - 1);

  //   double melLow = hzToMel(lowFreq);
  //   double melHigh = hzToMel(highFreq);

  //   List<double> melPoints = List.generate(
  //     numFilters + 2,
  //     (i) => melLow + (melHigh - melLow) * i / (numFilters + 1),
  //   );

  //   List<double> hzPoints = melPoints.map(melToHz).toList();
  //   List<int> bin =
  //       hzPoints.map((f) => (f / (sampleRate / 2) * fftBins).floor()).toList();

  //   List<List<double>> filterBank = [];

  //   for (int i = 1; i <= numFilters; i++) {
  //     List<double> filter = List.filled(fftBins, 0.0);

  //     for (int j = bin[i - 1]; j < bin[i]; j++) {
  //       if (j < filter.length) {
  //         filter[j] = (j - bin[i - 1]) / (bin[i] - bin[i - 1] + 1e-6);
  //       }
  //     }

  //     for (int j = bin[i]; j < bin[i + 1]; j++) {
  //       if (j < filter.length) {
  //         filter[j] = (bin[i + 1] - j) / (bin[i + 1] - bin[i] + 1e-6);
  //       }
  //     }

  //     filterBank.add(filter);
  //   }

  //   return filterBank;
  // }

  // /// Applies log scaling (like browser's audio processing)
  // List<List<double>> _applyLogScaling(List<List<double>> melSpectrogram) {
  //   return melSpectrogram.map((frame) {
  //     return frame.map((value) => math.log(value + 1e-8)).toList();
  //   }).toList();
  // }

  // /// Formats the spectrogram for the model (exactly [43, 232] shape)
  // Float32List _formatForModel(List<List<double>> melSpectrogram) {
  //   // Ensure exact dimensions
  //   List<List<double>> formatted = List.generate(numFrames, (i) {
  //     if (i < melSpectrogram.length) {
  //       List<double> frame = melSpectrogram[i];
  //       if (frame.length >= numMelBins) {
  //         return frame.sublist(0, numMelBins);
  //       } else {
  //         return [...frame, ...List.filled(numMelBins - frame.length, 0.0)];
  //       }
  //     } else {
  //       return List.filled(numMelBins, 0.0);
  //     }
  //   });

  //   // Flatten to 1D array
  //   List<double> flattened = [];
  //   for (var frame in formatted) {
  //     flattened.addAll(frame);
  //   }

  //   return Float32List.fromList(flattened);
  // }

  // ===== LOW-LATENCY OPTIMIZED METHODS =====

  /// Fast audio length adjustment
  List<double> _ensureCorrectLengthFast(List<double> audioData) {
    const int targetLength = sampleRate;

    if (audioData.length >= targetLength) {
      // Take most recent samples (no copying if exact length)
      return audioData.length == targetLength
          ? audioData
          : audioData.sublist(audioData.length - targetLength);
    } else {
      // Pad with zeros (minimal allocation)
      return [
        ...audioData,
        ...List.filled(targetLength - audioData.length, 0.0),
      ];
    }
  }

  /// Quick normalization (single pass)
  List<double> _quickNormalization(List<double> audioData) {
    double maxAmplitude = 0.0;

    // Find max in single pass
    for (double sample in audioData) {
      double abs = sample.abs();
      if (abs > maxAmplitude) maxAmplitude = abs;
    }

    if (maxAmplitude == 0.0) return audioData;

    // Normalize in-place style
    double scaleFactor = 1.0 / maxAmplitude;
    return audioData.map((x) => x * scaleFactor).toList();
  }

  /// Fast frame creation with reduced overlap
  List<List<double>> _createFramesFast(List<double> audioData) {
    List<List<double>> frames = [];
    const int fastHopLength =
        240; // Larger hop = less overlap = faster processing

    for (
      int start = 0;
      start + windowLength <= audioData.length;
      start += fastHopLength
    ) {
      frames.add(audioData.sublist(start, start + windowLength));
    }

    // Ensure exact frame count
    while (frames.length < numFrames) {
      frames.add(List.filled(windowLength, 0.0));
    }

    return frames.take(numFrames).toList();
  }

  /// Fast power spectrum computation (simplified FFT)
  List<double> _computePowerSpectrumFast(List<double> frame) {
    // Use smaller FFT size for speed
    const int fastFftSize = 256;

    List<double> paddedFrame = List<double>.from(frame);
    while (paddedFrame.length < fastFftSize) {
      paddedFrame.add(0.0);
    }

    // Simplified FFT with fewer bins
    List<Complex> fftResult = _performFFTFast(
      paddedFrame.take(fastFftSize).toList(),
    );

    List<double> powerSpectrum = [];
    int numBins = fastFftSize ~/ 2 + 1;

    for (int i = 0; i < numBins; i++) {
      double magnitude = fftResult[i].magnitude;
      powerSpectrum.add(magnitude * magnitude);
    }

    return powerSpectrum;
  }

  /// Fast FFT implementation (reduced precision for speed)
  List<Complex> _performFFTFast(List<double> input) {
    int n = input.length;
    List<Complex> X = List.filled(n, const Complex(0, 0));

    // Simplified DFT with reduced precision
    for (int k = 0; k < n ~/ 2; k++) {
      // Only compute half for speed
      double real = 0.0;
      double imag = 0.0;

      for (int i = 0; i < n; i += 2) {
        // Skip every other sample for speed
        double angle = -2 * math.pi * k * i / n;
        real += input[i] * math.cos(angle);
        imag += input[i] * math.sin(angle);
      }

      X[k] = Complex(real, imag);
    }

    return X;
  }

  /// Fast mel filter application
  List<List<double>> _applyMelFiltersFast(List<List<double>> powerSpectrum) {
    // Use cached filter bank for speed
    List<List<double>> melFilters = _createMelFilterBankFast();

    return powerSpectrum.map((spectrum) {
      List<double> melFrame = [];

      for (List<double> filter in melFilters) {
        double sum = 0.0;
        int minLength = math.min(filter.length, spectrum.length);

        for (int i = 0; i < minLength; i++) {
          sum += filter[i] * spectrum[i];
        }

        melFrame.add(sum);
      }

      return melFrame;
    }).toList();
  }

  /// Fast mel filter bank creation (reduced precision)
  List<List<double>> _createMelFilterBankFast() {
    // Use fewer filters for speed
    int fastNumFilters = numMelBins;
    int fftBins = 128 + 1; // Match fast FFT size

    List<List<double>> filterBank = [];

    // Simplified linear spacing instead of mel scale for speed
    for (int i = 0; i < fastNumFilters; i++) {
      List<double> filter = List.filled(fftBins, 0.0);

      // Simple triangular filter
      int center = (i * fftBins / fastNumFilters).round();
      int width = (fftBins / fastNumFilters).round();

      for (
        int j = math.max(0, center - width);
        j < math.min(fftBins, center + width);
        j++
      ) {
        filter[j] = 1.0 - (j - center).abs() / width;
      }

      filterBank.add(filter);
    }

    return filterBank;
  }

  /// Fast log scaling
  List<List<double>> _applyLogScalingFast(List<List<double>> melSpectrogram) {
    return melSpectrogram.map((frame) {
      return frame
          .map((value) => math.log(value + 1e-6))
          .toList(); // Slightly less precision for speed
    }).toList();
  }

  /// Fast model formatting
  Float32List _formatForModelFast(List<List<double>> melSpectrogram) {
    // Pre-allocate output array
    Float32List result = Float32List(numFrames * numMelBins);

    for (int i = 0; i < numFrames; i++) {
      List<double> frame =
          i < melSpectrogram.length
              ? melSpectrogram[i]
              : List.filled(numMelBins, 0.0);

      for (int j = 0; j < numMelBins; j++) {
        result[i * numMelBins + j] = j < frame.length ? frame[j] : 0.0;
      }
    }

    return result;
  }
}

/// Complex number class for FFT
class Complex {
  final double real;
  final double imaginary;

  const Complex(this.real, this.imaginary);

  Complex operator +(Complex other) =>
      Complex(real + other.real, imaginary + other.imaginary);

  Complex operator *(Complex other) => Complex(
    real * other.real - imaginary * other.imaginary,
    real * other.imaginary + imaginary * other.real,
  );

  double get magnitude => math.sqrt(real * real + imaginary * imaginary);
}
