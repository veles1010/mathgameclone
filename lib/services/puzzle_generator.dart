import 'dart:math';
import '../models/cell_model.dart';
import '../models/crossmath_puzzle.dart';
import '../models/equation_model.dart';
import 'math_evaluator.dart';

/// A 5-cell standard Crossmath equation: Number1 [op] Number2 [=] Result
class _EquationSpec {
  final String id;
  final bool isHorizontal;
  final (int, int) firstCoord;
  final (int, int) opCoord;
  final (int, int) secondCoord;
  final (int, int) equalCoord;
  final (int, int) resultCoord;

  _EquationSpec({
    required this.id,
    required this.isHorizontal,
    required this.firstCoord,
    required this.opCoord,
    required this.secondCoord,
    required this.equalCoord,
    required this.resultCoord,
  });

  /// Factory for horizontal equation of 5 cells: (r, c) .. (r, c+4)
  factory _EquationSpec.horizontal(String id, int r, int c) {
    return _EquationSpec(
      id: id,
      isHorizontal: true,
      firstCoord: (r, c),
      opCoord: (r, c + 1),
      secondCoord: (r, c + 2),
      equalCoord: (r, c + 3),
      resultCoord: (r, c + 4),
    );
  }

  /// Factory for vertical equation of 5 cells: (r, c) .. (r+4, c)
  factory _EquationSpec.vertical(String id, int r, int c) {
    return _EquationSpec(
      id: id,
      isHorizontal: false,
      firstCoord: (r, c),
      opCoord: (r + 1, c),
      secondCoord: (r + 2, c),
      equalCoord: (r + 3, c),
      resultCoord: (r + 4, c),
    );
  }
}

class _PuzzleBoard {
  final List<_EquationSpec> eqSpecs;
  final Map<String, String> eqOperators;
  final Map<(int, int), int> cellValues;

  const _PuzzleBoard({
    required this.eqSpecs,
    required this.eqOperators,
    required this.cellValues,
  });
}

class PuzzleGenerator {
  /// Gets a puzzle for a given difficulty and level index
  static CrossmathPuzzle getPuzzle({
    required PuzzleDifficulty difficulty,
    int levelNumber = 1,
    int? customSeed,
  }) {
    switch (difficulty) {
      case PuzzleDifficulty.easy:
        return _generateEasyPuzzle(levelNumber: levelNumber);
      case PuzzleDifficulty.medium:
        return _generateMediumPuzzle(levelNumber: levelNumber);
      case PuzzleDifficulty.hard:
        return _generateHardPuzzle(levelNumber: levelNumber);
      case PuzzleDifficulty.expert:
        return _generateExpertPuzzle(levelNumber: levelNumber);
    }
  }

  /// Daily Challenge puzzle
  static CrossmathPuzzle getDailyPuzzle(DateTime date) {
    final day = date.day;
    return _generateHardPuzzle(
      levelNumber: day,
      customTitle: 'Günün Bulmacası (${date.day}.${date.month}.${date.year})',
    );
  }

  // =========================================================================
  // EASY: 5x5 Crossword (Stage 1-5 style)
  // =========================================================================
  static CrossmathPuzzle _generateEasyPuzzle({required int levelNumber}) {
    final random = Random(100 + levelNumber);

    for (int attempt = 0; attempt < 100; attempt++) {
      final a = random.nextInt(6) + 1;
      final b = random.nextInt(6) + 1;
      final d = random.nextInt(6) + 1;
      final e = random.nextInt(6) + 1;

      final ops = ['+', '-'];
      final opH1 = ops[random.nextInt(ops.length)];
      final opV1 = ops[random.nextInt(ops.length)];
      final opH2 = ops[random.nextInt(ops.length)];
      final opV2 = ops[random.nextInt(ops.length)];

      final c = MathEvaluator.evaluate(numbers: [a, b], operators: [opH1]);
      final g = MathEvaluator.evaluate(numbers: [a, d], operators: [opV1]);
      final f = MathEvaluator.evaluate(numbers: [d, e], operators: [opH2]);
      final h = MathEvaluator.evaluate(numbers: [b, e], operators: [opV2]);

      if (c == null || c < 1 || g == null || g < 1 || f == null || f < 1 || h == null || h < 1) {
        continue;
      }

      final values = {
        (0, 0): a, (0, 2): b, (0, 4): c,
        (2, 0): d, (2, 2): e, (2, 4): f,
        (4, 0): g, (4, 2): h,
      };

      final eqSpecs = [
        _EquationSpec.horizontal('h0', 0, 0),
        _EquationSpec.horizontal('h1', 2, 0),
        _EquationSpec.vertical('v0', 0, 0),
        _EquationSpec.vertical('v1', 0, 2),
      ];

      final eqOps = {'h0': opH1, 'h1': opH2, 'v0': opV1, 'v1': opV2};

      return _assemblePuzzle(
        id: 'easy_$levelNumber',
        title: 'Kolay - Seviye $levelNumber',
        difficulty: PuzzleDifficulty.easy,
        rows: 5,
        cols: 5,
        eqSpecs: eqSpecs,
        eqOperators: eqOps,
        cellValues: values,
        clueRatio: 0.5,
        random: random,
      );
    }

    return _fallbackEasyPuzzle(levelNumber);
  }

