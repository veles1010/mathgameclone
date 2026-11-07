import 'package:flutter_test/flutter_test.dart';
import 'package:crossmath_puzzle/services/math_evaluator.dart';
import 'package:crossmath_puzzle/models/crossmath_puzzle.dart';
import 'package:crossmath_puzzle/services/puzzle_generator.dart';

void main() {
  group('MathEvaluator Tests', () {
    test('Simple addition', () {
      expect(MathEvaluator.evaluate(numbers: [3, 5], operators: ['+']), 8);
    });

    test('Simple subtraction', () {
      expect(MathEvaluator.evaluate(numbers: [10, 3], operators: ['-']), 7);
    });

    test('Multiplication', () {
      expect(MathEvaluator.evaluate(numbers: [4, 5], operators: ['×']), 20);
    });

    test('Division', () {
      expect(MathEvaluator.evaluate(numbers: [12, 4], operators: ['÷']), 3);
    });

    test('Non-integer division returns null', () {
      expect(MathEvaluator.evaluate(numbers: [5, 2], operators: ['÷']), isNull);
    });

    test('Division by zero returns null', () {
      expect(MathEvaluator.evaluate(numbers: [5, 0], operators: ['÷']), isNull);
    });
  });

  group('PuzzleGenerator Tests', () {
    test('Generate easy puzzle', () {
      final puzzle = PuzzleGenerator.getPuzzle(
        difficulty: PuzzleDifficulty.easy,
        levelNumber: 1,
      );
      expect(puzzle.rows, equals(5));
      expect(puzzle.cols, equals(5));
      expect(puzzle.equations.length, equals(4));
      expect(puzzle.initialNumbersToPlace.isNotEmpty, isTrue);
    });

    test('Generate medium puzzle (quad islands)', () {
      final puzzle = PuzzleGenerator.getPuzzle(
        difficulty: PuzzleDifficulty.medium,
        levelNumber: 1,
      );
      expect(puzzle.rows, equals(11));
      expect(puzzle.cols, equals(11));
      expect(puzzle.equations.isNotEmpty, isTrue);
    });

    test('Generate hard puzzle', () {
      final puzzle = PuzzleGenerator.getPuzzle(
        difficulty: PuzzleDifficulty.hard,
        levelNumber: 1,
      );
      expect(puzzle.rows, equals(11));
      expect(puzzle.equations.isNotEmpty, isTrue);
    });

    test('Generate expert puzzle', () {
      final puzzle = PuzzleGenerator.getPuzzle(
        difficulty: PuzzleDifficulty.expert,
        levelNumber: 1,
      );
      expect(puzzle.rows, equals(11));
      expect(puzzle.equations.isNotEmpty, isTrue);
    });

    void verifyPuzzleMath(CrossmathPuzzle puzzle) {
      for (final eq in puzzle.equations) {
        final numbers = <int>[];
        for (final coord in eq.numberCoords) {
          final cell = puzzle.grid[coord.$1][coord.$2];
          expect(cell.solutionValue, isNotNull,
              reason: 'Cell at $coord in equation ${eq.id} has null solutionValue');
          numbers.add(cell.solutionValue!);
        }
        final targetResCell = puzzle.grid[eq.resultCoord.$1][eq.resultCoord.$2];
        final targetVal = targetResCell.solutionValue ?? targetResCell.resultValue ?? eq.targetResult;
        final result = MathEvaluator.evaluate(numbers: numbers, operators: eq.operators);
        expect(result, equals(targetVal),
            reason: '${puzzle.id} Equation ${eq.id} failed: $numbers ${eq.operators} = $result (expected $targetVal)');
      }
    }

    test('Easy puzzle equations are correct across levels 1-20', () {
      for (int lvl = 1; lvl <= 20; lvl++) {
        final puzzle = PuzzleGenerator.getPuzzle(
          difficulty: PuzzleDifficulty.easy,
          levelNumber: lvl,
        );
        verifyPuzzleMath(puzzle);
      }
    });

    test('Medium puzzle equations are correct across levels 1-20', () {
      for (int lvl = 1; lvl <= 20; lvl++) {
        final puzzle = PuzzleGenerator.getPuzzle(
          difficulty: PuzzleDifficulty.medium,
          levelNumber: lvl,
        );
        verifyPuzzleMath(puzzle);
      }
    });

    test('Hard & Expert puzzle equations are correct across levels 1-20', () {
      for (int lvl = 1; lvl <= 20; lvl++) {
        final puzzleHard = PuzzleGenerator.getPuzzle(
          difficulty: PuzzleDifficulty.hard,
          levelNumber: lvl,
        );
        verifyPuzzleMath(puzzleHard);

        final puzzleExpert = PuzzleGenerator.getPuzzle(
          difficulty: PuzzleDifficulty.expert,
          levelNumber: lvl,
        );
        verifyPuzzleMath(puzzleExpert);
      }
    });

    test('Daily challenge equations are correct for any day of month', () {
      for (int day = 1; day <= 31; day++) {
        final puzzle = PuzzleGenerator.getDailyPuzzle(DateTime(2026, 11, day));
        verifyPuzzleMath(puzzle);
      }
    });
  });
}
