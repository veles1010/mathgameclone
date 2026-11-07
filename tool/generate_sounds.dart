// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

void main() {
  const sampleRate = 44100;

  // 1. Correct Sound (Pleasing bell / crystal chime)
  final correctSamples = _generateCorrectSound(sampleRate);
  File('assets/audio/correct.wav').writeAsBytesSync(
    _createWav(correctSamples, sampleRate),
  );
  print('Generated assets/audio/correct.wav (${correctSamples.length} samples)');

  // 2. Error Sound (Gentle negative warning / boop)
  final errorSamples = _generateErrorSound(sampleRate);
  File('assets/audio/error.wav').writeAsBytesSync(
    _createWav(errorSamples, sampleRate),
  );
  print('Generated assets/audio/error.wav (${errorSamples.length} samples)');

  // 3. Confetti / Victory Sound (Party pop + celebratory fanfare)
  final confettiSamples = _generateConfettiSound(sampleRate);
  File('assets/audio/confetti.wav').writeAsBytesSync(
    _createWav(confettiSamples, sampleRate),
  );
  print('Generated assets/audio/confetti.wav (${confettiSamples.length} samples)');

  // 4. Tap Sound (Short soft wooden click)
  final tapSamples = _generateTapSound(sampleRate);
  File('assets/audio/tap.wav').writeAsBytesSync(
    _createWav(tapSamples, sampleRate),
  );
  print('Generated assets/audio/tap.wav (${tapSamples.length} samples)');
}

List<int> _generateCorrectSound(int sampleRate) {
  final duration = 0.40; // 400ms
  final numSamples = (duration * sampleRate).toInt();
  final samples = List<int>.filled(numSamples, 0);

  // Two ascending bells: E6 (1318.5 Hz) -> G#6/B6 (1975.5 Hz)
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    double sample = 0.0;

    // First bell: E6 (1318.5 Hz)
    if (t >= 0.0) {
      final t1 = t;
      final env1 = math.exp(-t1 * 14.0) * math.min(t1 / 0.005, 1.0);
      sample += 0.5 * env1 * math.sin(2 * math.pi * 1318.5 * t1);
      sample += 0.2 * env1 * math.sin(2 * math.pi * 2637.0 * t1); // 2nd harmonic
    }

    // Second bell: B6 (1975.5 Hz) starting at 70ms
    if (t >= 0.07) {
      final t2 = t - 0.07;
      final env2 = math.exp(-t2 * 11.0) * math.min(t2 / 0.005, 1.0);
      sample += 0.6 * env2 * math.sin(2 * math.pi * 1975.5 * t2);
      sample += 0.25 * env2 * math.sin(2 * math.pi * 3951.0 * t2);
    }

    final clamped = (sample * 26000).clamp(-32767.0, 32767.0).toInt();
    samples[i] = clamped;
  }
  return samples;
}

List<int> _generateErrorSound(int sampleRate) {
  final duration = 0.24; // 240ms
  final numSamples = (duration * sampleRate).toInt();
  final samples = List<int>.filled(numSamples, 0);

  // Two soft low-pitch buzz pulses: 180Hz -> 130Hz
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    double sample = 0.0;

    // Pulse 1: 0 to 90ms (180 Hz)
    if (t < 0.09) {
      final t1 = t;
      final env1 = math.sin(math.pi * (t1 / 0.09));
      sample = 0.6 * env1 * (
        math.sin(2 * math.pi * 180.0 * t1) +
        0.3 * math.sin(2 * math.pi * 360.0 * t1)
      );
    }
    // Pause 90ms to 110ms
    // Pulse 2: 110ms to 230ms (130 Hz)
    else if (t >= 0.11 && t < 0.23) {
      final t2 = t - 0.11;
      final env2 = math.sin(math.pi * (t2 / 0.12));
      sample = 0.7 * env2 * (
        math.sin(2 * math.pi * 130.0 * t2) +
        0.35 * math.sin(2 * math.pi * 260.0 * t2)
      );
    }

    final clamped = (sample * 24000).clamp(-32767.0, 32767.0).toInt();
    samples[i] = clamped;
  }
  return samples;
}