  // =========================================================================
  // MEDIUM: 11x11 Quad Islands (Matching Reference Images 1 & 4)
  // =========================================================================
  static final List<_PuzzleBoard> _mediumBoards = [
    // Board 1: Reference Image 1 Stage 9
    _PuzzleBoard(
      eqSpecs: [
        _EquationSpec.horizontal('tl_h0', 0, 0),
        _EquationSpec.vertical('tl_v0', 0, 0),
        _EquationSpec.vertical('tl_v1', 0, 4),
        _EquationSpec.horizontal('center_h0', 2, 2),
        _EquationSpec.vertical('bridge_l', 2, 2),
        _EquationSpec.horizontal('tl_h1', 4, 0),
        _EquationSpec.horizontal('tr_h0', 0, 6),
        _EquationSpec.vertical('tr_v0', 0, 6),
        _EquationSpec.vertical('tr_v1', 0, 10),
        _EquationSpec.vertical('bridge_r', 2, 8),
        _EquationSpec.horizontal('tr_h1', 4, 6),
        _EquationSpec.horizontal('bl_h0', 6, 0),
        _EquationSpec.vertical('bl_v0', 6, 0),
        _EquationSpec.horizontal('bl_h1', 8, 0),
        _EquationSpec.horizontal('bl_h2', 10, 0),
        _EquationSpec.horizontal('br_h0', 6, 6),
        _EquationSpec.horizontal('br_h1', 8, 6),
        _EquationSpec.vertical('br_v1', 6, 10),
        _EquationSpec.horizontal('br_h2', 10, 6),
      ],
      eqOperators: {
        'tl_h0': '-', 'tl_v0': '-', 'tl_v1': '-',
        'center_h0': '-', 'bridge_l': '+', 'tl_h1': '+',
        'tr_h0': '-', 'tr_v0': '×', 'tr_v1': '+',
        'bridge_r': '-', 'tr_h1': '-',
        'bl_h0': '+', 'bl_v0': '+', 'bl_h1': '+', 'bl_h2': '-',
        'br_h0': '÷', 'br_h1': '-', 'br_v1': '×', 'br_h2': '-',
      },
      cellValues: {
        (0, 0): 10, (0, 2): 3, (0, 4): 7,
        (2, 0): 9, (2, 2): 2, (2, 4): 1, (2, 6): 1,
        (4, 0): 1, (4, 2): 5, (4, 4): 6,
        (0, 6): 7, (0, 8): 3, (0, 10): 4,
        (2, 8): 3, (2, 10): 2,
        (4, 6): 7, (4, 8): 1, (4, 10): 6,
        (6, 0): 9, (6, 2): 7, (6, 4): 16,
        (8, 0): 2, (8, 2): 1, (8, 4): 3,
        (10, 0): 11, (10, 2): 4, (10, 4): 7,
        (6, 6): 10, (6, 8): 2, (6, 10): 5,
        (8, 6): 3, (8, 8): 2, (8, 10): 1,
        (10, 6): 8, (10, 8): 3, (10, 10): 5,
      },
    ),
    // Board 2: Reference Image 4
    _PuzzleBoard(
      eqSpecs: [
        _EquationSpec.horizontal('tl_h0', 0, 0),
        _EquationSpec.vertical('tl_v0', 0, 0),
        _EquationSpec.vertical('tl_v1', 0, 2),
        _EquationSpec.vertical('tl_v2', 0, 4),
        _EquationSpec.horizontal('center_h0', 2, 2),
        _EquationSpec.horizontal('tr_h0', 0, 6),
        _EquationSpec.vertical('tr_v0', 0, 6),
        _EquationSpec.vertical('tr_v1', 0, 10),
        _EquationSpec.horizontal('tr_h1', 4, 6),
        _EquationSpec.vertical('bridge_r', 4, 8),
        _EquationSpec.horizontal('bl_h0', 6, 0),
        _EquationSpec.vertical('bl_v0', 6, 0),
        _EquationSpec.horizontal('bl_h1', 8, 2),
        _EquationSpec.vertical('bl_v1', 6, 2),
        _EquationSpec.horizontal('bl_h2', 10, 0),
        _EquationSpec.horizontal('br_h0', 6, 6),
        _EquationSpec.vertical('br_v0', 6, 6),
        _EquationSpec.vertical('br_v1', 6, 10),
        _EquationSpec.horizontal('br_h2', 10, 6),
      ],
      eqOperators: {
        'tl_h0': '-', 'tl_v0': '+', 'tl_v1': '+', 'tl_v2': '+',
        'center_h0': '-',
        'tr_h0': '+', 'tr_v0': '-', 'tr_v1': '-', 'tr_h1': '+',
        'bridge_r': '-',
        'bl_h0': '+', 'bl_v0': '-', 'bl_h1': '×', 'bl_v1': '+', 'bl_h2': '+',
        'br_h0': '-', 'br_v0': '+', 'br_v1': '+', 'br_h2': '+',
      },
      cellValues: {
        (0, 0): 7, (0, 2): 1, (0, 4): 6,
        (2, 0): 3, (2, 2): 4, (2, 4): 2, (2, 6): 2,
        (4, 0): 10, (4, 2): 5, (4, 4): 8,
        (0, 6): 3, (0, 8): 4, (0, 10): 7,
        (2, 10): 1,
        (4, 6): 1, (4, 8): 5, (4, 10): 6,
        (6, 0): 10, (6, 2): 8, (6, 4): 18,
        (8, 0): 7, (8, 2): 2, (8, 4): 2, (8, 6): 4, (8, 8): 3, (8, 10): 8,
        (10, 0): 3, (10, 2): 10, (10, 4): 13,
        (6, 6): 8, (6, 8): 2, (6, 10): 6,
        (10, 6): 12, (10, 8): 2, (10, 10): 14,
      },
    ),
  ];

