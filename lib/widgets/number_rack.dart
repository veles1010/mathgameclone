import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/game_controller.dart';

class NumberRack extends StatelessWidget {
  final GameController controller;

  const NumberRack({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;
    final rackCounts = controller.rackCounts;

    // Expand into individual tile list so duplicates appear as separate chips
    // (exactly as seen in the Crossmath screenshots!)
    final expandedTiles = <int>[];
    final sortedKeys = rackCounts.keys.toList()..sort();
    for (final num in sortedKeys) {
      final count = rackCounts[num] ?? 0;
      for (int i = 0; i < count; i++) {
        expandedTiles.add(num);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.rackBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: theme.boardBorderColor.withValues(alpha: 0.5), width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app_rounded, size: 13, color: theme.accentColor),
                const SizedBox(width: 6),
                Text(
                  'Sayıları sürükleyin veya dokunarak yerleştirin',
                  style: theme.font(
                    color: theme.secondaryTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Multi-row Wrap layout (exactly matches 3-row grid from screenshots)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 140),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: expandedTiles.map((number) {
                    final tileContent = _buildTileWidget(number: number);

                    return Draggable<int>(
                      data: number,
                      onDragStarted: () => HapticFeedback.lightImpact(),
                      feedback: Material(
                        type: MaterialType.transparency,
                        child: Transform.scale(
                          scale: 1.15,
                          child: _buildTileWidget(number: number, isDragging: true),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.25,
                        child: tileContent,
                      ),
                      child: GestureDetector(
                        onTap: () => controller.placeNumber(number),
                        child: tileContent,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTileWidget({
    required int number,
    bool isDragging = false,
  }) {
    final theme = controller.theme;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.rackTileBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDragging
              ? theme.accentColor
              : theme.rackTileBorder.withValues(alpha: 0.8),
          width: isDragging ? 2.2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDragging ? theme.accentColor : Colors.black).withValues(alpha: isDragging ? 0.4 : 0.15),
            blurRadius: isDragging ? 10 : 3,
            offset: Offset(0, isDragging ? 4 : 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$number',
          style: theme.font(
            color: isDragging ? theme.accentColor : theme.rackTileText,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
