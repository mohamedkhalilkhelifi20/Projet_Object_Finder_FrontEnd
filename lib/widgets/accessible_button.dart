import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';

class AccessibleButton extends StatelessWidget {
  final String label;
  final String semanticLabel; // pour TalkBack / VoiceOver
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double height;

  const AccessibleButton({
    super.key,
    required this.label,
    required this.onPressed,
    String? semanticLabel,
    this.icon,
    this.color,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height = 56,
  }) : semanticLabel = semanticLabel ?? label;

  @override
  Widget build(BuildContext context) {
    // Semantics → lecteurs d'écran TalkBack (Android) / VoiceOver (iOS)
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,

      child: SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: isOutlined ? _buildOutlined(context) : _buildFilled(context),
      ),
    );
  }

  Widget _buildFilled(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading
          ? null
          : () {
              HapticFeedback.lightImpact(); // retour haptique au tap
              onPressed?.call();
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppTheme.primaryColor,
        disabledBackgroundColor: Colors.white12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _buildChild(),
    );
  }

  Widget _buildOutlined(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading
          ? null
          : () {
              HapticFeedback.lightImpact();
              onPressed?.call();
            },

      style: OutlinedButton.styleFrom(
         foregroundColor: color ?? AppTheme.primaryColor,
        side: BorderSide(
          color: color ?? AppTheme.primaryColor,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _buildChild(),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        width:  24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Colors.white,
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 10),
          Text(label),
        ],
      );
    }
    return Text(label);
  }
}