  static CrossmathPuzzle _generateMediumPuzzle({required int levelNumber}) {
    final board = _mediumBoards[(levelNumber - 1) % _mediumBoards.length];
    final random = Random(2000 + levelNumber);
    final clueRatio = (0.48 - ((levelNumber % 10) * 0.015)).clamp(0.28, 0.48);

    return _assemblePuzzle(
      id: 'medium_$levelNumber',
      title: 'Orta - Seviye $levelNumber',
      difficulty: PuzzleDifficulty.medium,
      rows: 11,
      cols: 11,
      eqSpecs: board.eqSpecs,
      eqOperators: board.eqOperators,
      cellValues: board.cellValues,
      clueRatio: clueRatio,
      random: random,
    );
  }

  // =========================================================================
  // HARD & EXPERT: 11x11 Master Quad Islands (Matching Reference Image 2)
  // =========================================================================
  static final List<_PuzzleBoard> _expertBoards = [
    // Board 1: Reference Image 2
    _PuzzleBoard(
      eqSpecs: [
        _EquationSpec.horizontal('tl_h1', 0, 0),
        _EquationSpec.vertical('tl_v1', 0, 0),
        _EquationSpec.horizontal('tl_h2', 2, 0),
        _EquationSpec.horizontal('tl_h3', 4, 0),
        _EquationSpec.vertical('tl_v2', 0, 4),
        _EquationSpec.horizontal('tr_h1', 0, 6),
        _EquationSpec.horizontal('tr_h2', 2, 6),
        _EquationSpec.vertical('tr_v1', 0, 8),
        _EquationSpec.vertical('tr_v2', 0, 10),
        _EquationSpec.horizontal('tr_h3', 4, 6),
        _EquationSpec.vertical('bridge_left', 4, 2),
        _EquationSpec.vertical('bridge_right', 4, 6),
        _EquationSpec.horizontal('bl_h1', 6, 0),
        _EquationSpec.vertical('bl_v1', 6, 0),
        _EquationSpec.horizontal('bl_h2', 8, 0),
        _EquationSpec.vertical('bl_v2', 6, 4),
        _EquationSpec.horizontal('br_h1', 6, 6),
        _EquationSpec.horizontal('br_h2', 8, 6),
        _EquationSpec.vertical('br_v1', 6, 8),
        _EquationSpec.vertical('br_v2', 6, 10),
        _EquationSpec.horizontal('bottom_bridge', 10, 4),
      ],
      eqOperators: {
        'tl_h1': '+', 'tl_v1': '+', 'tl_h2': '-', 'tl_h3': '+', 'tl_v2': '×',
        'tr_h1': '-', 'tr_h2': '+', 'tr_v1': '÷', 'tr_v2': '÷', 'tr_h3': '+',
        'bridge_left': '+', 'bridge_right': '-',
        'bl_h1': '+', 'bl_v1': '+', 'bl_h2': '-', 'bl_v2': '+',
        'br_h1': '+', 'br_h2': '+', 'br_v1': '-', 'br_v2': '-',
        'bottom_bridge': '÷',
      },
      cellValues: {
        (0, 0): 7, (0, 2): 4, (0, 4): 11,
        (2, 0): 23, (2, 2): 20, (2, 4): 3,
        (4, 0): 30, (4, 2): 3, (4, 4): 33,
        (0, 6): 40, (0, 8): 4, (0, 10): 36,
        (2, 6): 1, (2, 8): 2, (2, 10): 3,
        (4, 6): 10, (4, 8): 2, (4, 10): 12,
        (6, 0): 4, (6, 2): 3, (6, 4): 7,
        (8, 0): 24, (8, 2): 6, (8, 4): 18,
        (10, 0): 28, (10, 4): 25,
        (6, 6): 8, (6, 8): 16, (6, 10): 24,
        (8, 6): 2, (8, 8): 11, (8, 10): 13,
        (10, 6): 5, (10, 8): 5, (10, 10): 11,
      },
    ),
    // Board 2: Master Quad Island Variant
    _PuzzleBoard(
      eqSpecs: [
        _EquationSpec.horizontal('tl_h1', 0, 0),
        _EquationSpec.vertical('tl_v1', 0, 0),
        _EquationSpec.horizontal('tl_h2', 2, 0),
        _EquationSpec.horizontal('tl_h3', 4, 0),
        _EquationSpec.vertical('tl_v2', 0, 4),
        _EquationSpec.horizontal('tr_h1', 0, 6),
        _EquationSpec.horizontal('tr_h2', 2, 6),
        _EquationSpec.vertical('tr_v1', 0, 8),
        _EquationSpec.vertical('tr_v2', 0, 10),
        _EquationSpec.horizontal('tr_h3', 4, 6),
        _EquationSpec.vertical('bridge_left', 4, 2),
        _EquationSpec.vertical('bridge_right', 4, 6),
        _EquationSpec.horizontal('bl_h1', 6, 0),
        _EquationSpec.vertical('bl_v1', 6, 0),
        _EquationSpec.horizontal('bl_h2', 8, 0),
        _EquationSpec.vertical('bl_v2', 6, 4),
        _EquationSpec.horizontal('br_h1', 6, 6),
        _EquationSpec.horizontal('br_h2', 8, 6),
        _EquationSpec.vertical('br_v1', 6, 8),
        _EquationSpec.vertical('br_v2', 6, 10),
        _EquationSpec.horizontal('bottom_bridge', 10, 4),
      ],
      eqOperators: {
        'tl_h1': '+', 'tl_v1': '+', 'tl_h2': '-', 'tl_h3': '+', 'tl_v2': '×',
        'tr_h1': '-', 'tr_h2': '+', 'tr_v1': '÷', 'tr_v2': '÷', 'tr_h3': '+',
        'bridge_left': '+', 'bridge_right': '-',
        'bl_h1': '+', 'bl_v1': '+', 'bl_h2': '-', 'bl_v2': '+',
        'br_h1': '+', 'br_h2': '+', 'br_v1': '-', 'br_v2': '-',
        'bottom_bridge': '-',
      },
      cellValues: {
        (0, 0): 9, (0, 2): 5, (0, 4): 14,
        (2, 0): 15, (2, 2): 13, (2, 4): 2,
        (4, 0): 24, (4, 2): 4, (4, 4): 28,
        (0, 6): 30, (0, 8): 6, (0, 10): 24,
        (2, 6): 1, (2, 8): 3, (2, 10): 4,
        (4, 6): 4, (4, 8): 2, (4, 10): 6,
        (6, 0): 4, (6, 2): 4, (6, 4): 8,
        (8, 0): 20, (8, 2): 8, (8, 4): 12,
        (10, 0): 24, (10, 4): 20,
        (6, 6): 2, (6, 8): 14, (6, 10): 16,
        (8, 6): 2, (8, 8): 7, (8, 10): 9,
        (10, 6): 13, (10, 8): 7, (10, 10): 7,
      },
    ),
  ];

