import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cell_model.dart';
import '../models/crossmath_puzzle.dart';
import '../services/puzzle_generator.dart';
import '../theme/game_theme.dart';

class GameAction {
  final int row;
  final int col;
  final int? previousValue;
  final int? newValue;

  GameAction({
    required this.row,
    required this.col,
    required this.previousValue,
    required this.newValue,
  });
}

class GameController extends ChangeNotifier {
  // Theme state
  ThemeType _currentThemeType = ThemeType.classicCrossmath;
  late CrossmathThemeData _theme;

  // Puzzle & Game state
  late CrossmathPuzzle _puzzle;
  PuzzleDifficulty _difficulty = PuzzleDifficulty.easy;
  int _currentLevel = 1;
  bool _isDaily = false;
  DateTime? _currentDailyDate;

  (int, int)? _selectedCell;
  final List<GameAction> _undoHistory = [];
  final Map<int, int> _rackCounts = {}; // number -> available count

  // Status
  bool _isWon = false;
  bool _isGameOver = false;
  int _mistakes = 0;
  static const int maxMistakes = 3;
  bool _relaxedMode = false; // no mistake limit

  // Timer
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isPaused = false;

  // Hints
  int _hintsRemaining = 3;
  int _hintsUsedInLevel = 0;

  // Star rating for current level (1-3)
  int _earnedStars = 3;

  // Preferences
  late SharedPreferences _prefs;

  // Getters
  ThemeType get currentThemeType => _currentThemeType;
  CrossmathThemeData get theme => _theme;
  CrossmathPuzzle get puzzle => _puzzle;
  PuzzleDifficulty get difficulty => _difficulty;
  int get currentLevel => _currentLevel;
  bool get isDaily => _isDaily;
  (int, int)? get selectedCell => _selectedCell;
  Map<int, int> get rackCounts => _rackCounts;
  bool get canUndo => _undoHistory.isNotEmpty && !_isWon && !_isGameOver;
  bool get isWon => _isWon;
  bool get isGameOver => _isGameOver;
  int get mistakes => _mistakes;
  bool get relaxedMode => _relaxedMode;
  int get secondsElapsed => _secondsElapsed;
  bool get isPaused => _isPaused;
  int get hintsRemaining => _hintsRemaining;
  int get earnedStars => _earnedStars;

  // Stats getters
  int get totalGamesPlayed => _prefs.getInt('stats_games_played') ?? 0;
  int get totalGamesWon => _prefs.getInt('stats_games_won') ?? 0;
  int get bestTimeEasy => _prefs.getInt('stats_best_time_easy') ?? 0;
  int get bestTimeMedium => _prefs.getInt('stats_best_time_medium') ?? 0;
  int get bestTimeHard => _prefs.getInt('stats_best_time_hard') ?? 0;
  int get bestTimeExpert => _prefs.getInt('stats_best_time_expert') ?? 0;

  int getLevelStars(PuzzleDifficulty diff, int lvl) {
    return _prefs.getInt('stars_${diff.name}_$lvl') ?? 0;
  }

  int getHighestLevelUnlocked(PuzzleDifficulty diff) {
    return _prefs.getInt('highest_level_${diff.name}') ?? 1;
  }

  DateTime? get currentDailyDate => _currentDailyDate;

  bool isDailyCompleted(DateTime date) {
    final key = '${date.year}_${date.month}_${date.day}';
    return _prefs.getBool('daily_completed_$key') ?? false;
  }

  void markDailyCompleted(DateTime date) {
    final key = '${date.year}_${date.month}_${date.day}';
    _prefs.setBool('daily_completed_$key', true);
  }

  int getDailyStreak() {
    int streak = 0;
    DateTime check = DateTime.now();
    // If today is completed, start from today, else start from yesterday
    if (!isDailyCompleted(check)) {
      check = check.subtract(const Duration(days: 1));
    }
    while (isDailyCompleted(check)) {
      streak++;
      check = check.subtract(const Duration(days: 1));
      if (streak > 365) break;
    }
    return streak;
  }

