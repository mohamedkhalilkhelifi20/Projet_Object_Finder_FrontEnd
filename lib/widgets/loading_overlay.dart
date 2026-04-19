import 'package:flutter/material.dart';
import '../core/theme.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: [child, if (isLoading) _buildOverlay()]);
  }

  Widget _buildOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child:Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 32, vertical: 24
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12)
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color:  AppTheme.primaryColor,
                  strokeWidth: 3,
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: const TextStyle(
                      color:    Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      )
    );
  }
}
