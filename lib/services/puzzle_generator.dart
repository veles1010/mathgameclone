import 'dart:math';
import '../models/cell_model.dart';
import '../models/crossmath_puzzle.dart';
import '../models/equation_model.dart';
import 'math_evaluator.dart';

/// Defines an equation structure within a pattern template
class _EquationDef {
  final String id;
  final bool isHorizontal;
  final List<(int, int)> numberCoords;
  final List<(int, int)> operatorCoords;
  final (int, int) equalCoord;
  final (int, int) resultCoord;

  _EquationDef({
    required this.id,
    required this.isHorizontal,
    required this.numberCoords,
    required this.operatorCoords,
    required this.equalCoord,
    required this.resultCoord,
  });
}

/// A crossword pattern template with arbitrary sparse cell layout
class _PatternTemplate {
  final String name;
  final int rows;
  final int cols;
  final List<_EquationDef> equations;

  _PatternTemplate({
    required this.name,
    required this.rows,
    required this.cols,
    required this.equations,
  });
}

class PuzzleGenerator {
  /// Gets a puzzle for a given difficulty and level index
  static CrossmathPuzzle getPuzzle({
    required PuzzleDifficulty difficulty,
    int levelNumber = 1,
    int? customSeed,
  }) {
    final seed = customSeed ?? (difficulty.index * 1000 + levelNumber);
    final random = Random(seed);

    switch (difficulty) {
      case PuzzleDifficulty.easy:
        return _generatePatternOrGrid(
          difficulty: difficulty,
          levelNumber: levelNumber,
          random: random,
          patternTemplates: _getEasyTemplates(),
          allowedOps: ['+', '-'],
          clueRatio: 0.50, // 50% clues given
          maxNum: 10,
          customTitle: 'Kolay - Seviye $levelNumber',
        );

      case PuzzleDifficulty.medium:
        return _generatePatternOrGrid(
          difficulty: difficulty,
          levelNumber: levelNumber,
          random: random,
          patternTemplates: _getMediumTemplates(),
          allowedOps: ['+', '-', '×'],
          clueRatio: 0.45,
          maxNum: 12,
          customTitle: 'Orta - Seviye $levelNumber',
        );

      case PuzzleDifficulty.hard:
        return _generatePatternOrGrid(
          difficulty: difficulty,
          levelNumber: levelNumber,
          random: random,
          patternTemplates: _getHardTemplates(),
          allowedOps: ['+', '-', '×', '÷'],
          clueRatio: 0.40,
          maxNum: 15,
          customTitle: 'Zor - Seviye $levelNumber',
        );

      case PuzzleDifficulty.expert:
        return _generatePatternOrGrid(
          difficulty: difficulty,
          levelNumber: levelNumber,
          random: random,
          patternTemplates: _getExpertTemplates(),
          allowedOps: ['+', '-', '×', '÷'],
          clueRatio: 0.35,
          maxNum: 18,
          customTitle: 'Uzman - Seviye $levelNumber',
        );
    }
  }

  /// Daily Challenge puzzle seeded by day
  static CrossmathPuzzle getDailyPuzzle(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = Random(seed);
    return _generatePatternOrGrid(
      difficulty: PuzzleDifficulty.hard,
      levelNumber: date.day,
      random: random,
      patternTemplates: _getHardTemplates(),
      allowedOps: ['+', '-', '×', '÷'],
      clueRatio: 0.38,
      maxNum: 16,
      customTitle: 'Günün Bulmacası (${date.day}.${date.month}.${date.year})',
    );
  }

