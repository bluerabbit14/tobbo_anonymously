import 'package:flutter/material.dart';
import 'package:Tobbo/core/constants/app_spacing.dart';
import 'package:Tobbo/core/theme/tobbo_palette.dart';
import 'package:Tobbo/presentation/widgets/tobbo_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            TobboButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null)
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: context.palette.primaryText,
          ),
        Expanded(child: Text(title, style: Theme.of(context).textTheme.headlineMedium)),
      ],
    );
  }
}
