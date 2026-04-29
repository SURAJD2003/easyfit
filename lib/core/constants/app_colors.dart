import 'package:flutter/material.dart';

abstract class AppColors {
  // ── Brand ─────────────────────────────────────────
  static const primary        = Color(0xFFFF6B00);  // deep orange
  static const primaryLight   = Color(0xFFFF8C38);
  static const primaryDark    = Color(0xFFCC5500);
  static const primaryGlow    = Color(0x33FF6B00);  // 20% opacity glow

  // ── Background ────────────────────────────────────
  static const background     = Color(0xFF0A0A0A);  // near black
  static const surface        = Color(0xFF141414);
  static const card           = Color(0xFF1C1C1C);
  static const cardElevated   = Color(0xFF242424);
  static const bottomNav      = Color(0xFF111111);

  // ── Text ──────────────────────────────────────────
  static const textPrimary    = Color(0xFFF5F5F5);
  static const textSecondary  = Color(0xFF9E9E9E);
  static const textHint       = Color(0xFF616161);
  static const textDisabled   = Color(0xFF424242);

  // ── Border ────────────────────────────────────────
  static const border         = Color(0xFF2A2A2A);
  static const borderLight    = Color(0xFF333333);

  // ── Status ────────────────────────────────────────
  static const success        = Color(0xFF4CAF50);
  static const successLight   = Color(0x334CAF50);
  static const error          = Color(0xFFE53935);
  static const errorLight     = Color(0x33E53935);
  static const warning        = Color(0xFFFFC107);
  static const warningLight   = Color(0x33FFC107);
  static const info           = Color(0xFF2196F3);

  // ── Gradients ─────────────────────────────────────
  static const gradientOrange = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientDark = LinearGradient(
    colors: [surface, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const gradientCard = LinearGradient(
    colors: [card, cardElevated],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Transparent ───────────────────────────────────
  static const transparent    = Colors.transparent;
  static const white          = Color(0xFFFFFFFF);
  static const black          = Color(0xFF000000);
}