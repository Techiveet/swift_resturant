import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0F9D58);
  static const Color primaryDark = Color(0xFF08783F);
  static const Color ink = Color(0xFF0C1813);
  static const Color scaffold = Color(0xFFF4F7F5);
  static const Color card = Colors.white;
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFD7E0DA);
  static const Color info = Color(0xFF2563EB);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);
  static const Color success = Color(0xFF15803D);
}

class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: dark ? const Color(0xFF5DDB91) : AppColors.primaryDark,
          onPrimary: dark ? AppColors.ink : Colors.white,
          surface: dark ? const Color(0xFF15211B) : Colors.white,
          onSurface: dark ? const Color(0xFFF0F7F2) : AppColors.ink,
          outline: dark ? const Color(0xFF53655A) : AppColors.border,
        );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return base.copyWith(
      scaffoldBackgroundColor: dark
          ? const Color(0xFF0C1510)
          : AppColors.scaffold,
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF101C16) : AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: dark ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: .12),
          disabledForegroundColor: scheme.onSurface.withValues(alpha: .45),
          minimumSize: const Size(64, 54),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: buttonShape,
          elevation: 1,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: .12),
          disabledForegroundColor: scheme.onSurface.withValues(alpha: .45),
          minimumSize: const Size(64, 54),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: buttonShape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(64, 54),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: BorderSide(color: scheme.primary, width: 1.5),
          shape: buttonShape,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.all(12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 4,
        extendedTextStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(backgroundColor: scheme.surface),
    );
  }
}
