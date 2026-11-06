import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';

class GameHeader extends StatelessWidget {
  final GameController controller;
  final VoidCallback onOpenThemes;
  final VoidCallback onOpenDifficulty;
  final VoidCallback onOpenLevels;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenHelp;

  const GameHeader({
    super.key,
    required this.controller,
    required this.onOpenThemes,
    required this.onOpenDifficulty,
    required this.onOpenLevels,
    required this.onOpenSettings,
    required this.onOpenHelp,
  });

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.appBarColor,
        border: Border(
          bottom: BorderSide(color: theme.boardBorderColor.withValues(alpha: 0.4), width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top action buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Difficulty & Level Selector row
                Row(
                  children: [
                    // Difficulty selector
                    InkWell(
                      onTap: onOpenDifficulty,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.accentColor.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.difficulty.icon,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              controller.isDaily ? 'Günün Oyunu' : controller.difficulty.labelTr,
                              style: theme.font(
                                color: theme.primaryTextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: theme.primaryTextColor,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (!controller.isDaily) ...[
                      const SizedBox(width: 6),
                      // Level selector button (e.g. Lvl 1)
                      InkWell(
                        onTap: onOpenLevels,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.backgroundSecondary,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.boardBorderColor.withValues(alpha: 0.6)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Lvl ${controller.currentLevel}',
                                style: theme.font(
                                  color: theme.accentColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.grid_view_rounded,
                                size: 14,
                                color: theme.secondaryTextColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Right action buttons: Help, Theme switcher, Settings
                Row(
                  children: [
                    // Help button
                    IconButton(
                      icon: Icon(Icons.help_outline_rounded, color: theme.primaryTextColor),
                      tooltip: 'Nasıl Oynanır?',
                      onPressed: onOpenHelp,
                      visualDensity: VisualDensity.compact,
                    ),

                    // Theme switcher pill
                    InkWell(
                      onTap: onOpenThemes,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.accentColor.withValues(alpha: 0.25),
                              theme.accentColorSecondary.withValues(alpha: 0.25),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.accentColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              controller.currentThemeType.previewEmoji,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tema',
                              style: theme.font(
                                color: theme.primaryTextColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 4),

                    // Settings
                    IconButton(
                      icon: Icon(Icons.settings_outlined, color: theme.primaryTextColor),
                      tooltip: 'Ayarlar',
                      onPressed: onOpenSettings,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Secondary Stats Bar: Timer, Pause, Mistakes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Timer
                InkWell(
                  onTap: () => controller.togglePause(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.backgroundSecondary.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          controller.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                          size: 18,
                          color: theme.accentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatTime(controller.secondsElapsed),
                          style: theme.font(
                            color: theme.primaryTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Mistakes Counter or Relaxed Mode
                controller.relaxedMode
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.satisfiedGlowColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.spa_rounded, size: 16, color: theme.satisfiedGlowColor),
                            const SizedBox(width: 4),
                            Text(
                              'Rahat Mod',
                              style: theme.font(
                                color: theme.satisfiedGlowColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        children: [
                          Text(
                            'Hata: ',
                            style: theme.font(
                              color: theme.secondaryTextColor,
                              fontSize: 13,
                            ),
                          ),
                          ...List.generate(GameController.maxMistakes, (index) {
                            final isUsed = index < controller.mistakes;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Icon(
                                isUsed ? Icons.close_rounded : Icons.favorite_rounded,
                                size: 18,
                                color: isUsed ? theme.errorColor : const Color(0xFFEF4444),
                              ),
                            );
                          }),
                        ],
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

