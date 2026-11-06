import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../theme/game_theme.dart';

class ThemeSelectorDialog extends StatelessWidget {
  final GameController controller;

  const ThemeSelectorDialog({super.key, required this.controller});

  static void show(BuildContext context, GameController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ThemeSelectorDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = controller.theme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      decoration: BoxDecoration(
        color: activeTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: activeTheme.boardBorderColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: activeTheme.secondaryTextColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🎨', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Text(
                      'Oyun Temaları',
                      style: activeTheme.font(
                        color: activeTheme.primaryTextColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: activeTheme.secondaryTextColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Crossmath deneyiminizi kişiselleştirin. Seçtiğiniz tema hemen uygulanır.',
                style: activeTheme.font(
                  color: activeTheme.secondaryTextColor,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: ThemeType.values.length,
              itemBuilder: (context, index) {
                final themeType = ThemeType.values[index];
                final themeData = CrossmathThemeData.getTheme(themeType);
                final isSelected = controller.currentThemeType == themeType;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      controller.setTheme(themeType);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: themeData.backgroundSecondary,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? themeData.accentColor
                              : themeData.boardBorderColor.withValues(alpha: 0.4),
                          width: isSelected ? 2.2 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: themeData.accentColor.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          // Theme Icon & Color Swatch
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  themeData.backgroundColor,
                                  themeData.backgroundSecondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: themeData.accentColor, width: 1.5),
                            ),
                            child: Center(
                              child: Text(
                                themeType.previewEmoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      themeType.displayName,
                                      style: themeData.font(
                                        color: themeData.primaryTextColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: themeData.accentColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'AKTİF',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  themeType.description,
                                  style: themeData.font(
                                    color: themeData.secondaryTextColor,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Mini Color Dots Swatch
                                Row(
                                  children: [
                                    _buildColorDot(themeData.accentColor),
                                    const SizedBox(width: 6),
                                    _buildColorDot(themeData.accentColorSecondary),
                                    const SizedBox(width: 6),
                                    _buildColorDot(themeData.satisfiedGlowColor),
                                    const SizedBox(width: 6),
                                    _buildColorDot(themeData.resultCellBg),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Selection Radio / Check
                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: isSelected
                                ? themeData.accentColor
                                : themeData.secondaryTextColor.withValues(alpha: 0.4),
                            size: 24,
                          ),
                        ],
                      ),
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

  Widget _buildColorDot(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
      ),
    );
  }
}

