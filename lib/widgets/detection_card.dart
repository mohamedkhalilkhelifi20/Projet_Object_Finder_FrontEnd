import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/detection_model.dart';
import 'danger_badge.dart';

class DetectionCard extends StatelessWidget {
  final DetectionModel detection;
  final bool showTimestamp;

  const DetectionCard({
    super.key,
    required this.detection,
    this.showTimestamp = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.dangerLevelColor(detection.dangerLevel);

    return Semantics(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(102), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Ligne 1 : label + badge danger
            Row(
              children: [
                Expanded(
                  child: Text(
                    detection.labelTraduit,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                DangerBadge(dangerLevel: detection.dangerLevel),
              ],
            ),
            const SizedBox(height: 10),
            // ─── Ligne 2 : distance + confiance
            Row(
              children: [
                _infoChip(
                  Icons.straighten_rounded,
                  detection.distanceFormatted,
                  Colors.white70,
                ),
                const SizedBox(width: 12),
                _infoChip(
                  Icons.psychology_rounded,
                  "${(detection.confidence * 100).round()}%",
                  Colors.white54,
                ),
                if (showTimestamp) ...[
                  const Spacer(),
                  Text(
                    _formatTime(detection.timestamp),
                    style: const TextStyle(fontSize: 12, color: Colors.white38),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 10),
            // ─── Message vocal ──────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withAlpha(20), // 0.08 * 255
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.volume_up_rounded, color: color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      detection.voiceMessage,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color, 
            fontSize: 14,
            fontWeight: FontWeight.w500,
            ),
        ),
      ],
    );
  }

   String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:"
           "${dt.minute.toString().padLeft(2, '0')}";
  }

}
