import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ThemeType {
  classicCrossmath,
  cyberpunk,
  nordicWood,
  forestZen,
  synthwaveSunset,
  deepOcean,
  minimalObsidian;

  String get displayName {
    switch (this) {
      case ThemeType.classicCrossmath:
        return 'Klasik Crossmath';
      case ThemeType.cyberpunk:
        return 'Cyberpunk Neon';
      case ThemeType.nordicWood:
        return 'İskandinav Ahşap';
      case ThemeType.forestZen:
        return 'Zen Ormanı';
      case ThemeType.synthwaveSunset:
        return 'Retro Sunset';
      case ThemeType.deepOcean:
        return 'Derin Okyanus';
      case ThemeType.minimalObsidian:
        return 'Minimalist Obsidyen';
    }
  }

  String get description {
    switch (this) {
      case ThemeType.classicCrossmath:
        return 'Orijinal sarı karolar ve yeşil sayı havuzu';
      case ThemeType.cyberpunk:
        return 'Işıltılı neonlar ve fütüristik siber hatlar';
      case ThemeType.nordicWood:
        return 'Sıcak ahşap dokuları ve huzurlu doğal tonlar';
      case ThemeType.forestZen:
        return 'Dingin bambu yeşili ve meditatif atmosfer';
      case ThemeType.synthwaveSunset:
        return '80\'ler synthwave günbatımı ve retro gradyanlar';
      case ThemeType.deepOcean:
        return 'Okyanus derinlikleri ve biyolüminesans ışıltı';
      case ThemeType.minimalObsidian:
        return 'Sade, keskin ve modern koyu lüks tasarım';
    }
  }

  String get previewEmoji {
    switch (this) {
      case ThemeType.classicCrossmath:
        return '🟡';
      case ThemeType.cyberpunk:
        return '⚡';
      case ThemeType.nordicWood:
        return '🪵';
      case ThemeType.forestZen:
        return '🍃';
      case ThemeType.synthwaveSunset:
        return '🌇';
      case ThemeType.deepOcean:
        return '🌊';
      case ThemeType.minimalObsidian:
        return '💎';
    }
  }
}

class CrossmathThemeData {
  final ThemeType type;
  final bool isDark;

  // Background
  final Color backgroundColor;
  final Color backgroundSecondary;
  final List<Color> backgroundGradient;

  // Header & Controls
  final Color appBarColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color accentColor;
  final Color accentColorSecondary;

  // Board
  final Color boardBackgroundColor;
  final Color boardBorderColor;

  // Cells
  final Color fixedCellBg;
  final Color fixedCellText;
  final Color fixedCellBorder;

  final Color editableEmptyCellBg;
  final Color editableEmptyCellBorder;
  final Color editableFilledCellBg;
  final Color editableFilledCellText;
  final Color editableFilledCellBorder;

  final Color selectedCellBg;
  final Color selectedCellBorder;
  final Color highlightedCellBg;

  final Color operatorCellBg;
  final Color operatorCellText;
  final Color equalCellBg;
  final Color equalCellText;
  final Color resultCellBg;
  final Color resultCellText;
  final Color resultCellBorder;

  final Color satisfiedGlowColor;
  final Color errorColor;

  // Tile Rack / Number Bank
  final Color rackBg;
  final Color rackTileBg;
  final Color rackTileText;
  final Color rackTileBorder;
  final Color rackTileDisabledBg;

  // Typography
  final TextStyle Function({
    TextStyle? textStyle,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
  }) font;

  const CrossmathThemeData({
    required this.type,
    required this.isDark,
    required this.backgroundColor,
    required this.backgroundSecondary,
    required this.backgroundGradient,
    required this.appBarColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.accentColor,
    required this.accentColorSecondary,
    required this.boardBackgroundColor,
    required this.boardBorderColor,
    required this.fixedCellBg,
    required this.fixedCellText,
    required this.fixedCellBorder,
    required this.editableEmptyCellBg,
    required this.editableEmptyCellBorder,
    required this.editableFilledCellBg,
    required this.editableFilledCellText,
    required this.editableFilledCellBorder,
    required this.selectedCellBg,
    required this.selectedCellBorder,
    required this.highlightedCellBg,
    required this.operatorCellBg,
    required this.operatorCellText,
    required this.equalCellBg,
    required this.equalCellText,
    required this.resultCellBg,
    required this.resultCellText,
    required this.resultCellBorder,
    required this.satisfiedGlowColor,
    required this.errorColor,
    required this.rackBg,
    required this.rackTileBg,
    required this.rackTileText,
    required this.rackTileBorder,
    required this.rackTileDisabledBg,
    required this.font,
  });

