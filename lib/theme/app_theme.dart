import 'package:flutter/material.dart';

class BizootColors {
  static const background = Color(0xFF08061F);
  static const backgroundSecondary = Color(0xFF060414);
  static const surface = Color(0xFF111033);
  static const surfaceElevated = Color(0xFF17124A);
  static const surfaceGlass = Color(0xCC14103C);
  static const primary = Color(0xFF16B8FF);
  static const secondary = Color(0xFF7C4DFF);
  static const pink = Color(0xFFFF4FD8);
  static const orange = Color(0xFFFF9A3D);
  static const yellow = Color(0xFFFFD166);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFC9C5E8);
  static const textMuted = Color(0xFF8F8BAA);
  static const border = Color(0x428B7BFF);
  static const borderBright = Color(0x66C170FF);
  static const success = Color(0xFF57F3BA);
  static const danger = Color(0xFFFF6B8A);
}

class BizootGradients {
  static const main = LinearGradient(
    colors: [
      BizootColors.primary,
      BizootColors.secondary,
      BizootColors.pink,
      BizootColors.orange,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const surface = LinearGradient(
    colors: [
      BizootColors.surface,
      BizootColors.surfaceElevated,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const surfaceStrong = LinearGradient(
    colors: [
      Color(0xFF151044),
      Color(0xFF1D1457),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const glass = LinearGradient(
    colors: [
      Color(0xCC17124A),
      Color(0xB3111033),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const heroGlow = LinearGradient(
    colors: [
      Color(0x6616B8FF),
      Color(0x557C4DFF),
      Color(0x33FF4FD8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class BizootSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
}

class BizootRadii {
  static const double card = 28;
  static const double input = 20;
  static const double button = 26;
}

class BizootDurations {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration press = Duration(milliseconds: 140);
  static const Duration medium = Duration(milliseconds: 180);
}

class AppTheme {
  static ThemeData light() => _buildTheme(Brightness.light);

  static ThemeData dark() => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final scaffold = brightness == Brightness.dark ? BizootColors.background : BizootColors.background;

    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: BizootColors.primary,
      onPrimary: Colors.white,
      secondary: BizootColors.secondary,
      onSecondary: Colors.white,
      error: BizootColors.danger,
      onError: Colors.white,
      surface: BizootColors.surface,
      onSurface: BizootColors.textPrimary,
      tertiary: BizootColors.orange,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0x332A1600),
      onTertiaryContainer: BizootColors.textPrimary,
      primaryContainer: Color(0x33245BBD),
      onPrimaryContainer: BizootColors.textPrimary,
      secondaryContainer: Color(0x33332178),
      onSecondaryContainer: BizootColors.textPrimary,
      onSurfaceVariant: BizootColors.textSecondary,
      outline: BizootColors.border,
      shadow: Colors.black,
      scrim: Colors.black54,
      inversePrimary: BizootColors.secondary,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      fontFamily: 'sans-serif',
    );

    return base.copyWith(
      splashColor: BizootColors.primary.withValues(alpha: 0.12),
      highlightColor: Colors.transparent,
      dividerColor: scheme.outline,
      canvasColor: Colors.transparent,
      cardTheme: CardThemeData(
        color: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BizootRadii.card),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: BizootColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: BizootColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: const TextStyle(
          fontSize: 44,
          height: 1.02,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.4,
          color: BizootColors.textPrimary,
        ),
        headlineMedium: const TextStyle(
          fontSize: 34,
          height: 1.05,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.1,
          color: BizootColors.textPrimary,
        ),
        headlineSmall: const TextStyle(
          fontSize: 24,
          height: 1.1,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.7,
          color: BizootColors.textPrimary,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          height: 1.15,
          fontWeight: FontWeight.w800,
          color: BizootColors.textPrimary,
        ),
        titleMedium: const TextStyle(
          fontSize: 17,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: BizootColors.textPrimary,
        ),
        bodyLarge: const TextStyle(
          fontSize: 15,
          height: 1.48,
          color: BizootColors.textSecondary,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          height: 1.45,
          color: BizootColors.textSecondary,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          height: 1.35,
          color: BizootColors.textMuted,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BizootColors.surfaceElevated.withValues(alpha: 0.95),
        labelStyle: const TextStyle(color: BizootColors.textSecondary, fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(color: BizootColors.textMuted),
        floatingLabelStyle: const TextStyle(color: BizootColors.textSecondary, fontWeight: FontWeight.w700),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BizootRadii.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BizootRadii.input),
          borderSide: BorderSide(color: BizootColors.border.withValues(alpha: 0.55)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BizootRadii.input),
          borderSide: const BorderSide(color: BizootColors.primary, width: 1.25),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BizootRadii.input),
          borderSide: const BorderSide(color: BizootColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BizootRadii.input),
          borderSide: const BorderSide(color: BizootColors.danger),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? Colors.white : BizootColors.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? BizootColors.primary.withValues(alpha: 0.62)
              : BizootColors.surfaceElevated.withValues(alpha: 0.92),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(color: BizootColors.textPrimary),
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(BizootColors.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(BizootRadii.input)),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: BizootColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BizootRadii.card),
        ),
        titleTextStyle: const TextStyle(
          color: BizootColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: const TextStyle(
          color: BizootColors.textSecondary,
          fontSize: 14,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: BizootColors.surface,
        modalBackgroundColor: BizootColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: BizootColors.surfaceElevated,
        side: BorderSide(color: scheme.outline),
        selectedColor: BizootColors.secondary.withValues(alpha: 0.18),
        labelStyle: const TextStyle(color: BizootColors.textSecondary, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(color: BizootColors.textPrimary, fontWeight: FontWeight.w700),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: BizootColors.textSecondary,
        textColor: BizootColors.textPrimary,
        tileColor: Colors.transparent,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: BizootColors.primary,
        linearTrackColor: Color(0x221E225F),
      ),
    );
  }
}
