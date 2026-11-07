import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../models/cell_model.dart';

class GridWidget extends StatelessWidget {
  final GameController controller;

  const GridWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final puzzle = controller.puzzle;
    final theme = controller.theme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamic cell padding based on grid size (11x11 uses tighter padding)
        final cellPadding = puzzle.cols >= 11
            ? 1.5
            : (puzzle.cols >= 9 ? 2.0 : (puzzle.cols >= 7 ? 2.8 : 3.5));
        final boardPadding = puzzle.cols >= 11 ? 8.0 : (puzzle.cols >= 9 ? 10.0 : 12.0);

        final maxGridWidth = constraints.maxWidth - (boardPadding * 2);
        final maxGridHeight = constraints.maxHeight - (boardPadding * 2);

        final totalHorizontalPaddings = (puzzle.cols * cellPadding * 2);
        final totalVerticalPaddings = (puzzle.rows * cellPadding * 2);

        final cellSizeByWidth = (maxGridWidth - totalHorizontalPaddings) / puzzle.cols;
        final cellSizeByHeight = (maxGridHeight - totalVerticalPaddings) / puzzle.rows;

        // Take the smaller dimension to keep cells square and prevent overflow
        final rawCellSize = math.min(cellSizeByWidth, cellSizeByHeight);
        final cellSize = rawCellSize.clamp(18.0, 52.0);

        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.all(boardPadding),
              decoration: BoxDecoration(
                color: theme.boardBackgroundColor,
                borderRadius: BorderRadius.circular(puzzle.cols >= 9 ? 16 : 20),
                border: Border.all(
                  color: theme.boardBorderColor.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(puzzle.rows, (r) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(puzzle.cols, (c) {
                      final cell = puzzle.grid[r][c];
                      return Padding(
                        padding: EdgeInsets.all(cellPadding),
                        child: SizedBox(
                          width: cellSize,
                          height: cellSize,
                          child: _buildCell(context, cell, cellSize),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(BuildContext context, CellModel cell, double size) {
    switch (cell.type) {
      case CellType.empty:
        return const SizedBox.shrink();

      case CellType.operator:
        return _buildOperatorCell(cell, size);

      case CellType.equal:
        return _buildEqualCell(cell, size);

      case CellType.result:
        if (cell.isEditableNumber) {
          return _buildNumberCell(context, cell, size);
        }
        return _buildResultCell(cell, size);

      case CellType.number:
        return _buildNumberCell(context, cell, size);
    }
  }

  Widget _buildOperatorCell(CellModel cell, double size) {
    final theme = controller.theme;
    final hasBg = theme.operatorCellBg != Colors.transparent;
    final radius = (size * 0.22).clamp(4.0, 10.0);

    return Container(
      decoration: hasBg
          ? BoxDecoration(
              color: theme.operatorCellBg,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: theme.fixedCellBorder, width: 1.0),
            )
          : null,
      child: Center(
        child: Text(
          cell.operatorSymbol ?? '',
          style: theme.font(
            color: theme.operatorCellText,
            fontSize: (size * 0.48).clamp(10.0, 24.0),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildEqualCell(CellModel cell, double size) {
    final theme = controller.theme;
    final hasBg = theme.equalCellBg != Colors.transparent;
    final radius = (size * 0.22).clamp(4.0, 10.0);

    return Container(
      decoration: hasBg
          ? BoxDecoration(
              color: theme.equalCellBg,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: theme.fixedCellBorder, width: 1.0),
            )
          : null,
      child: Center(
        child: Text(
          '=',
          style: theme.font(
            color: theme.equalCellText,
            fontSize: (size * 0.48).clamp(10.0, 24.0),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCell(CellModel cell, double size) {
    final theme = controller.theme;

    // Check if the equations related to this result are satisfied
    bool isSatisfied = false;
    for (final eq in controller.puzzle.equations) {
      if (eq.resultCoord.$1 == cell.row && eq.resultCoord.$2 == cell.col) {
        if (eq.isSatisfied(controller.puzzle.grid)) {
          isSatisfied = true;
          break;
        }
      }
    }

    final radius = (size * 0.22).clamp(4.0, 10.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isSatisfied
            ? theme.satisfiedGlowColor.withValues(alpha: 0.25)
            : theme.resultCellBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isSatisfied ? theme.satisfiedGlowColor : theme.resultCellBorder,
          width: isSatisfied ? 2.0 : 1.2,
        ),
        boxShadow: isSatisfied
            ? [
                BoxShadow(
                  color: theme.satisfiedGlowColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          '${cell.resultValue ?? ''}',
          style: theme.font(
            color: isSatisfied ? theme.satisfiedGlowColor : theme.resultCellText,
            fontSize: (size * 0.42).clamp(9.0, 22.0),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberCell(BuildContext context, CellModel cell, double size) {
    // If editable, wrap in DragTarget to accept dropped number tiles
    if (cell.isEditableNumber) {
      return DragTarget<int>(
        onWillAcceptWithDetails: (details) => cell.isEditableNumber,
        onAcceptWithDetails: (details) {
          controller.placeNumberInCell(cell.row, cell.col, details.data);
        },
        builder: (context, candidateData, rejectedData) {
          final isHovered = candidateData.isNotEmpty;
          return _buildNumberCellContent(cell, size, isHovered: isHovered);
        },
      );
    }

    return _buildNumberCellContent(cell, size, isHovered: false);
  }

  Widget _buildNumberCellContent(
    CellModel cell,
    double size, {
    required bool isHovered,
  }) {
    final theme = controller.theme;
    final radius = (size * 0.22).clamp(4.0, 10.0);

    Color bg;
    Color border;
    double borderWidth = 1.2;
    Color textColor;
    String text = '';

    if (cell.isFixed) {
      // Clue given at start
      bg = theme.fixedCellBg;
      border = cell.isSelected ? theme.selectedCellBorder : theme.fixedCellBorder;
      borderWidth = cell.isSelected ? 2.0 : 1.2;
      textColor = theme.fixedCellText;
      text = '${cell.solutionValue}';
    } else {
      // Editable slot
      if (cell.userValue != null) {
        bg = cell.isError
            ? theme.errorColor.withValues(alpha: 0.25)
            : (isHovered
                ? theme.accentColor.withValues(alpha: 0.3)
                : theme.editableFilledCellBg);
        border = isHovered
            ? theme.accentColor
            : (cell.isError
                ? theme.errorColor
                : (cell.isSelected ? theme.selectedCellBorder : theme.editableFilledCellBorder));
        borderWidth = (isHovered || cell.isSelected || cell.isError) ? 2.2 : 1.5;
        textColor = cell.isError ? theme.errorColor : theme.editableFilledCellText;
        text = '${cell.userValue}';
      } else {
        // Empty editable slot
        bg = isHovered
            ? theme.accentColor.withValues(alpha: 0.35)
            : (cell.isSelected
                ? theme.selectedCellBg
                : (cell.isHighlighted ? theme.highlightedCellBg : theme.editableEmptyCellBg));
        border = isHovered
            ? theme.accentColor
            : (cell.isSelected
                ? theme.selectedCellBorder
                : theme.editableEmptyCellBorder.withValues(alpha: 0.6));
        borderWidth = (isHovered || cell.isSelected) ? 2.2 : 1.2;
        textColor = theme.primaryTextColor;
        text = '';
      }
    }

    return GestureDetector(
      onTap: () => controller.selectCell(cell.row, cell.col),
      onDoubleTap: () {
        if (cell.isEditableNumber && cell.userValue != null) {
          controller.selectCell(cell.row, cell.col);
          controller.eraseCurrentCell();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: border, width: borderWidth),
          boxShadow: (cell.isSelected || isHovered)
              ? [
                  BoxShadow(
                    color: (isHovered ? theme.accentColor : theme.accentColor).withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: theme.font(
              color: textColor,
              fontSize: (size * 0.44).clamp(10.0, 22.0),
              fontWeight: cell.isFixed ? FontWeight.w800 : FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