  static CrossmathThemeData getTheme(ThemeType type) {
    switch (type) {
      case ThemeType.classicCrossmath:
        return CrossmathThemeData(
          type: type,
          isDark: true,
          backgroundColor: const Color(0xFF131722),
          backgroundSecondary: const Color(0xFF1A1F2E),
          backgroundGradient: const [Color(0xFF11141E), Color(0xFF181D2B)],
          appBarColor: const Color(0xFF1A1F2E),
          primaryTextColor: const Color(0xFFF8FAFC),
          secondaryTextColor: const Color(0xFF94A3B8),
          accentColor: const Color(0xFFE5BE64),
          accentColorSecondary: const Color(0xFF10B981),
          boardBackgroundColor: const Color(0xFF0F121A),
          boardBorderColor: const Color(0xFF262C3D),
          fixedCellBg: const Color(0xFFF3C759),
          fixedCellText: const Color(0xFF1C1917),
          fixedCellBorder: const Color(0xFFD9A736),
          editableEmptyCellBg: const Color(0xFF382F26),
          editableEmptyCellBorder: const Color(0xFF5E4F41),
          editableFilledCellBg: const Color(0xFFF8FAFC),
          editableFilledCellText: const Color(0xFF047857),
          editableFilledCellBorder: const Color(0xFF10B981),
          selectedCellBg: const Color(0xFF4D3F33),
          selectedCellBorder: const Color(0xFFF59E0B),
          highlightedCellBg: const Color(0x33F59E0B),
          operatorCellBg: const Color(0xFFF3C759),
          operatorCellText: const Color(0xFF1C1917),
          equalCellBg: const Color(0xFFF3C759),
          equalCellText: const Color(0xFF1C1917),
          resultCellBg: const Color(0xFFF3C759),
          resultCellText: const Color(0xFF1C1917),
          resultCellBorder: const Color(0xFFD9A736),
          satisfiedGlowColor: const Color(0xFF10B981),
          errorColor: const Color(0xFFEF4444),
          rackBg: const Color(0xFF181D2B),
          rackTileBg: const Color(0xFFE6F4EA),
          rackTileText: const Color(0xFF047857),
          rackTileBorder: const Color(0xFFA7D7B5),
          rackTileDisabledBg: const Color(0xFF232838),
          font: GoogleFonts.outfit,
        );

      case ThemeType.cyberpunk:
        return CrossmathThemeData(
          type: type,
          isDark: true,
          backgroundColor: const Color(0xFF090D16),
          backgroundSecondary: const Color(0xFF131B2E),
          backgroundGradient: const [Color(0xFF070A12), Color(0xFF0E1626)],
          appBarColor: const Color(0xFF0E1626),
          primaryTextColor: const Color(0xFFF1F5F9),
          secondaryTextColor: const Color(0xFF94A3B8),
          accentColor: const Color(0xFF00F0FF),
          accentColorSecondary: const Color(0xFFFF007F),
          boardBackgroundColor: const Color(0x33101A30),
          boardBorderColor: const Color(0xFF1E2D4A),
          fixedCellBg: const Color(0xFF182238),
          fixedCellText: const Color(0xFFE2E8F0),
          fixedCellBorder: const Color(0xFF2E4068),
          editableEmptyCellBg: const Color(0xFF0F172A),
          editableEmptyCellBorder: const Color(0xFF00F0FF),
          editableFilledCellBg: const Color(0xFF152A4A),
          editableFilledCellText: const Color(0xFF00F0FF),
          editableFilledCellBorder: const Color(0xFF00F0FF),
          selectedCellBg: const Color(0xFF1E3A8A),
          selectedCellBorder: const Color(0xFFFF007F),
          highlightedCellBg: const Color(0x3300F0FF),
          operatorCellBg: const Color(0xFF0F172A),
          operatorCellText: const Color(0xFFFF007F),
          equalCellBg: const Color(0xFF0F172A),
          equalCellText: const Color(0xFF94A3B8),
          resultCellBg: const Color(0xFF172554),
          resultCellText: const Color(0xFF38BDF8),
          resultCellBorder: const Color(0xFF1E40AF),
          satisfiedGlowColor: const Color(0xFF10B981),
          errorColor: const Color(0xFFEF4444),
          rackBg: const Color(0x660E1626),
          rackTileBg: const Color(0xFF1E293B),
          rackTileText: const Color(0xFF00F0FF),
          rackTileBorder: const Color(0xFF38BDF8),
          rackTileDisabledBg: const Color(0xFF0F172A),
          font: GoogleFonts.rajdhani,
        );

      case ThemeType.nordicWood:
        return CrossmathThemeData(
          type: type,
          isDark: false,
          backgroundColor: const Color(0xFFF5EFEB),
          backgroundSecondary: const Color(0xFFEADFCF),
          backgroundGradient: const [Color(0xFFFBF8F5), Color(0xFFEDE3D7)],
          appBarColor: const Color(0xFFEDE3D7),
          primaryTextColor: const Color(0xFF3D2E24),
          secondaryTextColor: const Color(0xFF7A685A),
          accentColor: const Color(0xFFB45309),
          accentColorSecondary: const Color(0xFF8B5E3C),
          boardBackgroundColor: const Color(0xFFE5D7C5),
          boardBorderColor: const Color(0xFFD4C1A9),
          fixedCellBg: const Color(0xFFDFCEB9),
          fixedCellText: const Color(0xFF2C1F16),
          fixedCellBorder: const Color(0xFFBFA990),
          editableEmptyCellBg: const Color(0xFFFAF6F0),
          editableEmptyCellBorder: const Color(0xFFB45309),
          editableFilledCellBg: const Color(0xFFFFFDF9),
          editableFilledCellText: const Color(0xFF8B4513),
          editableFilledCellBorder: const Color(0xFFB45309),
          selectedCellBg: const Color(0xFFFDE68A),
          selectedCellBorder: const Color(0xFFB45309),
          highlightedCellBg: const Color(0x33F59E0B),
          operatorCellBg: Colors.transparent,
          operatorCellText: const Color(0xFF8B5E3C),
          equalCellBg: Colors.transparent,
          equalCellText: const Color(0xFF7A685A),
          resultCellBg: const Color(0xFFD97706),
          resultCellText: const Color(0xFFFFFBEB),
          resultCellBorder: const Color(0xFFB45309),
          satisfiedGlowColor: const Color(0xFF059669),
          errorColor: const Color(0xFFDC2626),
          rackBg: const Color(0x66E5D7C5),
          rackTileBg: const Color(0xFFEDE0D4),
          rackTileText: const Color(0xFF3D2E24),
          rackTileBorder: const Color(0xFFBFA990),
          rackTileDisabledBg: const Color(0xFFD6C5B3),
          font: GoogleFonts.merriweather,
        );

      case ThemeType.forestZen:
        return CrossmathThemeData(
          type: type,
          isDark: true,
          backgroundColor: const Color(0xFF0C1713),
          backgroundSecondary: const Color(0xFF14241E),
          backgroundGradient: const [Color(0xFF09120F), Color(0xFF12231D)],
          appBarColor: const Color(0xFF14241E),
          primaryTextColor: const Color(0xFFECFDF5),
          secondaryTextColor: const Color(0xFF6EE7B7),
          accentColor: const Color(0xFF10B981),
          accentColorSecondary: const Color(0xFF34D399),
          boardBackgroundColor: const Color(0x33064E3B),
          boardBorderColor: const Color(0xFF134E4A),
          fixedCellBg: const Color(0xFF132D26),
          fixedCellText: const Color(0xFFD1FAE5),
          fixedCellBorder: const Color(0xFF1F4E42),
          editableEmptyCellBg: const Color(0xFF0A1813),
          editableEmptyCellBorder: const Color(0xFF10B981),
          editableFilledCellBg: const Color(0xFF1A3E34),
          editableFilledCellText: const Color(0xFF34D399),
          editableFilledCellBorder: const Color(0xFF10B981),
          selectedCellBg: const Color(0xFF065F46),
          selectedCellBorder: const Color(0xFF34D399),
          highlightedCellBg: const Color(0x2610B981),
          operatorCellBg: Colors.transparent,
          operatorCellText: const Color(0xFF6EE7B7),
          equalCellBg: Colors.transparent,
          equalCellText: const Color(0xFF059669),
          resultCellBg: const Color(0xFF047857),
          resultCellText: const Color(0xFFECFDF5),
          resultCellBorder: const Color(0xFF059669),
          satisfiedGlowColor: const Color(0xFF34D399),
          errorColor: const Color(0xFFF87171),
          rackBg: const Color(0x4D064E3B),
          rackTileBg: const Color(0xFF14352C),
          rackTileText: const Color(0xFFA7F3D0),
          rackTileBorder: const Color(0xFF059669),
          rackTileDisabledBg: const Color(0xFF0C1F1A),
          font: GoogleFonts.plusJakartaSans,
        );

      case ThemeType.synthwaveSunset:
        return CrossmathThemeData(
          type: type,
          isDark: true,
          backgroundColor: const Color(0xFF180A2E),
          backgroundSecondary: const Color(0xFF261047),
          backgroundGradient: const [Color(0xFF140728), Color(0xFF2B0C52)],
          appBarColor: const Color(0xFF261047),
          primaryTextColor: const Color(0xFFFFF1F2),
          secondaryTextColor: const Color(0xFFFDA4AF),
          accentColor: const Color(0xFFFF2E93),
          accentColorSecondary: const Color(0xFFFF9E00),
          boardBackgroundColor: const Color(0x334C1D95),
          boardBorderColor: const Color(0xFF5B21B6),
          fixedCellBg: const Color(0xFF311559),
          fixedCellText: const Color(0xFFFFE4E6),
          fixedCellBorder: const Color(0xFF581C87),
          editableEmptyCellBg: const Color(0xFF1F0B3B),
          editableEmptyCellBorder: const Color(0xFFFF2E93),
          editableFilledCellBg: const Color(0xFF4C1D95),
          editableFilledCellText: const Color(0xFFFFD166),
          editableFilledCellBorder: const Color(0xFFFF9E00),
          selectedCellBg: const Color(0xFF701A75),
          selectedCellBorder: const Color(0xFFFF2E93),
          highlightedCellBg: const Color(0x33FF2E93),
          operatorCellBg: Colors.transparent,
          operatorCellText: const Color(0xFFFF9E00),
          equalCellBg: Colors.transparent,
          equalCellText: const Color(0xFFF472B6),
          resultCellBg: const Color(0xFFBE185D),
          resultCellText: const Color(0xFFFFF1F2),
          resultCellBorder: const Color(0xFFDB2777),
          satisfiedGlowColor: const Color(0xFF10B981),
          errorColor: const Color(0xFFF43F5E),
          rackBg: const Color(0x4D3B0764),
          rackTileBg: const Color(0xFF3B1566),
          rackTileText: const Color(0xFFFFD166),
          rackTileBorder: const Color(0xFF86198F),
          rackTileDisabledBg: const Color(0xFF1E0A36),
          font: GoogleFonts.montserrat,
        );

      case ThemeType.deepOcean:
        return CrossmathThemeData(
          type: type,
          isDark: true,
          backgroundColor: const Color(0xFF04101E),
          backgroundSecondary: const Color(0xFF0A1E36),
          backgroundGradient: const [Color(0xFF030C18), Color(0xFF092340)],
          appBarColor: const Color(0xFF0A1E36),
          primaryTextColor: const Color(0xFFF0FDF4),
          secondaryTextColor: const Color(0xFF7DD3FC),
          accentColor: const Color(0xFF00C9FF),
          accentColorSecondary: const Color(0xFF38EF7D),
          boardBackgroundColor: const Color(0x330C4A6E),
          boardBorderColor: const Color(0xFF075985),
          fixedCellBg: const Color(0xFF0C2747),
          fixedCellText: const Color(0xFFE0F2FE),
          fixedCellBorder: const Color(0xFF0284C7),
          editableEmptyCellBg: const Color(0xFF06182B),
          editableEmptyCellBorder: const Color(0xFF00C9FF),
          editableFilledCellBg: const Color(0xFF0E3A66),
          editableFilledCellText: const Color(0xFF38EF7D),
          editableFilledCellBorder: const Color(0xFF38EF7D),
          selectedCellBg: const Color(0xFF0369A1),
          selectedCellBorder: const Color(0xFF38EF7D),
          highlightedCellBg: const Color(0x2600C9FF),
          operatorCellBg: Colors.transparent,
          operatorCellText: const Color(0xFF38EF7D),
          equalCellBg: Colors.transparent,
          equalCellText: const Color(0xFF38BDF8),
          resultCellBg: const Color(0xFF0284C7),
          resultCellText: const Color(0xFFF0FDF4),
          resultCellBorder: const Color(0xFF0369A1),
          satisfiedGlowColor: const Color(0xFF38EF7D),
          errorColor: const Color(0xFFFB7185),
          rackBg: const Color(0x4D0C2A4D),
          rackTileBg: const Color(0xFF0E3056),
          rackTileText: const Color(0xFF00C9FF),
          rackTileBorder: const Color(0xFF0284C7),
          rackTileDisabledBg: const Color(0xFF07192D),
          font: GoogleFonts.outfit,
        );

      case ThemeType.minimalObsidian:
        return CrossmathThemeData(
          type: type,
          isDark: true,
          backgroundColor: const Color(0xFF101216),
          backgroundSecondary: const Color(0xFF171920),
          backgroundGradient: const [Color(0xFF0C0E12), Color(0xFF16181F)],
          appBarColor: const Color(0xFF171920),
          primaryTextColor: const Color(0xFFF9FAFB),
          secondaryTextColor: const Color(0xFF9CA3AF),
          accentColor: const Color(0xFFF59E0B),
          accentColorSecondary: const Color(0xFFE5E7EB),
          boardBackgroundColor: const Color(0x221F2937),
          boardBorderColor: const Color(0xFF374151),
          fixedCellBg: const Color(0xFF1F242F),
          fixedCellText: const Color(0xFFF3F4F6),
          fixedCellBorder: const Color(0xFF374151),
          editableEmptyCellBg: const Color(0xFF14171E),
          editableEmptyCellBorder: const Color(0xFFF59E0B),
          editableFilledCellBg: const Color(0xFF262C3A),
          editableFilledCellText: const Color(0xFFFBBF24),
          editableFilledCellBorder: const Color(0xFFF59E0B),
          selectedCellBg: const Color(0xFF374151),
          selectedCellBorder: const Color(0xFFF59E0B),
          highlightedCellBg: const Color(0x26F59E0B),
          operatorCellBg: Colors.transparent,
          operatorCellText: const Color(0xFFD1D5DB),
          equalCellBg: Colors.transparent,
          equalCellText: const Color(0xFF9CA3AF),
          resultCellBg: const Color(0xFF374151),
          resultCellText: const Color(0xFFF9FAFB),
          resultCellBorder: const Color(0xFF4B5563),
          satisfiedGlowColor: const Color(0xFF10B981),
          errorColor: const Color(0xFFEF4444),
          rackBg: const Color(0x4D1F242F),
          rackTileBg: const Color(0xFF202633),
          rackTileText: const Color(0xFFF3F4F6),
          rackTileBorder: const Color(0xFF374151),
          rackTileDisabledBg: const Color(0xFF14171E),
          font: GoogleFonts.inter,
        );
    }
  }
}

