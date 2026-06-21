import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

void showSuccessSnackBar(
  BuildContext context,
  String message, {
  IconData icon = Icons.check_circle_outline,
}) {
  _showSnackBar(
    context,
    message,
    icon: icon,
    backgroundColor: BizootColors.surfaceElevated,
    borderColor: BizootColors.success.withValues(alpha: 0.45),
  );
}

void showErrorSnackBar(
  BuildContext context,
  String message, {
  IconData icon = Icons.error_outline,
}) {
  _showSnackBar(
    context,
    message,
    icon: icon,
    backgroundColor: BizootColors.surfaceElevated,
    borderColor: BizootColors.danger.withValues(alpha: 0.45),
  );
}

void _showSnackBar(
  BuildContext context,
  String message, {
  required IconData icon,
  required Color backgroundColor,
  required Color borderColor,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        content: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 28,
                spreadRadius: -12,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: BizootColors.textPrimary, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: BizootColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
}
