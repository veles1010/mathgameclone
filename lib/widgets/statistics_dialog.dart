import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../models/crossmath_puzzle.dart';

class StatisticsDialog extends StatelessWidget {
  final GameController controller;

  const StatisticsDialog({super.key, required this.controller});

  static void show(BuildContext context, GameController controller) {
    showDialog(
      context: context,
      builder: (ctx) => StatisticsDialog(controller: controller),
    );
  }

  String _formatTime(int seconds) {
    if (seconds <= 0) return '--:--';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = controller.theme;
    final played = controller.totalGamesPlayed;
    final won = controller.totalGamesWon;
    final winRate = played > 0 ? ((won / played) * 100).toInt() : 0;

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
              const Text('📊', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                'İstatistikler',
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
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // General Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    theme: theme,
                    title: 'Oynanan',
                    value: '$played',
                    icon: Icons.sports_esports_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    theme: theme,
                    title: 'Kazanılan',
                    value: '$won',
                    icon: Icons.emoji_events_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard(
                    theme: theme,
                    title: 'Kazanma %',
                    value: '%$winRate',
                    icon: Icons.trending_up_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Best Times Header
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'En İyi Süreler (Rekorlar)',
                style: theme.font(
                  color: theme.primaryTextColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            _buildBestTimeRow(
              diff: PuzzleDifficulty.easy,
              time: _formatTime(controller.bestTimeEasy),
            ),
            _buildBestTimeRow(
              diff: PuzzleDifficulty.medium,
              time: _formatTime(controller.bestTimeMedium),
            ),
            _buildBestTimeRow(
              diff: PuzzleDifficulty.hard,
              time: _formatTime(controller.bestTimeHard),
            ),
            _buildBestTimeRow(
              diff: PuzzleDifficulty.expert,
              time: _formatTime(controller.bestTimeExpert),
            ),
          ],
        ),
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

  Widget _buildMetricCard({
    required dynamic theme,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.boardBorderColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: theme.accentColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.font(
              color: theme.primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            style: theme.font(
              color: theme.secondaryTextColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestTimeRow({
    required PuzzleDifficulty diff,
    required String time,
  }) {
    final theme = controller.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.backgroundColor.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(diff.icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  diff.labelTr,
                  style: theme.font(
                    color: theme.primaryTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 14, color: theme.secondaryTextColor),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: theme.font(
                    color: theme.accentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

