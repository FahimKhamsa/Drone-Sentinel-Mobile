import 'dart:typed_data';
import 'browser_fft_processor.dart';

abstract class AudioFeatureExtractor {
  Float32List extractFeatures(List<double> audioData, int sampleRate);
}

class BrowserFFTExtractor implements AudioFeatureExtractor {
  final BrowserFFTProcessor _browserFFTProcessor = BrowserFFTProcessor();

  @override
  Float32List extractFeatures(List<double> audioData, int sampleRate) {
    if (audioData.isEmpty) {
      return Float32List(43 * 232); // Return empty features with correct shape
    }

    // Use Browser FFT processor to replicate web version's 'BROWSER_FFT' functionality
    // This produces a Log-Mel Spectrogram (NOT MFCCs) - exactly like the web version
    Float32List features = _browserFFTProcessor.processAudioLikeBrowserFFT(
      audioData,
    );

    print(
      'Browser FFT Log-Mel Spectrogram extraction performed. Features shape: [43, 232], flattened length: ${features.length}',
    );
    return features;
  }
}

class DummyAudioExtractor implements AudioFeatureExtractor {
  static const int _numFeatures = 43 * 232; // Match model input requirements

  @override
  Float32List extractFeatures(List<double> audioData, int sampleRate) {
    if (audioData.isEmpty) {
      return Float32List(_numFeatures);
    }

    Float32List features = Float32List(_numFeatures);
    for (int i = 0; i < _numFeatures; i++) {
      if (i < audioData.length) {
        features[i] = audioData[i];
      } else {
        features[i] = 0.0;
      }
    }

    print(
      'Dummy audio extraction performed. Features length: ${features.length}',
    );
    return features;
  }
}
