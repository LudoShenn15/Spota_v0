import 'package:flutter/material.dart';

enum BadgeType { success, warning, error, info }

class Badge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final double? size;

  const Badge({
    super.key,
    required this.text,
    this.type = BadgeType.info,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getColor(context).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _getColor(context),
          fontSize: size ?? 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getColor(BuildContext context) {
    switch (type) {
      case BadgeType.success:
        return Colors.green;
      case BadgeType.warning:
        return Colors.orange;
      case BadgeType.error:
        return Colors.red;
      case BadgeType.info:
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
