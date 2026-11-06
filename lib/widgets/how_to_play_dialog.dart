import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';

class HowToPlayDialog extends StatelessWidget {
  final GameController controller;

  const HowToPlayDialog({super.key, required this.controller});

  static void show(BuildContext context, GameController controller) {
    showDialog(
      context: context,
      builder: (ctx) => HowToPlayDialog(controller: controller),
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
        children: [
          const Text('🧩', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Text(
            'Nasıl Oynanır?',
            style: theme.font(
              color: theme.primaryTextColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRuleItem(
              icon: '➕',
              title: 'Çapraz Denklemler',
              description:
                  'Kelimeler yerine sayıların kesiştiği bir bulmaca! Hem yatay hem dikey denklemlerin sonuçları doğru olmalıdır.',
            ),
            const SizedBox(height: 14),
            _buildRuleItem(
              icon: '⚡',
              title: 'İşlem Önceliği (BODMAS)',
              description:
                  'Standart matematik kuralları geçerlidir: Çarpma (×) ve Bölme (÷), Toplama (+) ve Çıkarma (-) işlemlerinden önce yapılır.\nÖrnek: 2 + 3 × 4 = 14',
            ),
            const SizedBox(height: 14),
            _buildRuleItem(
              icon: '🔢',
              title: 'Sayıları Yerleştirin',
              description:
                  'Boş bir kareye dokunun, ardından alt paneldeki sayılardan birine dokunarak yerleştirin. Yanlış yerleştirmeleri silgi ile geri alabilirsiniz.',
            ),
            const SizedBox(height: 14),
            _buildRuleItem(
              icon: '💡',
              title: 'İpuçları & Modlar',
              description:
                  'Tıkandığınızda ipucu lambasına dokunarak doğru sayıyı öğrenebilirsiniz. İsterseniz ayarlardan Rahat Modu açarak limitsiz hata hakkıyla oynayabilirsiniz.',
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
            'Anladım, Başla!',
            style: theme.font(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem({
    required String icon,
    required String title,
    required String description,
  }) {
    final theme = controller.theme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.font(
                  color: theme.primaryTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.font(
                  color: theme.secondaryTextColor,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

