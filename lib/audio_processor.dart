import 'dart:math';
import 'dart:typed_data';

class Complex {
  final double real;
  final double imaginary;

  const Complex(this.real, this.imaginary);

  Complex operator +(Complex other) =>
      Complex(real + other.real, imaginary + other.imaginary);

  Complex operator -(Complex other) =>
      Complex(real - other.real, imaginary - other.imaginary);

  Complex operator *(Complex other) => Complex(
    real * other.real - imaginary * other.imaginary,
    real * other.imaginary + imaginary * other.real,
  );

  double get magnitude => sqrt(real * real + imaginary * imaginary);
}

class AudioProcessor {
  // Match web version's audio processing parameters
  final int sampleRate = 44100; // Same as web version
  final int fftSize = 2048; // Increased for better frequency resolution
  final int melBands = 232;
  final int windowLength = 400; // 25ms window
  final int hopLength = 160; // 10ms hop (similar to web version's overlap)

  List<List<double>> extractMelSpectrogram(Float64List audioSamples) {
    // Step 1: Use samples as-is (they should already be normalized from audio capture)
    List<double> signal = audioSamples.toList();

    // Step 2: Framing and Hamming Window
    int numFrames = ((signal.length - windowLength) / hopLength).floor() + 1;
    List<List<double>> frames = [];

    for (int i = 0; i < numFrames; i++) {
      int start = i * hopLength;
      int end = start + windowLength;
      if (end > signal.length) {
        // Pad with zeros if needed
        List<double> frame = signal.sublist(start);
        frame.addAll(List.filled(end - signal.length, 0.0));
        frame = _applyHammingWindow(frame);
        frames.add(frame);
      } else {
        List<double> frame = signal.sublist(start, end);
        frame = _applyHammingWindow(frame);
        frames.add(frame);
      }
    }

    // Step 3: FFT and power spectrum
    List<List<double>> powerSpectrogram =
        frames.map((frame) {
          // Pad frame to fftSize if needed
          while (frame.length < fftSize) {
            frame.add(0.0);
          }

          List<Complex> fftResult = _performFFT(frame);
          List<double> power = [];

          for (int i = 0; i < fftResult.length ~/ 2; i++) {
            double magnitude = fftResult[i].magnitude;
            power.add((magnitude * magnitude) / fftSize);
          }

          return power;
        }).toList();

    // Step 4: Mel filter banks
    List<List<double>> melFilterBank = _createMelFilterBank();

    // Step 5: Apply mel filters
    List<List<double>> melSpectrogram =
        powerSpectrogram.map((spectrum) {
          List<double> melBandsOut = [];
          for (var filter in melFilterBank) {
            double sum = 0.0;
            for (int i = 0; i < filter.length && i < spectrum.length; i++) {
              sum += filter[i] * spectrum[i];
            }
            // Use natural log as the model expects
            melBandsOut.add(log(1e-10 + sum));
          }
          return melBandsOut;
        }).toList();

    // Step 6: Pad/clip to [43, 232] - no normalization
    return _resizeToFixedShape(melSpectrogram, 43, melBands);
  }

  List<Complex> _performFFT(List<double> input) {
    int n = input.length;

    // Convert to complex numbers
    List<Complex> x = input.map((val) => Complex(val, 0.0)).toList();

    // Simple DFT implementation (not optimized FFT, but works for our purpose)
    List<Complex> X = List.filled(n, const Complex(0, 0));

    for (int k = 0; k < n; k++) {
      for (int n_idx = 0; n_idx < n; n_idx++) {
        double angle = -2 * pi * k * n_idx / n;
        Complex w = Complex(cos(angle), sin(angle));
        X[k] = X[k] + (x[n_idx] * w);
      }
    }

    return X;
  }

  List<double> _applyHammingWindow(List<double> frame) {
    int N = frame.length;
    return List.generate(
      N,
      (i) => frame[i] * (0.54 - 0.46 * cos((2 * pi * i) / (N - 1))),
    );
  }

  List<List<double>> _createMelFilterBank() {
    int numMelFilters = melBands;
    int fftBins = fftSize ~/ 2;
    double lowFreq = 0;
    double highFreq = sampleRate / 2;

    double hzToMel(double hz) => 2595 * log(1 + hz / 700);
    double melToHz(double mel) => 700 * (exp(mel / 2595) - 1);

    double melLow = hzToMel(lowFreq);
    double melHigh = hzToMel(highFreq);
    List<double> melPoints = List.generate(
      numMelFilters + 2,
      (i) => melLow + (melHigh - melLow) * i / (numMelFilters + 1),
    );
    List<double> hzPoints = melPoints.map(melToHz).toList();
    List<int> bin =
        hzPoints.map((f) => (f / (sampleRate / 2) * fftBins).floor()).toList();

    List<List<double>> filterBank = [];

    for (int i = 1; i <= numMelFilters; i++) {
      List<double> filter = List.filled(fftBins, 0.0);
      for (int j = bin[i - 1]; j < bin[i]; j++) {
        if (j < filter.length) {
          filter[j] = (j - bin[i - 1]) / (bin[i] - bin[i - 1] + 1e-6);
        }
      }
      for (int j = bin[i]; j < bin[i + 1]; j++) {
        if (j < filter.length) {
          filter[j] = (bin[i + 1] - j) / (bin[i + 1] - bin[i] + 1e-6);
        }
      }
      filterBank.add(filter);
    }

    return filterBank;
  }

  List<List<double>> _resizeToFixedShape(
    List<List<double>> input,
    int targetRows,
    int targetCols,
  ) {
    // Ensure matrix has exactly [targetRows, targetCols]
    List<List<double>> resized = List.generate(targetRows, (i) {
      if (i < input.length) {
        List<double> row = input[i];
        if (row.length >= targetCols) return row.sublist(0, targetCols);
        return [...row, ...List.filled(targetCols - row.length, 0.0)];
      } else {
        return List.filled(targetCols, 0.0);
      }
    });

    return resized;
  }
}
