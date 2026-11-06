import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../models/crossmath_puzzle.dart';

class DifficultySelectorDialog extends StatelessWidget {
  final GameController controller;

  const DifficultySelectorDialog({super.key, required this.controller});

  static void show(BuildContext context, GameController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DifficultySelectorDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: theme.boardBorderColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.secondaryTextColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Zorluk & Oyun Modu',
                  style: theme.font(
                    color: theme.primaryTextColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: theme.secondaryTextColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Daily Challenge Tile
            InkWell(
              onTap: () {
                controller.startNewGame(
                  difficulty: PuzzleDifficulty.hard,
                  isDaily: true,
                );
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.accentColor.withValues(alpha: 0.2),
                      theme.accentColorSecondary.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: controller.isDaily ? theme.accentColor : theme.boardBorderColor,
                    width: controller.isDaily ? 2.0 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    const Text('📅', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Günün Meydan Okuması',
                            style: theme.font(
                              color: theme.primaryTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Her gün özel yeni bir matematik bulmacası',
                            style: theme.font(
                              color: theme.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (controller.isDaily)
                      Icon(Icons.check_circle_rounded, color: theme.accentColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Standard Difficulty List
            ...PuzzleDifficulty.values.map((diff) {
              final isSelected = !controller.isDaily && controller.difficulty == diff;

              String subDesc = '';
              switch (diff) {
                case PuzzleDifficulty.easy:
                  subDesc = '5x5 ızgara (2x2 işlem), temel toplama ve çıkarma';
                  break;
                case PuzzleDifficulty.medium:
                  subDesc = '7x7 ızgara (3x3 işlem), çarpma ve dengeli bulmacalar';
                  break;
                case PuzzleDifficulty.hard:
                  subDesc = '9x9 ızgara (4x4 işlem), tüm 4 işlem ve işlem önceliği';
                  break;
                case PuzzleDifficulty.expert:
                  subDesc = '11x11 ızgara (5x5 işlem), usta matematikçiler için 25 sayılı dev bulmaca';
                  break;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () {
                    controller.startNewGame(difficulty: diff, isDaily: false);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.backgroundSecondary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? theme.accentColor : theme.boardBorderColor.withValues(alpha: 0.5),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(diff.icon, style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                diff.labelTr,
                                style: theme.font(
                                  color: theme.primaryTextColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                subDesc,
                                style: theme.font(
                                  color: theme.secondaryTextColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: theme.accentColor),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

