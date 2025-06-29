// lib/domain/entities/raw_audio_chunk.dart

import 'dart:typed_data';

/// Represents a chunk of raw audio data captured from the microphone.
class RawAudioChunk {
  /// The raw audio samples as a [Uint8List] (e.g., 16-bit PCM bytes).
  final Uint8List bytes;

  /// The timestamp when this audio chunk was captured.
  final DateTime timestamp;

  RawAudioChunk({required this.bytes, required this.timestamp});
}
