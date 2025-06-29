// lib/data/repositories/tflite_model_repository.dart

import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Manages the loading, inference, and lifecycle of the TensorFlow Lite model.
/// This class encapsulates all tflite_flutter plugin details.
class TfliteModelRepository {
  Interpreter? _interpreter;

  /// Returns true if the model interpreter has been successfully loaded.
  bool get isLoaded => _interpreter != null;

  /// Gets the required shape for the model's input tensor.
  /// Returns null if the model is not loaded.
  List<int>? get inputShape =>
      isLoaded ? _interpreter!.getInputTensor(0).shape : null;

  /// Gets the shape of the model's output tensor.
  /// Returns null if the model is not loaded.
  List<int>? get outputShape =>
      isLoaded ? _interpreter!.getOutputTensor(0).shape : null;

  TensorType? get outputType =>
      isLoaded ? _interpreter!.getOutputTensor(0).type : null;

  /// Loads the TensorFlow Lite model from the specified asset path.
  Future<void> loadModel(String modelPath) async {
    try {
      // Ensure any previous interpreter is closed before loading a new one
      if (_interpreter != null) {
        _interpreter!.close();
      }

      print('Attempting to load model from: $modelPath');

      // Try using Interpreter.fromAsset first as it's more reliable
      try {
        _interpreter = await Interpreter.fromAsset(modelPath);
        print('TensorFlow Lite model loaded successfully using fromAsset');
      } catch (assetError) {
        print('fromAsset failed: $assetError, trying fromBuffer...');

        // Fallback to fromBuffer approach
        final ByteData data = await rootBundle.load(modelPath);
        final Uint8List buffer = data.buffer.asUint8List();
        print('Buffer loaded, size: ${buffer.length} bytes');

        _interpreter = await Interpreter.fromBuffer(buffer);
        print('TensorFlow Lite model loaded successfully from buffer');
      }

      // Optional: Allocate tensors now if you know the input shape won't change.
      // _interpreter?.allocateTensors();

      print(
        'Model Input Tensor: ${_interpreter!.getInputTensor(0).shape}, Type: ${_interpreter!.getInputTensor(0).type}',
      );
      print(
        'Model Output Tensor: ${_interpreter!.getOutputTensor(0).shape}, Type: ${_interpreter!.getOutputTensor(0).type}',
      );
    } on MissingPluginException catch (e) {
      print(
        'Error loading TFLite model: Missing TFLite plugin implementation. Ensure you have run `flutter pub get` and configured platform-specific files correctly. Error: $e',
      );
    } catch (e) {
      print('Failed to load TensorFlow Lite model from $modelPath: $e');
    }
  }

  /// Runs inference on the loaded model with the given input.
  ///
  /// [input] should be a multi-dimensional list matching the model's input shape.
  /// For example: `[[1.0, 2.0, 3.0]]`
  ///
  /// [output] should be a pre-sized buffer to store the result. Its shape
  /// must also match the model's output.
  /// For example: `List<List<double>>.filled(1, List<double>.filled(10, 0))`
  void runInference(Object input, Object output) {
    if (!isLoaded) {
      print('Interpreter is not loaded. Please load a model first.');
      return;
    }
    _interpreter!.run(input, output);
  }

  /// Closes the TensorFlow Lite interpreter and releases resources.
  void closeModel() {
    if (_interpreter != null) {
      _interpreter!.close();
      _interpreter = null;
      print('TensorFlow Lite interpreter closed.');
    }
  }
}
