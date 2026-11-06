import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../widgets/difficulty_selector_dialog.dart';
import '../widgets/game_actions_bar.dart';
import '../widgets/game_header.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/grid_widget.dart';
import '../widgets/how_to_play_dialog.dart';
import '../widgets/level_selector_dialog.dart';
import '../widgets/number_rack.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/theme_selector_dialog.dart';
import '../widgets/victory_dialog.dart';

class GameScreen extends StatefulWidget {
  final GameController controller;

  const GameScreen({super.key, required this.controller});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _showingVictory = false;
  bool _showingGameOver = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleGameStateChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleGameStateChange);
    super.dispose();
  }

  void _handleGameStateChange() {
    if (!mounted) return;

    if (widget.controller.isWon && !_showingVictory) {
      _showingVictory = true;
      Future.microtask(() {
        if (!mounted) return;
        VictoryDialog.show(context, widget.controller);
        _showingVictory = false;
      });
    } else if (widget.controller.isGameOver && !_showingGameOver) {
      _showingGameOver = true;
      Future.microtask(() {
        if (!mounted) return;
        GameOverDialog.show(context, widget.controller);
        _showingGameOver = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final theme = widget.controller.theme;

        return Scaffold(
          backgroundColor: theme.backgroundColor,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: theme.backgroundGradient,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    // Top App Bar / Status
                    GameHeader(
                      controller: widget.controller,
                      onOpenThemes: () => ThemeSelectorDialog.show(context, widget.controller),
                      onOpenDifficulty: () => DifficultySelectorDialog.show(context, widget.controller),
                      onOpenLevels: () => LevelSelectorDialog.show(context, widget.controller),
                      onOpenSettings: () => SettingsDialog.show(context, widget.controller),
                      onOpenHelp: () => HowToPlayDialog.show(context, widget.controller),
                    ),

                    // Main Board Area
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Center(
                          child: GridWidget(controller: widget.controller),
                        ),
                      ),
                    ),

                    // Action buttons (Undo, Erase, Hint, Reset)
                    GameActionsBar(controller: widget.controller),

                    // Tile Tray (Number Rack)
                    NumberRack(controller: widget.controller),
                  ],
                ),

                // Paused Overlay
                if (widget.controller.isPaused)
                  Container(
                    color: Colors.black.withValues(alpha: 0.8),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.pause_circle_filled_rounded, size: 72, color: theme.accentColor),
                          const SizedBox(height: 16),
                          Text(
                            'Oyun Duraklatıldı',
                            style: theme.font(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.accentColor,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded, color: Colors.black),
                            label: Text(
                              'Devam Et',
                              style: theme.font(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () => widget.controller.togglePause(),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

