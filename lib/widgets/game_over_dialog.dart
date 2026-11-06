import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';

class GameOverDialog extends StatelessWidget {
  final GameController controller;

  const GameOverDialog({super.key, required this.controller});

  static void show(BuildContext context, GameController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameOverDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;

    return AlertDialog(
      backgroundColor: theme.backgroundSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: theme.errorColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: theme.errorColor, width: 2),
            ),
            child: Center(
              child: Icon(Icons.heart_broken_rounded, color: theme.errorColor, size: 36),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Hata Limiti Aşıldı',
            style: theme.font(
              color: theme.primaryTextColor,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '3 hakkınız tükendi. Baştan deneyebilir veya sınırsız hakla oynamak için Rahat Mod\'a geçebilirsiniz.',
            textAlign: TextAlign.center,
            style: theme.font(
              color: theme.secondaryTextColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          // Buttons
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accentColor,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.pop(context);
              controller.restartCurrentLevel();
            },
            child: Text(
              'Tekrar Dene',
              style: theme.font(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),

          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: BorderSide(color: theme.satisfiedGlowColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              controller.toggleRelaxedMode();
              Navigator.pop(context);
              controller.restartCurrentLevel();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.spa_rounded, color: theme.satisfiedGlowColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Rahat Modda Oyna (Limitsiz)',
                  style: theme.font(
                    color: theme.satisfiedGlowColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