  static CrossmathPuzzle _generateHardPuzzle({required int levelNumber, String? customTitle}) {
    return _generateExpertOrHard(
      levelNumber: levelNumber,
      difficulty: PuzzleDifficulty.hard,
      clueRatio: 0.42,
      customTitle: customTitle ?? 'Zor - Seviye $levelNumber',
    );
  }

  static CrossmathPuzzle _generateExpertPuzzle({required int levelNumber}) {
    return _generateExpertOrHard(
      levelNumber: levelNumber,
      difficulty: PuzzleDifficulty.expert,
      clueRatio: 0.32,
      customTitle: 'Uzman - Seviye $levelNumber',
    );
  }

  static CrossmathPuzzle _generateExpertOrHard({
    required int levelNumber,
    required PuzzleDifficulty difficulty,
    required double clueRatio,
    required String customTitle,
  }) {
    final board = _expertBoards[(levelNumber - 1) % _expertBoards.length];
    final random = Random(4000 + levelNumber);
    final dynamicClueRatio = (clueRatio - ((levelNumber % 10) * 0.01)).clamp(0.20, 0.45);

    return _assemblePuzzle(
      id: '${difficulty.name}_$levelNumber',
      title: customTitle,
      difficulty: difficulty,
      rows: 11,
      cols: 11,
      eqSpecs: board.eqSpecs,
      eqOperators: board.eqOperators,
      cellValues: board.cellValues,
      clueRatio: dynamicClueRatio,
      random: random,
    );
  }

