import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';

class LevelSelectorDialog extends StatelessWidget {
  final GameController controller;

  const LevelSelectorDialog({super.key, required this.controller});

  static void show(BuildContext context, GameController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LevelSelectorDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;
    final diff = controller.difficulty;
    final highestUnlocked = controller.getHighestLevelUnlocked(diff);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: theme.boardBorderColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Handle
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: theme.secondaryTextColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(diff.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Text(
                      '${diff.labelTr} - Seviyeler',
                      style: theme.font(
                        color: theme.primaryTextColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: theme.secondaryTextColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 30 Levels Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: 30, // 30 levels per difficulty
              itemBuilder: (context, index) {
                final level = index + 1;
                final isUnlocked = level <= highestUnlocked;
                final isCurrent = level == controller.currentLevel;
                final stars = controller.getLevelStars(diff, level);

                return InkWell(
                  onTap: isUnlocked
                      ? () {
                          controller.startNewGame(difficulty: diff, level: level);
                          Navigator.pop(context);
                        }
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? theme.accentColor.withValues(alpha: 0.25)
                          : (isUnlocked ? theme.backgroundSecondary : theme.backgroundSecondary.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCurrent
                            ? theme.accentColor
                            : (isUnlocked ? theme.boardBorderColor : Colors.transparent),
                        width: isCurrent ? 2.0 : 1.0,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: theme.accentColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isUnlocked)
                          Icon(Icons.lock_rounded, size: 20, color: theme.secondaryTextColor.withValues(alpha: 0.4))
                        else ...[
                          Text(
                            '$level',
                            style: theme.font(
                              color: isCurrent ? theme.accentColor : theme.primaryTextColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (sIdx) {
                              return Icon(
                                sIdx < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 10,
                                color: sIdx < stars ? Colors.amber : theme.secondaryTextColor.withValues(alpha: 0.4),
                              );
                            }),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
