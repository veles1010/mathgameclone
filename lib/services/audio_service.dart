import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool isSoundEnabled = true;

  // Lazy-loaded audio players
  AudioPlayer? _sfxPlayer;
  AudioPlayer? _celebrationPlayer;

  AudioPlayer get _sfx => _sfxPlayer ??= AudioPlayer();
  AudioPlayer get _celebration => _celebrationPlayer ??= AudioPlayer();

  Future<void> init() async {
    try {
      await _sfx.setPlayerMode(PlayerMode.lowLatency);
      await _celebration.setPlayerMode(PlayerMode.lowLatency);
    } catch (e) {
      debugPrint('AudioService init error: $e');
    }
  }

  /// Positive chime when an equation is completed correctly
  Future<void> playCorrect() async {
    if (!isSoundEnabled) return;
    try {
      await _sfx.stop();
      await _sfx.play(AssetSource('audio/correct.wav'), volume: 0.85);
    } catch (e) {
      debugPrint('playCorrect error: $e');
    }
  }

  /// Gentle negative warning when an equation evaluates incorrectly
  Future<void> playError() async {
    if (!isSoundEnabled) return;
    try {
      await _sfx.stop();
      await _sfx.play(AssetSource('audio/error.wav'), volume: 0.75);
    } catch (e) {
      debugPrint('playError error: $e');
    }
  }

  /// Confetti burst / victory celebration sound
  Future<void> playConfetti() async {
    if (!isSoundEnabled) return;
    try {
      await _celebration.stop();
      await _celebration.play(AssetSource('audio/confetti.wav'), volume: 1.0);
    } catch (e) {
      debugPrint('playConfetti error: $e');
    }
  }

  /// Short soft tap when moving numbers
  Future<void> playTap() async {
    if (!isSoundEnabled) return;
    try {
      await _sfx.stop();
      await _sfx.play(AssetSource('audio/tap.wav'), volume: 0.40);
    } catch (e) {
      debugPrint('playTap error: $e');
    }
  }

  void dispose() {
    _sfxPlayer?.dispose();
    _celebrationPlayer?.dispose();
  }
}
