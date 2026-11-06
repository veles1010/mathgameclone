import 'package:flutter_test/flutter_test.dart';
import 'package:crossmath_puzzle/services/math_evaluator.dart';
import 'package:crossmath_puzzle/models/crossmath_puzzle.dart';
import 'package:crossmath_puzzle/services/puzzle_generator.dart';

void main() {
  group('MathEvaluator Tests', () {
    test('Standard order of operations (BODMAS/PEMDAS)', () {
      // 2 + 3 * 4 = 14
      final result1 = MathEvaluator.evaluate(
        numbers: [2, 3, 4],
        operators: ['+', '×'],
      );
      expect(result1, equals(14));

      // 10 - 6 / 2 = 7
      final result2 = MathEvaluator.evaluate(
        numbers: [10, 6, 2],
        operators: ['-', '÷'],
      );
      expect(result2, equals(7));

      // 4 * 3 + 8 / 2 = 12 + 4 = 16
      final result3 = MathEvaluator.evaluate(
        numbers: [4, 3, 8, 2],
        operators: ['×', '+', '÷'],
      );
      expect(result3, equals(16));
    });

    test('Non-integer division should return null', () {
      // 5 / 2 = 2.5 (invalid in Crossmath)
      final result = MathEvaluator.evaluate(
        numbers: [5, 2],
        operators: ['÷'],
      );
      expect(result, isNull);
    });

    test('Division by zero should return null', () {
      final result = MathEvaluator.evaluate(
        numbers: [5, 0],
        operators: ['÷'],
      );
      expect(result, isNull);
    });
  });

  group('PuzzleGenerator Tests', () {
    test('Generate easy puzzle generates valid equations', () {
      final puzzle = PuzzleGenerator.getPuzzle(
        difficulty: PuzzleDifficulty.easy,
        levelNumber: 1,
      );
      expect(puzzle.rows, equals(5));
      expect(puzzle.equations.isNotEmpty, isTrue);
      expect(puzzle.initialNumbersToPlace.isNotEmpty, isTrue);
    });

    test('Generate medium pattern puzzle generates valid equations', () {
      final puzzle = PuzzleGenerator.getPuzzle(
        difficulty: PuzzleDifficulty.medium,
        levelNumber: 1,
      );
      expect(puzzle.rows, equals(9));
      expect(puzzle.equations.isNotEmpty, isTrue);
    });

    test('Generate hard pattern puzzle generates valid equations', () {
      final puzzle = PuzzleGenerator.getPuzzle(
        difficulty: PuzzleDifficulty.hard,
        levelNumber: 1,
      );
      expect(puzzle.rows, equals(11));
      expect(puzzle.equations.isNotEmpty, isTrue);
    });

    test('Generate expert pattern puzzle generates valid equations', () {
      final puzzle = PuzzleGenerator.getPuzzle(
        difficulty: PuzzleDifficulty.expert,
        levelNumber: 1,
      );
      expect(puzzle.rows, equals(11));
      expect(puzzle.equations.isNotEmpty, isTrue);
    });
  });
}