  // =========================================================================
  // PUZZLE ASSEMBLER
  // =========================================================================
  static CrossmathPuzzle _assemblePuzzle({
    required String id,
    required String title,
    required PuzzleDifficulty difficulty,
    required int rows,
    required int cols,
    required List<_EquationSpec> eqSpecs,
    required Map<String, String> eqOperators,
    required Map<(int, int), int> cellValues,
    required double clueRatio,
    required Random random,
  }) {
    // 1. Create grid with empty cells
    final grid = List.generate(
      rows,
      (r) => List.generate(
        cols,
        (c) => CellModel(row: r, col: c, type: CellType.empty),
      ),
    );

    // 2. Collect all distinct number coordinates (operands + results)
    final allNumCoords = cellValues.keys.toList();

    // 3. Decide which cells are fixed clues vs editable slots
    final totalNumbers = allNumCoords.length;
    final perm = List.generate(totalNumbers, (i) => i)..shuffle(random);
    final numClues = (totalNumbers * clueRatio).round().clamp(1, totalNumbers - 2);
    final clueIndices = perm.sublist(0, numClues);

    final neededNumbers = <int>[];

    for (int i = 0; i < totalNumbers; i++) {
      final coord = allNumCoords[i];
      final val = cellValues[coord]!;
      final isFixed = clueIndices.contains(i);

      if (!isFixed) {
        neededNumbers.add(val);
      }

      final relatedEqIds = eqSpecs
          .where((e) => e.firstCoord == coord || e.secondCoord == coord || e.resultCoord == coord)
          .map((e) => e.id)
          .toList();

      grid[coord.$1][coord.$2] = CellModel(
        row: coord.$1,
        col: coord.$2,
        type: CellType.number,
        solutionValue: val,
        isFixed: isFixed,
        userValue: isFixed ? val : null,
        equationIds: relatedEqIds,
      );
    }

    // 4. Fill operators and equals
    for (final eq in eqSpecs) {
      final op = eqOperators[eq.id]!;

      // Operator cell
      grid[eq.opCoord.$1][eq.opCoord.$2] = CellModel(
        row: eq.opCoord.$1,
        col: eq.opCoord.$2,
        type: CellType.operator,
        operatorSymbol: op,
      );

      // Equal cell
      grid[eq.equalCoord.$1][eq.equalCoord.$2] = CellModel(
        row: eq.equalCoord.$1,
        col: eq.equalCoord.$2,
        type: CellType.equal,
      );
    }

    // 5. Build EquationModel objects
    final equations = eqSpecs.map((eq) {
      final op = eqOperators[eq.id]!;
      final targetRes = cellValues[eq.resultCoord]!;

      return EquationModel(
        id: eq.id,
        isHorizontal: eq.isHorizontal,
        numberCoords: [eq.firstCoord, eq.secondCoord],
        operators: [op],
        resultCoord: eq.resultCoord,
        targetResult: targetRes,
      );
    }).toList();

    neededNumbers.sort();

    return CrossmathPuzzle(
      id: id,
      title: title,
      difficulty: difficulty,
      rows: rows,
      cols: cols,
      grid: grid,
      equations: equations,
      initialNumbersToPlace: neededNumbers,
    );
  }