List<int> _generateConfettiSound(int sampleRate) {
  final duration = 1.7; // 1.7s
  final numSamples = (duration * sampleRate).toInt();
  final samples = List<int>.filled(numSamples, 0);
  final rand = math.Random(42);

  // 1. Party popper POP (0 to 120ms): frequency sweep 900 -> 90 Hz + noise
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    double sample = 0.0;

    // Popper blast
    if (t < 0.15) {
      final tPop = t;
      final envPop = math.exp(-tPop * 35.0);
      final freq = 800.0 * math.exp(-tPop * 30.0) + 80.0;
      final sweep = math.sin(2 * math.pi * freq * tPop);
      final noise = (rand.nextDouble() * 2.0 - 1.0);
      sample += 0.8 * envPop * (0.6 * sweep + 0.4 * noise);
    }

    // Celebratory fanfare chord arpeggio:
    // G5 (784Hz) at 80ms
    // C6 (1046.5Hz) at 200ms
    // E6 (1318.5Hz) at 320ms
    // G6 (1568Hz) at 440ms sustained
    // C7 (2093Hz) at 560ms sparkling peak
    final notes = [
      (0.08, 784.0, 0.45),
      (0.20, 1046.5, 0.50),
      (0.32, 1318.5, 0.55),
      (0.44, 1568.0, 0.65),
      (0.56, 2093.0, 0.50),
    ];

    for (final note in notes) {
      final start = note.$1;
      final freq = note.$2;
      final vol = note.$3;

      if (t >= start) {
        final tn = t - start;
        // Fast attack, long resonant decay
        final attack = math.min(tn / 0.015, 1.0);
        final decay = math.exp(-tn * 2.8);
        final env = attack * decay;
        final tremolo = 1.0 + 0.05 * math.sin(2 * math.pi * 6.0 * tn);

        sample += vol * env * tremolo * (
          math.sin(2 * math.pi * freq * tn) +
          0.3 * math.sin(2 * math.pi * freq * 2.0 * tn)
        );
      }
    }

    // Sparkle glitter in background after pop (0.3s to 1.4s)
    if (t >= 0.25 && t < 1.4) {
      final tg = t - 0.25;
      final sparkleEnv = math.sin(math.pi * (tg / 1.15)) * 0.08;
      // High frequency tinkles
      final sparkleFreq = 2500.0 + 1500.0 * math.sin(2 * math.pi * 12.0 * tg);
      sample += sparkleEnv * math.sin(2 * math.pi * sparkleFreq * tg);
    }

    final clamped = (sample * 22000).clamp(-32767.0, 32767.0).toInt();
    samples[i] = clamped;
  }
  return samples;
}

List<int> _generateTapSound(int sampleRate) {
  final duration = 0.04; // 40ms
  final numSamples = (duration * sampleRate).toInt();
  final samples = List<int>.filled(numSamples, 0);

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final env = math.exp(-t * 90.0);
    final freq = 900.0 * math.exp(-t * 40.0) + 200.0;
    final sample = 0.5 * env * math.sin(2 * math.pi * freq * t);

    final clamped = (sample * 22000).clamp(-32767.0, 32767.0).toInt();
    samples[i] = clamped;
  }
  return samples;
}

Uint8List _createWav(List<int> samples, int sampleRate) {
  const numChannels = 1; // mono
  const bitsPerSample = 16;
  final byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
  const blockAlign = numChannels * (bitsPerSample ~/ 8);
  final subChunk2Size = samples.length * (bitsPerSample ~/ 8);
  final chunkSize = 36 + subChunk2Size;

  final b = ByteData(44 + subChunk2Size);

  // "RIFF"
  b.setUint8(0, 0x52); b.setUint8(1, 0x49); b.setUint8(2, 0x46); b.setUint8(3, 0x46);
  b.setUint32(4, chunkSize, Endian.little);

  // "WAVE"
  b.setUint8(8, 0x57); b.setUint8(9, 0x41); b.setUint8(10, 0x56); b.setUint8(11, 0x45);

  // "fmt "
  b.setUint8(12, 0x66); b.setUint8(13, 0x6D); b.setUint8(14, 0x74); b.setUint8(15, 0x20);
  b.setUint32(16, 16, Endian.little); // Subchunk1Size
  b.setUint16(20, 1, Endian.little); // PCM
  b.setUint16(22, numChannels, Endian.little);
  b.setUint32(24, sampleRate, Endian.little);
  b.setUint32(28, byteRate, Endian.little);
  b.setUint16(32, blockAlign, Endian.little);
  b.setUint16(34, bitsPerSample, Endian.little);

  // "data"
  b.setUint8(36, 0x64); b.setUint8(37, 0x61); b.setUint8(38, 0x74); b.setUint8(39, 0x61);
  b.setUint32(40, subChunk2Size, Endian.little);

  // Samples
  for (int i = 0; i < samples.length; i++) {
    b.setInt16(44 + (i * 2), samples[i], Endian.little);
  }

  return b.buffer.asUint8List();
}
