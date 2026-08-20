import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Tobbo/core/theme/tobbo_palette.dart';

class TobboLoader extends StatelessWidget {
  const TobboLoader({super.key, this.color, this.size = 40});

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.stretchedDots(
      color: color ?? context.palette.primary,
      size: size,
    );
  }
}

class TobboLoadingOverlay extends StatelessWidget {
  const TobboLoadingOverlay({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: context.palette.primaryText.withValues(alpha: 0.24),
        child: Center(child: TobboLoader(color: color, size: 48)),
      ),
    );
  }
}
