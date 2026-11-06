import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';

class VictoryDialog extends StatefulWidget {
  final GameController controller;

  const VictoryDialog({super.key, required this.controller});

  static void show(BuildContext context, GameController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => VictoryDialog(controller: controller),
    );
  }

  @override
  State<VictoryDialog> createState() => _VictoryDialogState();
}

class _VictoryDialogState extends State<VictoryDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.controller.theme;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        AlertDialog(
          backgroundColor: theme.backgroundSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: theme.accentColor, width: 2),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.accentColor, theme.accentColorSecondary],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.accentColor.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🏆', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: 12),

              // Star Rating Display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final filled = index < widget.controller.earnedStars;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_border_rounded,
                      color: filled ? Colors.amber : theme.secondaryTextColor.withValues(alpha: 0.4),
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),

              Text(
                'Tebrikler!',
                style: theme.font(
                  color: theme.primaryTextColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tüm denklemleri doğru çözdünüz!',
                textAlign: TextAlign.center,
                style: theme.font(
                  color: theme.secondaryTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),

              // Stats Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.backgroundColor.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.boardBorderColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.timer_outlined,
                      label: 'Süre',
                      value: _formatTime(widget.controller.secondsElapsed),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: theme.boardBorderColor.withValues(alpha: 0.4),
                    ),
                    _buildStatItem(
                      icon: Icons.favorite_border_rounded,
                      label: 'Hata',
                      value: '${widget.controller.mistakes} / ${widget.controller.relaxedMode ? "∞" : GameController.maxMistakes}',
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: theme.boardBorderColor.withValues(alpha: 0.4),
                    ),
                    _buildStatItem(
                      icon: Icons.stars_rounded,
                      label: 'Zorluk',
                      value: widget.controller.difficulty.labelTr,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: theme.secondaryTextColor.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.controller.restartCurrentLevel();
                      },
                      child: Text(
                        'Tekrar Oyna',
                        style: theme.font(
                          color: theme.primaryTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.controller.nextLevel();
                      },
                      child: Text(
                        'Sonraki Seviye',
                        style: theme.font(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: [
            theme.accentColor,
            theme.accentColorSecondary,
            theme.satisfiedGlowColor,
            Colors.amber,
            Colors.white,
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = widget.controller.theme;
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.accentColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.font(
            color: theme.primaryTextColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.font(
            color: theme.secondaryTextColor,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

