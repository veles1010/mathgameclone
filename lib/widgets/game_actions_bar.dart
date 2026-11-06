import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';

class GameActionsBar extends StatelessWidget {
  final GameController controller;

  const GameActionsBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Undo button
          _buildActionButton(
            context: context,
            icon: Icons.undo_rounded,
            label: 'Geri Al',
            isEnabled: controller.canUndo,
            onTap: () => controller.undo(),
          ),

          // Erase button
          _buildActionButton(
            context: context,
            icon: Icons.backspace_outlined,
            label: 'Sil',
            isEnabled: controller.selectedCell != null &&
                controller.puzzle.grid[controller.selectedCell!.$1][controller.selectedCell!.$2].isEditableNumber &&
                controller.puzzle.grid[controller.selectedCell!.$1][controller.selectedCell!.$2].userValue != null,
            onTap: () => controller.eraseCurrentCell(),
          ),

          // Hint button
          _buildActionButton(
            context: context,
            icon: Icons.lightbulb_outline_rounded,
            label: 'İpucu',
            badge: '${controller.hintsRemaining}',
            isEnabled: controller.hintsRemaining > 0,
            onTap: () => controller.useHint(),
          ),

          // Restart button
          _buildActionButton(
            context: context,
            icon: Icons.refresh_rounded,
            label: 'Sıfırla',
            isEnabled: true,
            onTap: () => _confirmRestart(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isEnabled,
    required VoidCallback onTap,
    String? badge,
  }) {
    final theme = controller.theme;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isEnabled ? 1.0 : 0.35,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.backgroundSecondary.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isEnabled
                          ? theme.accentColor.withValues(alpha: 0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isEnabled ? theme.accentColor : theme.secondaryTextColor,
                    size: 22,
                  ),
                ),
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: theme.accentColorSecondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.font(
                color: isEnabled ? theme.primaryTextColor : theme.secondaryTextColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRestart(BuildContext context) {
    final theme = controller.theme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.backgroundSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Seviyeyi Sıfırla?',
          style: theme.font(
            color: theme.primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Bu seviyedeki ilerlemeniz sıfırlanacak. Baştan başlamak istiyor musunuz?',
          style: theme.font(color: theme.secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Vazgeç', style: theme.font(color: theme.secondaryTextColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              controller.restartCurrentLevel();
            },
            child: Text(
              'Sıfırla',
              style: theme.font(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