  /// Generates a puzzle using one of the sparse crossword pattern templates
  static CrossmathPuzzle _generatePatternOrGrid({
    required PuzzleDifficulty difficulty,
    required int levelNumber,
    required Random random,
    required List<_PatternTemplate> patternTemplates,
    required List<String> allowedOps,
    required double clueRatio,
    required int maxNum,
    required String customTitle,
  }) {
    // Pick a template based on levelNumber for predictable variety
    final template = patternTemplates[(levelNumber - 1) % patternTemplates.length];
    final rows = template.rows;
    final cols = template.cols;

    // Collect all unique number coordinates in the pattern
    final allNumberCoords = <(int, int)>{};
    for (final eq in template.equations) {
      allNumberCoords.addAll(eq.numberCoords);
    }
    final numberCoordsList = allNumberCoords.toList();

    for (int attempt = 0; attempt < 250; attempt++) {
      // 1. Assign random numbers to each distinct cell
      final cellValues = <(int, int), int>{};
      for (final coord in numberCoordsList) {
        cellValues[coord] = random.nextInt(maxNum) + 1;
      }

      // 2. Pick operators and evaluate each equation
      final eqOperators = <String, List<String>>{};
      final eqResults = <String, int>{};
      bool valid = true;

      for (final eq in template.equations) {
        final nums = [for (final c in eq.numberCoords) cellValues[c]!];
        final ops = _pickSafeOperators(numbers: nums, allowedOps: allowedOps, random: random);

        final result = MathEvaluator.evaluate(numbers: nums, operators: ops);
        if (result == null || result < 1 || result > 120) {
          valid = false;
          break;
        }

        eqOperators[eq.id] = ops;
        eqResults[eq.id] = result;
      }

      if (!valid) continue;

      // 3. Build the grid
      final grid = List.generate(
        rows,
        (r) => List.generate(
          cols,
          (c) => CellModel(row: r, col: c, type: CellType.empty),
        ),
      );

      // Determine which number cells are fixed clues vs editable slots
      final totalNumbers = numberCoordsList.length;
      final perm = List.generate(totalNumbers, (i) => i)..shuffle(random);
      final numClues = (totalNumbers * clueRatio).round().clamp(1, totalNumbers - 2);
      final clueIndices = perm.sublist(0, numClues);

      final neededNumbers = <int>[];

      for (int i = 0; i < totalNumbers; i++) {
        final coord = numberCoordsList[i];
        final val = cellValues[coord]!;
        final isFixed = clueIndices.contains(i);

        if (!isFixed) {
          neededNumbers.add(val);
        }

        final relatedEqIds = template.equations
            .where((e) => e.numberCoords.contains(coord))
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

      // Fill operators, equals, and results for each equation
      for (final eq in template.equations) {
        final ops = eqOperators[eq.id]!;
        final res = eqResults[eq.id]!;

        for (int opIdx = 0; opIdx < eq.operatorCoords.length; opIdx++) {
          final opCoord = eq.operatorCoords[opIdx];
          grid[opCoord.$1][opCoord.$2] = CellModel(
            row: opCoord.$1,
            col: opCoord.$2,
            type: CellType.operator,
            operatorSymbol: ops[opIdx],
          );
        }

        grid[eq.equalCoord.$1][eq.equalCoord.$2] = CellModel(
          row: eq.equalCoord.$1,
          col: eq.equalCoord.$2,
          type: CellType.equal,
        );

        grid[eq.resultCoord.$1][eq.resultCoord.$2] = CellModel(
          row: eq.resultCoord.$1,
          col: eq.resultCoord.$2,
          type: CellType.result,
          resultValue: res,
        );
      }

      // Build EquationModel objects
      final equationModels = template.equations.map((eq) {
        return EquationModel(
          id: eq.id,
          isHorizontal: eq.isHorizontal,
          numberCoords: eq.numberCoords,
          operators: eqOperators[eq.id]!,
          resultCoord: eq.resultCoord,
          targetResult: eqResults[eq.id]!,
        );
      }).toList();

      neededNumbers.sort();

      return CrossmathPuzzle(
        id: '${difficulty.name}_$levelNumber',
        title: customTitle,
        difficulty: difficulty,
        rows: rows,
        cols: cols,
        grid: grid,
        equations: equationModels,
        initialNumbersToPlace: neededNumbers,
      );
    }

    // High safety fallback
    return _fallbackEasyPuzzle(levelNumber);
  }

  /// Picks operators that have high probability of producing clean integer results
  static List<String> _pickSafeOperators({
    required List<int> numbers,
    required List<String> allowedOps,
    required Random random,
  }) {
    final opsCount = numbers.length - 1;
    final chosen = <String>[];
    int mulCount = 0;

    for (int i = 0; i < opsCount; i++) {
      final left = numbers[i];
      final right = numbers[i + 1];

      final candidates = <String>[];
      if (allowedOps.contains('+')) candidates.add('+');
      if (allowedOps.contains('-')) candidates.add('-');

      if (allowedOps.contains('×') && mulCount < 1) {
        candidates.add('×');
      }

      if (allowedOps.contains('÷') && right > 1 && left % right == 0) {
        candidates.add('÷');
      }

      final op = candidates[random.nextInt(candidates.length)];
      if (op == '×') mulCount++;
      chosen.add(op);
    }

    return chosen;
  }

  // ==========================================
  // CROSSWORD PATTERN TEMPLATES
  // ==========================================

  /// Easy Templates (5x5, 7x5 open crossword)
  static List<_PatternTemplate> _getEasyTemplates() {
    return [
      // Easy Template 1: Classic 2x2 intersecting cross (5x5)
      _PatternTemplate(
        name: 'Kolay Çapraz',
        rows: 5,
        cols: 5,
        equations: [
          _EquationDef(id: 'h0', isHorizontal: true, numberCoords: [(0, 0), (0, 2)], operatorCoords: [(0, 1)], equalCoord: (0, 3), resultCoord: (0, 4)),
          _EquationDef(id: 'h1', isHorizontal: true, numberCoords: [(2, 0), (2, 2)], operatorCoords: [(2, 1)], equalCoord: (2, 3), resultCoord: (2, 4)),
          _EquationDef(id: 'v0', isHorizontal: false, numberCoords: [(0, 0), (2, 0)], operatorCoords: [(1, 0)], equalCoord: (3, 0), resultCoord: (4, 0)),
          _EquationDef(id: 'v1', isHorizontal: false, numberCoords: [(0, 2), (2, 2)], operatorCoords: [(1, 2)], equalCoord: (3, 2), resultCoord: (4, 2)),
        ],
      ),

      // Easy Template 2: Staggered T-Shape (7x5) with open corner spaces
      _PatternTemplate(
        name: 'Kademeli T',
        rows: 5,
        cols: 7,
        equations: [
          _EquationDef(id: 'h0', isHorizontal: true, numberCoords: [(0, 2), (0, 4)], operatorCoords: [(0, 3)], equalCoord: (0, 5), resultCoord: (0, 6)),
          _EquationDef(id: 'h1', isHorizontal: true, numberCoords: [(2, 0), (2, 2)], operatorCoords: [(2, 1)], equalCoord: (2, 3), resultCoord: (2, 4)),
          _EquationDef(id: 'v0', isHorizontal: false, numberCoords: [(0, 2), (2, 2)], operatorCoords: [(1, 2)], equalCoord: (3, 2), resultCoord: (4, 2)),
          _EquationDef(id: 'v1', isHorizontal: false, numberCoords: [(0, 4), (2, 4)], operatorCoords: [(1, 4)], equalCoord: (3, 4), resultCoord: (4, 4)),
        ],
      ),
    ];
  }

  /// Medium Templates: Pinwheel & Staggered Bridge (9x9 with empty spaces!)
  static List<_PatternTemplate> _getMediumTemplates() {
    return [
      // Medium Template 1: Pinwheel / Open Corners (9x9)
      // The 4 corners are empty! Equations intersect around center
      _PatternTemplate(
        name: 'Fırıldak Çapraz',
        rows: 9,
        cols: 9,
        equations: [
          // Top horizontal
          _EquationDef(id: 'h0', isHorizontal: true, numberCoords: [(2, 2), (2, 4), (2, 6)], operatorCoords: [(2, 3), (2, 5)], equalCoord: (2, 7), resultCoord: (2, 8)),
          // Center horizontal
          _EquationDef(id: 'h1', isHorizontal: true, numberCoords: [(4, 0), (4, 2), (4, 4)], operatorCoords: [(4, 1), (4, 3)], equalCoord: (4, 5), resultCoord: (4, 6)),
          // Bottom horizontal
          _EquationDef(id: 'h2', isHorizontal: true, numberCoords: [(6, 2), (6, 4), (6, 6)], operatorCoords: [(6, 3), (6, 5)], equalCoord: (6, 7), resultCoord: (6, 8)),
          // Left vertical
          _EquationDef(id: 'v0', isHorizontal: false, numberCoords: [(2, 2), (4, 2), (6, 2)], operatorCoords: [(3, 2), (5, 2)], equalCoord: (7, 2), resultCoord: (8, 2)),
          // Center vertical
          _EquationDef(id: 'v1', isHorizontal: false, numberCoords: [(0, 4), (2, 4), (4, 4)], operatorCoords: [(1, 4), (3, 4)], equalCoord: (5, 4), resultCoord: (6, 4)),
          // Right vertical
          _EquationDef(id: 'v2', isHorizontal: false, numberCoords: [(2, 6), (4, 6), (6, 6)], operatorCoords: [(3, 6), (5, 6)], equalCoord: (7, 6), resultCoord: (8, 6)),
        ],
      ),

      // Medium Template 2: Interlocking Dual Islands (9x9)
      _PatternTemplate(
        name: 'Çift Ada Köprüsü',
        rows: 9,
        cols: 9,
        equations: [
          // Top-Left block
          _EquationDef(id: 'h0', isHorizontal: true, numberCoords: [(0, 0), (0, 2)], operatorCoords: [(0, 1)], equalCoord: (0, 3), resultCoord: (0, 4)),
          _EquationDef(id: 'h1', isHorizontal: true, numberCoords: [(2, 0), (2, 2)], operatorCoords: [(2, 1)], equalCoord: (2, 3), resultCoord: (2, 4)),
          _EquationDef(id: 'v0', isHorizontal: false, numberCoords: [(0, 0), (2, 0)], operatorCoords: [(1, 0)], equalCoord: (3, 0), resultCoord: (4, 0)),
          _EquationDef(id: 'v1', isHorizontal: false, numberCoords: [(0, 2), (2, 2)], operatorCoords: [(1, 2)], equalCoord: (3, 2), resultCoord: (4, 2)),
          // Connecting Bridge at row 4
          _EquationDef(id: 'h_bridge', isHorizontal: true, numberCoords: [(4, 2), (4, 4), (4, 6)], operatorCoords: [(4, 3), (4, 5)], equalCoord: (4, 7), resultCoord: (4, 8)),
          // Bottom-Right block
          _EquationDef(id: 'h2', isHorizontal: true, numberCoords: [(6, 4), (6, 6)], operatorCoords: [(6, 5)], equalCoord: (6, 7), resultCoord: (6, 8)),
          _EquationDef(id: 'h3', isHorizontal: true, numberCoords: [(8, 4), (8, 6)], operatorCoords: [(8, 5)], equalCoord: (8, 7), resultCoord: (8, 8)),
          _EquationDef(id: 'v2', isHorizontal: false, numberCoords: [(4, 4), (6, 4)], operatorCoords: [(5, 4)], equalCoord: (7, 4), resultCoord: (8, 4)),
          _EquationDef(id: 'v3', isHorizontal: false, numberCoords: [(4, 6), (6, 6)], operatorCoords: [(5, 6)], equalCoord: (7, 6), resultCoord: (8, 6)),
        ],
      ),
    ];
  }

  /// Hard Templates: Quad Islands with Bridge (11x11 matching Image 1 & 2!)
  static List<_PatternTemplate> _getHardTemplates() {
    return [
      // Hard Template 1: Iconic Quad Islands with Open Center (11x11)
      // Exactly matches user's uploaded screenshot media_1793965608476_6fbf19db.jpg!
      _PatternTemplate(
        name: 'Dört Ada Çaprazı',
        rows: 11,
        cols: 11,
        equations: [
          // Top-Left Island
          _EquationDef(id: 'tl_h0', isHorizontal: true, numberCoords: [(0, 0), (0, 2)], operatorCoords: [(0, 1)], equalCoord: (0, 3), resultCoord: (0, 4)),
          _EquationDef(id: 'tl_v0', isHorizontal: false, numberCoords: [(0, 0), (2, 0)], operatorCoords: [(1, 0)], equalCoord: (3, 0), resultCoord: (4, 0)),
          _EquationDef(id: 'tl_v1', isHorizontal: false, numberCoords: [(0, 2), (2, 2)], operatorCoords: [(1, 2)], equalCoord: (3, 2), resultCoord: (4, 2)),
          // Top-Right Island
          _EquationDef(id: 'tr_h0', isHorizontal: true, numberCoords: [(0, 6), (0, 8)], operatorCoords: [(0, 7)], equalCoord: (0, 9), resultCoord: (0, 10)),
          _EquationDef(id: 'tr_v0', isHorizontal: false, numberCoords: [(0, 6), (2, 6)], operatorCoords: [(1, 6)], equalCoord: (3, 6), resultCoord: (4, 6)),
          _EquationDef(id: 'tr_v1', isHorizontal: false, numberCoords: [(0, 8), (2, 8)], operatorCoords: [(1, 8)], equalCoord: (3, 8), resultCoord: (4, 8)),
          // Top Bridge connecting Island 1 and 2
          _EquationDef(id: 'top_bridge', isHorizontal: true, numberCoords: [(2, 2), (2, 4), (2, 6)], operatorCoords: [(2, 3), (2, 5)], equalCoord: (2, 7), resultCoord: (2, 8)),
          // Mid-Left & Mid-Right connectors
          _EquationDef(id: 'mid_h0', isHorizontal: true, numberCoords: [(4, 2), (4, 4)], operatorCoords: [(4, 3)], equalCoord: (4, 5), resultCoord: (4, 6)),
          _EquationDef(id: 'mid_h1', isHorizontal: true, numberCoords: [(6, 6), (6, 8)], operatorCoords: [(6, 7)], equalCoord: (6, 9), resultCoord: (6, 10)),
          // Bottom-Left Island
          _EquationDef(id: 'bl_h0', isHorizontal: true, numberCoords: [(8, 2), (8, 4), (8, 6)], operatorCoords: [(8, 3), (8, 5)], equalCoord: (8, 7), resultCoord: (8, 8)),
          _EquationDef(id: 'bl_v0', isHorizontal: false, numberCoords: [(6, 0), (8, 0)], operatorCoords: [(7, 0)], equalCoord: (9, 0), resultCoord: (10, 0)),
          _EquationDef(id: 'bl_v1', isHorizontal: false, numberCoords: [(6, 2), (8, 2)], operatorCoords: [(7, 2)], equalCoord: (9, 2), resultCoord: (10, 2)),
          _EquationDef(id: 'bl_h1', isHorizontal: true, numberCoords: [(10, 0), (10, 2)], operatorCoords: [(10, 1)], equalCoord: (10, 3), resultCoord: (10, 4)),
          // Bottom-Right Island
          _EquationDef(id: 'br_v0', isHorizontal: false, numberCoords: [(6, 6), (8, 6)], operatorCoords: [(7, 6)], equalCoord: (9, 6), resultCoord: (10, 6)),
          _EquationDef(id: 'br_v1', isHorizontal: false, numberCoords: [(6, 8), (8, 8)], operatorCoords: [(7, 8)], equalCoord: (9, 8), resultCoord: (10, 8)),
          _EquationDef(id: 'br_h0', isHorizontal: true, numberCoords: [(10, 6), (10, 8)], operatorCoords: [(10, 7)], equalCoord: (10, 9), resultCoord: (10, 10)),
        ],
      ),

      // Hard Template 2: Open Hollow Ring (11x11)
      _PatternTemplate(
        name: 'Açık Halka',
        rows: 11,
        cols: 11,
        equations: [
          // Top border
          _EquationDef(id: 'th0', isHorizontal: true, numberCoords: [(0, 0), (0, 2), (0, 4)], operatorCoords: [(0, 1), (0, 3)], equalCoord: (0, 5), resultCoord: (0, 6)),
          _EquationDef(id: 'th1', isHorizontal: true, numberCoords: [(0, 6), (0, 8)], operatorCoords: [(0, 7)], equalCoord: (0, 9), resultCoord: (0, 10)),
          // Left border
          _EquationDef(id: 'lv0', isHorizontal: false, numberCoords: [(0, 0), (2, 0), (4, 0)], operatorCoords: [(1, 0), (3, 0)], equalCoord: (5, 0), resultCoord: (6, 0)),
          _EquationDef(id: 'lv1', isHorizontal: false, numberCoords: [(6, 0), (8, 0)], operatorCoords: [(7, 0)], equalCoord: (9, 0), resultCoord: (10, 0)),
          // Right border
          _EquationDef(id: 'rv0', isHorizontal: false, numberCoords: [(0, 10), (2, 10), (4, 10)], operatorCoords: [(1, 10), (3, 10)], equalCoord: (5, 10), resultCoord: (6, 10)),
          _EquationDef(id: 'rv1', isHorizontal: false, numberCoords: [(6, 10), (8, 10)], operatorCoords: [(7, 10)], equalCoord: (9, 10), resultCoord: (10, 10)),
          // Bottom border
          _EquationDef(id: 'bh0', isHorizontal: true, numberCoords: [(10, 0), (10, 2), (10, 4)], operatorCoords: [(10, 1), (10, 3)], equalCoord: (10, 5), resultCoord: (10, 6)),
          _EquationDef(id: 'bh1', isHorizontal: true, numberCoords: [(10, 6), (10, 8)], operatorCoords: [(10, 7)], equalCoord: (10, 9), resultCoord: (10, 10)),
          // Interior Crossbars
          _EquationDef(id: 'cross_h', isHorizontal: true, numberCoords: [(4, 2), (4, 4), (4, 6)], operatorCoords: [(4, 3), (4, 5)], equalCoord: (4, 7), resultCoord: (4, 8)),
          _EquationDef(id: 'cross_v', isHorizontal: false, numberCoords: [(2, 4), (4, 4), (6, 4)], operatorCoords: [(3, 4), (5, 4)], equalCoord: (7, 4), resultCoord: (8, 4)),
        ],
      ),
    ];
  }

  /// Expert Templates: Master Crossword (11x11 with multiple bridges & 3-number equations)
  static List<_PatternTemplate> _getExpertTemplates() {
    return [
      // Expert Template 1: Master Quad Maze (11x11)
      _PatternTemplate(
        name: 'Usta Labirenti',
        rows: 11,
        cols: 11,
        equations: [
          // Top-Left Island
          _EquationDef(id: 'e_tl_h0', isHorizontal: true, numberCoords: [(0, 0), (0, 2)], operatorCoords: [(0, 1)], equalCoord: (0, 3), resultCoord: (0, 4)),
          _EquationDef(id: 'e_tl_v0', isHorizontal: false, numberCoords: [(0, 0), (2, 0)], operatorCoords: [(1, 0)], equalCoord: (3, 0), resultCoord: (4, 0)),
          _EquationDef(id: 'e_tl_v1', isHorizontal: false, numberCoords: [(0, 2), (2, 2)], operatorCoords: [(1, 2)], equalCoord: (3, 2), resultCoord: (4, 2)),
          _EquationDef(id: 'e_tl_h1', isHorizontal: true, numberCoords: [(2, 0), (2, 2)], operatorCoords: [(2, 1)], equalCoord: (2, 3), resultCoord: (2, 4)),
          // Top-Right Island
          _EquationDef(id: 'e_tr_h0', isHorizontal: true, numberCoords: [(0, 6), (0, 8)], operatorCoords: [(0, 7)], equalCoord: (0, 9), resultCoord: (0, 10)),
          _EquationDef(id: 'e_tr_v0', isHorizontal: false, numberCoords: [(0, 8), (2, 8)], operatorCoords: [(1, 8)], equalCoord: (3, 8), resultCoord: (4, 8)),
          _EquationDef(id: 'e_tr_v1', isHorizontal: false, numberCoords: [(0, 6), (2, 6)], operatorCoords: [(1, 6)], equalCoord: (3, 6), resultCoord: (4, 6)),
          _EquationDef(id: 'e_tr_h1', isHorizontal: true, numberCoords: [(2, 6), (2, 8)], operatorCoords: [(2, 7)], equalCoord: (2, 9), resultCoord: (2, 10)),
          // Central Bridges (connecting the 4 islands!)
          _EquationDef(id: 'e_mid_h0', isHorizontal: true, numberCoords: [(4, 2), (4, 4), (4, 6)], operatorCoords: [(4, 3), (4, 5)], equalCoord: (4, 7), resultCoord: (4, 8)),
          _EquationDef(id: 'e_mid_v0', isHorizontal: false, numberCoords: [(2, 4), (4, 4), (6, 4)], operatorCoords: [(3, 4), (5, 4)], equalCoord: (7, 4), resultCoord: (8, 4)),
          _EquationDef(id: 'e_mid_h1', isHorizontal: true, numberCoords: [(6, 2), (6, 4), (6, 6)], operatorCoords: [(6, 3), (6, 5)], equalCoord: (6, 7), resultCoord: (6, 8)),
          // Bottom-Left Island
          _EquationDef(id: 'e_bl_h0', isHorizontal: true, numberCoords: [(8, 0), (8, 2)], operatorCoords: [(8, 1)], equalCoord: (8, 3), resultCoord: (8, 4)),
          _EquationDef(id: 'e_bl_v0', isHorizontal: false, numberCoords: [(6, 0), (8, 0)], operatorCoords: [(7, 0)], equalCoord: (9, 0), resultCoord: (10, 0)),
          _EquationDef(id: 'e_bl_v1', isHorizontal: false, numberCoords: [(6, 2), (8, 2)], operatorCoords: [(7, 2)], equalCoord: (9, 2), resultCoord: (10, 2)),
          _EquationDef(id: 'e_bl_h1', isHorizontal: true, numberCoords: [(10, 0), (10, 2)], operatorCoords: [(10, 1)], equalCoord: (10, 3), resultCoord: (10, 4)),
          // Bottom-Right Island
          _EquationDef(id: 'e_br_h0', isHorizontal: true, numberCoords: [(8, 6), (8, 8)], operatorCoords: [(8, 7)], equalCoord: (8, 9), resultCoord: (8, 10)),
          _EquationDef(id: 'e_br_v0', isHorizontal: false, numberCoords: [(6, 6), (8, 6)], operatorCoords: [(7, 6)], equalCoord: (9, 6), resultCoord: (10, 6)),
          _EquationDef(id: 'e_br_v1', isHorizontal: false, numberCoords: [(6, 8), (8, 8)], operatorCoords: [(7, 8)], equalCoord: (9, 8), resultCoord: (10, 8)),
          _EquationDef(id: 'e_br_h1', isHorizontal: true, numberCoords: [(10, 6), (10, 8)], operatorCoords: [(10, 7)], equalCoord: (10, 9), resultCoord: (10, 10)),
        ],
      ),
    ];
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
    grid[0][4] = CellModel(row: 0, col: 4, type: CellType.result, resultValue: 9);

    grid[1][0] = CellModel(row: 1, col: 0, type: CellType.operator, operatorSymbol: '×');
    grid[1][2] = CellModel(row: 1, col: 2, type: CellType.operator, operatorSymbol: '+');

    grid[2][0] = CellModel(row: 2, col: 0, type: CellType.number, solutionValue: 2, isFixed: false, equationIds: ['h1', 'v0']);
    grid[2][1] = CellModel(row: 2, col: 1, type: CellType.operator, operatorSymbol: '+');
    grid[2][2] = CellModel(row: 2, col: 2, type: CellType.number, solutionValue: 5, isFixed: true, userValue: 5, equationIds: ['h1', 'v1']);
    grid[2][3] = CellModel(row: 2, col: 3, type: CellType.equal);
    grid[2][4] = CellModel(row: 2, col: 4, type: CellType.result, resultValue: 7);

    grid[3][0] = CellModel(row: 3, col: 0, type: CellType.equal);
    grid[3][2] = CellModel(row: 3, col: 2, type: CellType.equal);

    grid[4][0] = CellModel(row: 4, col: 0, type: CellType.result, resultValue: 12);
    grid[4][2] = CellModel(row: 4, col: 2, type: CellType.result, resultValue: 8);

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