  static CrossmathPuzzle _fallbackEasyPuzzle(int levelNumber) {
    const rows = 5;
    const cols = 5;
    final grid = List.generate(
      rows,
      (r) => List.generate(cols, (c) => CellModel(row: r, col: c, type: CellType.empty)),
    );

    grid[0][0] = CellModel(row: 0, col: 0, type: CellType.number, solutionValue: 6, isFixed: true, userValue: 6, equationIds: ['h0', 'v0']);
    grid[0][1] = CellModel(row: 0, col: 1, type: CellType.operator, operatorSymbol: '+');
    grid[0][2] = CellModel(row: 0, col: 2, type: CellType.number, solutionValue: 3, isFixed: false, equationIds: ['h0', 'v1']);
    grid[0][3] = CellModel(row: 0, col: 3, type: CellType.equal);
    grid[0][4] = CellModel(row: 0, col: 4, type: CellType.result, solutionValue: 9, isFixed: true, userValue: 9, equationIds: ['h0']);

    grid[1][0] = CellModel(row: 1, col: 0, type: CellType.operator, operatorSymbol: '×');
    grid[1][2] = CellModel(row: 1, col: 2, type: CellType.operator, operatorSymbol: '+');

    grid[2][0] = CellModel(row: 2, col: 0, type: CellType.number, solutionValue: 2, isFixed: false, equationIds: ['h1', 'v0']);
    grid[2][1] = CellModel(row: 2, col: 1, type: CellType.operator, operatorSymbol: '+');
    grid[2][2] = CellModel(row: 2, col: 2, type: CellType.number, solutionValue: 5, isFixed: true, userValue: 5, equationIds: ['h1', 'v1']);
    grid[2][3] = CellModel(row: 2, col: 3, type: CellType.equal);
    grid[2][4] = CellModel(row: 2, col: 4, type: CellType.result, solutionValue: 7, isFixed: true, userValue: 7, equationIds: ['h1']);

    grid[3][0] = CellModel(row: 3, col: 0, type: CellType.equal);
    grid[3][2] = CellModel(row: 3, col: 2, type: CellType.equal);

    grid[4][0] = CellModel(row: 4, col: 0, type: CellType.result, solutionValue: 12, isFixed: true, userValue: 12, equationIds: ['v0']);
    grid[4][2] = CellModel(row: 4, col: 2, type: CellType.result, solutionValue: 8, isFixed: true, userValue: 8, equationIds: ['v1']);

    final equations = [
      EquationModel(id: 'h0', isHorizontal: true, numberCoords: [(0, 0), (0, 2)], operators: ['+'], resultCoord: (0, 4), targetResult: 9),
      EquationModel(id: 'h1', isHorizontal: true, numberCoords: [(2, 0), (2, 2)], operators: ['+'], resultCoord: (2, 4), targetResult: 7),
      EquationModel(id: 'v0', isHorizontal: false, numberCoords: [(0, 0), (2, 0)], operators: ['×'], resultCoord: (4, 0), targetResult: 12),
      EquationModel(id: 'v1', isHorizontal: false, numberCoords: [(0, 2), (2, 2)], operators: ['+'], resultCoord: (4, 2), targetResult: 8),
    ];

    return CrossmathPuzzle(
      id: 'easy_fallback',
      title: 'Kolay - Seviye $levelNumber',
      difficulty: PuzzleDifficulty.easy,
      rows: rows,
      cols: cols,
      grid: grid,
      equations: equations,
      initialNumbersToPlace: [2, 3],
    );
  }
}
