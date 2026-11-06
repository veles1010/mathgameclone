enum CellType {
  empty,
  number,
  operator,
  equal,
  result,
}

class CellModel {
  final int row;
  final int col;
  final CellType type;

  // Number cell properties
  final int? solutionValue;
  int? userValue;
  final bool isFixed; // Pre-filled clue

  // Operator / Equal / Result properties
  final String? operatorSymbol; // '+', '-', '×', '÷'
  final int? resultValue;

  // Equations this cell is part of (e.g. ["h_0", "v_1"])
  final List<String> equationIds;

  // UI state
  bool isSelected;
  bool isHighlighted;
  bool isError;

  CellModel({
    required this.row,
    required this.col,
    required this.type,
    this.solutionValue,
    this.userValue,
    this.isFixed = false,
    this.operatorSymbol,
    this.resultValue,
    List<String>? equationIds,
    this.isSelected = false,
    this.isHighlighted = false,
    this.isError = false,
  }) : equationIds = equationIds ?? [];

  /// Helper to check if this cell is an editable player slot
  bool get isEditableNumber => type == CellType.number && !isFixed;

  /// Helper to get the currently displayed number (fixed or user filled)
  int? get displayValue => isFixed ? solutionValue : userValue;

  /// Whether player has correctly solved this cell
  bool get isCorrect => isFixed || (userValue != null && userValue == solutionValue);

  CellModel copyWith({
    int? userValue,
    bool? isSelected,
    bool? isHighlighted,
    bool? isError,
  }) {
    final cell = CellModel(
      row: row,
      col: col,
      type: type,
      solutionValue: solutionValue,
      userValue: userValue ?? this.userValue,
      isFixed: isFixed,
      operatorSymbol: operatorSymbol,
      resultValue: resultValue,
      equationIds: List.from(equationIds),
      isSelected: isSelected ?? this.isSelected,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isError: isError ?? this.isError,
    );
    return cell;
  }
}

