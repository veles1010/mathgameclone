import 'cell_model.dart';
import 'equation_model.dart';

enum PuzzleDifficulty {
  easy,
  medium,
  hard,
  expert;

  String get labelTr {
    switch (this) {
      case PuzzleDifficulty.easy:
        return 'Kolay';
      case PuzzleDifficulty.medium:
        return 'Orta';
      case PuzzleDifficulty.hard:
        return 'Zor';
      case PuzzleDifficulty.expert:
        return 'Uzman';
    }
  }

  String get icon {
    switch (this) {
      case PuzzleDifficulty.easy:
        return '🌱';
      case PuzzleDifficulty.medium:
        return '⚡';
      case PuzzleDifficulty.hard:
        return '🔥';
      case PuzzleDifficulty.expert:
        return '👑';
    }
  }
}

class CrossmathPuzzle {
  final String id;
  final String title;
  final PuzzleDifficulty difficulty;
  final int rows;
  final int cols;
  final List<List<CellModel>> grid;
  final List<EquationModel> equations;
  final List<int> initialNumbersToPlace; // Solvable tiles needed

  CrossmathPuzzle({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.rows,
    required this.cols,
    required this.grid,
    required this.equations,
    required this.initialNumbersToPlace,
  });

  /// Deep copy of the puzzle for a fresh game session
  CrossmathPuzzle copy() {
    final newGrid = List.generate(
      rows,
      (r) => List.generate(
        cols,
        (c) {
          final cell = grid[r][c];
          return CellModel(
            row: cell.row,
            col: cell.col,
            type: cell.type,
            solutionValue: cell.solutionValue,
            userValue: cell.userValue,
            isFixed: cell.isFixed,
            operatorSymbol: cell.operatorSymbol,
            resultValue: cell.resultValue,
            equationIds: List.from(cell.equationIds),
            isSelected: false,
            isHighlighted: false,
            isError: false,
          );
        },
      ),
    );

    return CrossmathPuzzle(
      id: id,
      title: title,
      difficulty: difficulty,
      rows: rows,
      cols: cols,
      grid: newGrid,
      equations: equations, // Equation definitions are immutable
      initialNumbersToPlace: List.from(initialNumbersToPlace),
    );
  }
}

