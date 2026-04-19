import 'package:flutter/material.dart';
import '../core/theme.dart';

class DangerBadge extends StatelessWidget{
  final String dangerLevel;
  final bool large;

  const DangerBadge({
    super.key,
    required this.dangerLevel,
    this.large = false,
  });
  
  @override
  Widget build(BuildContext context) {

    final color = AppTheme.dangerLevelColor(dangerLevel);
    final icon  = AppTheme.dangerLevelIcon(dangerLevel);
    final size  = large ? 18.0 : 14.0;

    return Semantics(
      label: "Niveau de danger : $dangerLevel",
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: large ? 16 : 10,
          vertical:   large ? 8  : 5,
        ),
        decoration: BoxDecoration(
           color:        color.withAlpha(38), // 0.15 * 255
          borderRadius: BorderRadius.circular(100),
          border:       Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: size + 4),
            const SizedBox(width: 6),
            Text(
              dangerLevel,
              style: TextStyle(
                color:      color,
                fontSize:   size,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
}