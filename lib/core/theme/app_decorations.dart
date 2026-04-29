import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

abstract class AppDecorations {
  // ── Cards ─────────────────────────────────────────
  static BoxDecoration get card => BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
    border: Border.all(color: AppColors.border, width: 1),
  );

  static BoxDecoration get cardGlow => BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
    border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
    boxShadow: [
      BoxShadow(
        color: AppColors.primaryGlow,
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get cardElevated => BoxDecoration(
    color: AppColors.cardElevated,
    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
    border: Border.all(color: AppColors.borderLight, width: 1),
  );

  // ── Gradient Cards ────────────────────────────────
  static BoxDecoration get gradientCard => BoxDecoration(
    gradient: AppColors.gradientCard,
    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
    border: Border.all(color: AppColors.border, width: 1),
  );

  static BoxDecoration get orangeGradientCard => BoxDecoration(
    gradient: AppColors.gradientOrange,
    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
  );

  // ── Input Fields ──────────────────────────────────
  static InputDecoration inputDecoration({
    required String hint,
    String? label,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        hintText: hint,
        labelText: label,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      );

  // ── Containers ────────────────────────────────────
  static BoxDecoration get surface => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
  );

  static BoxDecoration get pill => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
    border: Border.all(color: AppColors.border),
  );

  static BoxDecoration get orangePill => BoxDecoration(
    color: AppColors.primaryGlow,
    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
    border: Border.all(color: AppColors.primary.withOpacity(0.4)),
  );

  // ── Divider ───────────────────────────────────────
  static BoxDecoration get divider => const BoxDecoration(
    border: Border(
      bottom: BorderSide(color: AppColors.border, width: 1),
    ),
  );
}