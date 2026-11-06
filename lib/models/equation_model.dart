import 'cell_model.dart';
import '../services/math_evaluator.dart';

class EquationModel {
  final String id;
  final bool isHorizontal;
  final List<(int row, int col)> numberCoords;
  final List<String> operators;
  final (int row, int col) resultCoord;
  final int targetResult;

  EquationModel({
    required this.id,
    required this.isHorizontal,
    required this.numberCoords,
    required this.operators,
    required this.resultCoord,
    required this.targetResult,
  });

  /// Checks if all number cells in this equation are currently filled
  bool isComplete(List<List<CellModel>> grid) {
    for (final coord in numberCoords) {
      final cell = grid[coord.$1][coord.$2];
      if (cell.displayValue == null) {
        return false;
      }
    }
    return true;
  }

  /// Evaluates current values against targetResult using order of operations
  bool isSatisfied(List<List<CellModel>> grid) {
    final numbers = <int>[];
    for (final coord in numberCoords) {
      final cell = grid[coord.$1][coord.$2];
      final val = cell.displayValue;
      if (val == null) return false;
      numbers.add(val);
    }

    final evaluated = MathEvaluator.evaluate(
      numbers: numbers,
      operators: operators,
    );

    return evaluated == targetResult;
  }

  /// Returns current evaluated value if all cells filled, or null
  int? currentEvaluatedValue(List<List<CellModel>> grid) {
    final numbers = <int>[];
    for (final coord in numberCoords) {
      final cell = grid[coord.$1][coord.$2];
      final val = cell.displayValue;
      if (val == null) return null;
      numbers.add(val);
    }
    return MathEvaluator.evaluate(
      numbers: numbers,
      operators: operators,
    );
  }
}