  GameController() {
    _theme = CrossmathThemeData.getTheme(_currentThemeType);
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    // Load saved theme (default to classicCrossmath)
    final savedThemeIndex = _prefs.getInt('theme_type') ?? ThemeType.classicCrossmath.index;
    if (savedThemeIndex >= 0 && savedThemeIndex < ThemeType.values.length) {
      _currentThemeType = ThemeType.values[savedThemeIndex];
      _theme = CrossmathThemeData.getTheme(_currentThemeType);
    }

    _relaxedMode = _prefs.getBool('relaxed_mode') ?? false;
    _hintsRemaining = _prefs.getInt('hints_count') ?? 3;
    _currentLevel = _prefs.getInt('level_${_difficulty.name}') ?? 1;

    startNewGame(difficulty: _difficulty, level: _currentLevel);
  }

  void setTheme(ThemeType newTheme) {
    if (_currentThemeType == newTheme) return;
    _currentThemeType = newTheme;
    _theme = CrossmathThemeData.getTheme(newTheme);
    _prefs.setInt('theme_type', newTheme.index);
    notifyListeners();
  }

  void toggleRelaxedMode() {
    _relaxedMode = !_relaxedMode;
    _prefs.setBool('relaxed_mode', _relaxedMode);
    notifyListeners();
  }

  void startNewGame({
    required PuzzleDifficulty difficulty,
    int? level,
    bool isDaily = false,
    DateTime? dailyDate,
  }) {
    _timer?.cancel();
    _difficulty = difficulty;
    _isDaily = isDaily;
    _currentDailyDate = isDaily ? (dailyDate ?? DateTime.now()) : null;
    _currentLevel = level ?? (_prefs.getInt('level_${difficulty.name}') ?? 1);
    _isWon = false;
    _isGameOver = false;
    _mistakes = 0;
    _secondsElapsed = 0;
    _isPaused = false;
    _selectedCell = null;
    _undoHistory.clear();
    _hintsUsedInLevel = 0;
    _earnedStars = 3;

    // Increment games played
    final played = (_prefs.getInt('stats_games_played') ?? 0) + 1;
    _prefs.setInt('stats_games_played', played);

    if (isDaily) {
      _puzzle = PuzzleGenerator.getDailyPuzzle(_currentDailyDate!);
    } else {
      _puzzle = PuzzleGenerator.getPuzzle(
        difficulty: _difficulty,
        levelNumber: _currentLevel,
      );
    }

    // Initialize rack counts
    _rackCounts.clear();
    for (final num in _puzzle.initialNumbersToPlace) {
      _rackCounts[num] = (_rackCounts[num] ?? 0) + 1;
    }

    // Select the first empty editable cell automatically for convenience
    _autoSelectFirstEmptyCell();

    _startTimer();
    notifyListeners();
  }

