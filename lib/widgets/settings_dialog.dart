import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import 'statistics_dialog.dart';
import 'theme_selector_dialog.dart';

class SettingsDialog extends StatelessWidget {
  final GameController controller;

  const SettingsDialog({super.key, required this.controller});

  static void show(BuildContext context, GameController controller) {
    showDialog(
      context: context,
      builder: (ctx) => SettingsDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;

    return AlertDialog(
      backgroundColor: theme.backgroundSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.boardBorderColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.all(20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('⚙️', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                'Ayarlar',
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Relaxed Mode Toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: theme.accentColor,
            title: Text(
              'Rahat Mod',
              style: theme.font(
                color: theme.primaryTextColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '3 hata limiti olmadan stresten uzak oynayın',
              style: theme.font(color: theme.secondaryTextColor, fontSize: 12),
            ),
            value: controller.relaxedMode,
            onChanged: (val) {
              controller.toggleRelaxedMode();
            },
          ),
          const Divider(),

          // Themes shortcut
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Text(controller.currentThemeType.previewEmoji, style: const TextStyle(fontSize: 22)),
            title: Text(
              'Temalar',
              style: theme.font(
                color: theme.primaryTextColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              controller.currentThemeType.displayName,
              style: theme.font(color: theme.accentColor, fontSize: 12),
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: theme.secondaryTextColor),
            onTap: () {
              Navigator.pop(context);
              ThemeSelectorDialog.show(context, controller);
            },
          ),
          const Divider(),

          // Statistics shortcut
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Text('📊', style: TextStyle(fontSize: 22)),
            title: Text(
              'İstatistikler',
              style: theme.font(
                color: theme.primaryTextColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Oynanan oyunlar ve rekor süreler',
              style: theme.font(color: theme.secondaryTextColor, fontSize: 12),
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: theme.secondaryTextColor),
            onTap: () {
              Navigator.pop(context);
              StatisticsDialog.show(context, controller);
            },
          ),
          const Divider(),

          // About Crossmath
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 20, color: theme.secondaryTextColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Crossmath Math Puzzle • Flutter Cross-Platform',
                    style: theme.font(
                      color: theme.secondaryTextColor,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.accentColor,
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Kapat',
            style: theme.font(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