  void _autoSelectFirstEmptyCell() {
    for (int r = 0; r < _puzzle.rows; r++) {
      for (int c = 0; c < _puzzle.cols; c++) {
        final cell = _puzzle.grid[r][c];
        if (cell.isEditableNumber && cell.userValue == null) {
          selectCell(r, c);
          return;
        }
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && !_isWon && !_isGameOver) {
        _secondsElapsed++;
        notifyListeners();
      }
    });
  }

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  void selectCell(int r, int c) {
    if (_isWon || _isGameOver) return;
    final cell = _puzzle.grid[r][c];

    // Clear previous selection and highlights
    for (final row in _puzzle.grid) {
      for (final it in row) {
        it.isSelected = false;
        it.isHighlighted = false;
      }
    }

    if (cell.type == CellType.empty) {
      _selectedCell = null;
      notifyListeners();
      return;
    }

    _selectedCell = (r, c);
    cell.isSelected = true;

    // Highlight row and column of the equation
    for (final eqId in cell.equationIds) {
      final eq = _puzzle.equations.firstWhere((e) => e.id == eqId);
      for (final coord in eq.numberCoords) {
        _puzzle.grid[coord.$1][coord.$2].isHighlighted = true;
      }
      _puzzle.grid[eq.resultCoord.$1][eq.resultCoord.$2].isHighlighted = true;
    }

    HapticFeedback.selectionClick();
    notifyListeners();
  }

  /// User taps a number from the rack
  void placeNumber(int number) {
    if (_selectedCell == null) return;
    final (r, c) = _selectedCell!;
    placeNumberInCell(r, c, number);
  }

  /// User drags or drops a number into a specific cell
  void placeNumberInCell(int r, int c, int number) {
    if (_isWon || _isGameOver || _isPaused) return;

    final cell = _puzzle.grid[r][c];
    if (!cell.isEditableNumber) return;

    // Check if number is available in rack
    final available = _rackCounts[number] ?? 0;
    if (available <= 0) return;

    selectCell(r, c);

    final oldValue = cell.userValue;

    // Return old value to rack if replacing
    if (oldValue != null) {
      _rackCounts[oldValue] = (_rackCounts[oldValue] ?? 0) + 1;
    }

    // Decrement new number from rack
    _rackCounts[number] = available - 1;
    cell.userValue = number;

    // Record undo
    _undoHistory.add(
      GameAction(row: r, col: c, previousValue: oldValue, newValue: number),
    );

    HapticFeedback.lightImpact();

    // Check equations affected
    _validateAffectedEquations(cell);

    // Check victory
    _checkWinCondition();

    // Automatically advance to the next empty cell if any
    _advanceToNextEmptyCell();

    notifyListeners();
  }

  void eraseCurrentCell() {
    if (_isWon || _isGameOver || _isPaused) return;
    if (_selectedCell == null) return;

    final (r, c) = _selectedCell!;
    final cell = _puzzle.grid[r][c];

    if (!cell.isEditableNumber || cell.userValue == null) return;

    final oldValue = cell.userValue!;
    _rackCounts[oldValue] = (_rackCounts[oldValue] ?? 0) + 1;
    cell.userValue = null;
    cell.isError = false;

    _undoHistory.add(
      GameAction(row: r, col: c, previousValue: oldValue, newValue: null),
    );

    // Re-check errors on affected equations
    for (final eqId in cell.equationIds) {
      final eq = _puzzle.equations.firstWhere((e) => e.id == eqId);
      for (final coord in [...eq.numberCoords, eq.resultCoord]) {
        _checkAndClearCellError(coord.$1, coord.$2);
      }
    }

    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void undo() {
    if (!canUndo) return;

    final lastAction = _undoHistory.removeLast();
    final cell = _puzzle.grid[lastAction.row][lastAction.col];

    // Revert rack
    if (lastAction.newValue != null) {
      _rackCounts[lastAction.newValue!] = (_rackCounts[lastAction.newValue!] ?? 0) + 1;
    }
    if (lastAction.previousValue != null) {
      _rackCounts[lastAction.previousValue!] = (_rackCounts[lastAction.previousValue!] ?? 1) - 1;
    }

    cell.userValue = lastAction.previousValue;
    selectCell(lastAction.row, lastAction.col);

    // Re-check errors on affected equations
    for (final eqId in cell.equationIds) {
      final eq = _puzzle.equations.firstWhere((e) => e.id == eqId);
      for (final coord in [...eq.numberCoords, eq.resultCoord]) {
        _checkAndClearCellError(coord.$1, coord.$2);
      }
    }

    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void useHint() {
    if (_isWon || _isGameOver || _isPaused) return;
    if (_hintsRemaining <= 0) return;

    // Target selected cell if editable and empty/wrong, or pick any unsolved editable cell
    CellModel? targetCell;
    if (_selectedCell != null) {
      final (r, c) = _selectedCell!;
      final cell = _puzzle.grid[r][c];
      if (cell.isEditableNumber && !cell.isCorrect) {
        targetCell = cell;
      }
    }

    if (targetCell == null) {
      for (final row in _puzzle.grid) {
        for (final cell in row) {
          if (cell.isEditableNumber && !cell.isCorrect) {
            targetCell = cell;
            break;
          }
        }
        if (targetCell != null) break;
      }
    }

    if (targetCell == null) return;

    _hintsRemaining--;
    _hintsUsedInLevel++;
    _prefs.setInt('hints_count', _hintsRemaining);

    // If cell had wrong value, return to rack
    if (targetCell.userValue != null) {
      _rackCounts[targetCell.userValue!] = (_rackCounts[targetCell.userValue!] ?? 0) + 1;
    }

    final correctVal = targetCell.solutionValue!;
    // Remove correctVal from rack
    final count = _rackCounts[correctVal] ?? 1;
    _rackCounts[correctVal] = count > 0 ? count - 1 : 0;

    targetCell.userValue = correctVal;
    targetCell.isError = false;

    selectCell(targetCell.row, targetCell.col);
    HapticFeedback.heavyImpact();

    _validateAffectedEquations(targetCell);
    _checkWinCondition();
    notifyListeners();
  }

  void _checkAndClearCellError(int r, int c) {
    final target = _puzzle.grid[r][c];
    if (!target.isEditableNumber || target.userValue == null) {
      target.isError = false;
      return;
    }
    bool stillError = false;
    for (final eqId in target.equationIds) {
      final eq = _puzzle.equations.firstWhere((e) => e.id == eqId);
      if (eq.isComplete(_puzzle.grid) && !eq.isSatisfied(_puzzle.grid)) {
        stillError = true;
        break;
      }
    }
    target.isError = stillError;
  }

  void _validateAffectedEquations(CellModel cell) {
    for (final eqId in cell.equationIds) {
      final eq = _puzzle.equations.firstWhere((e) => e.id == eqId);
      final allCoords = [...eq.numberCoords, eq.resultCoord];
      if (eq.isComplete(_puzzle.grid)) {
        if (!eq.isSatisfied(_puzzle.grid)) {
          // Equation is filled completely but evaluates wrong!
          cell.isError = true;
          if (!_relaxedMode) {
            _mistakes++;
            if (_mistakes >= maxMistakes) {
              _isGameOver = true;
              _timer?.cancel();
            }
          }
        } else {
          for (final coord in allCoords) {
            _checkAndClearCellError(coord.$1, coord.$2);
          }
        }
      } else {
        for (final coord in allCoords) {
          _checkAndClearCellError(coord.$1, coord.$2);
        }
      }
    }
  }

  void _checkWinCondition() {
    for (final eq in _puzzle.equations) {
      if (!eq.isSatisfied(_puzzle.grid)) {
        return;
      }
    }

    // Every single equation is satisfied! VICTORY!
    _isWon = true;
    _timer?.cancel();
    HapticFeedback.heavyImpact();

    // Calculate stars:
    // 3 stars: 0 mistakes, 0 hints
    // 2 stars: <= 1 mistake and <= 1 hint
    // 1 star: completed
    if (_mistakes == 0 && _hintsUsedInLevel == 0) {
      _earnedStars = 3;
    } else if (_mistakes <= 1 && _hintsUsedInLevel <= 1) {
      _earnedStars = 2;
    } else {
      _earnedStars = 1;
    }

    // Save stats
    final won = (_prefs.getInt('stats_games_won') ?? 0) + 1;
    _prefs.setInt('stats_games_won', won);

    final bestKey = 'stats_best_time_${_difficulty.name}';
    final currentBest = _prefs.getInt(bestKey) ?? 0;
    if (currentBest == 0 || _secondsElapsed < currentBest) {
      _prefs.setInt(bestKey, _secondsElapsed);
    }

    // Save level progression and stars
    if (!_isDaily) {
      final prevStars = _prefs.getInt('stars_${_difficulty.name}_$_currentLevel') ?? 0;
      if (_earnedStars > prevStars) {
        _prefs.setInt('stars_${_difficulty.name}_$_currentLevel', _earnedStars);
      }

      final highest = _prefs.getInt('highest_level_${_difficulty.name}') ?? 1;
      if (_currentLevel >= highest) {
        _prefs.setInt('highest_level_${_difficulty.name}', _currentLevel + 1);
      }

      final nextLevel = _currentLevel + 1;
      _prefs.setInt('level_${_difficulty.name}', nextLevel);
    }
  }

  void _advanceToNextEmptyCell() {
    for (int r = 0; r < _puzzle.rows; r++) {
      for (int c = 0; c < _puzzle.cols; c++) {
        final cell = _puzzle.grid[r][c];
        if (cell.isEditableNumber && cell.userValue == null) {
          selectCell(r, c);
          return;
        }
      }
    }
  }

  void nextLevel() {
    startNewGame(difficulty: _difficulty, level: _currentLevel + 1);
  }

  void restartCurrentLevel() {
    startNewGame(difficulty: _difficulty, level: _currentLevel, isDaily: _isDaily);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

