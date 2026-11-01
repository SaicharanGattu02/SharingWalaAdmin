import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label = status.toUpperCase();

    switch (label) {
      case 'ACTIVE':
      case 'APPROVED':
      case 'COMPLETED':
      case 'ACCEPTED':
      case 'RESOLVED':
        bg = AppColors.successBg;
        text = AppColors.success;
        break;
      case 'PENDING':
      case 'DRAFT':
      case 'UNDER_INVESTIGATION':
      case 'REQUESTED':
        bg = AppColors.warningBg;
        text = AppColors.warning;
        break;
      case 'SUSPENDED':
      case 'REJECTED':
      case 'BLOCKED':
      case 'CANCELLED':
      case 'DELETED':
        bg = AppColors.errorBg;
        text = AppColors.error;
        break;
      case 'IN_PROGRESS':
      case 'PUBLISHED':
        bg = AppColors.infoBg;
        text = AppColors.info;
        break;
      case 'CAR':
        bg = const Color(0xFFEFF6FF);
        text = const Color(0xFF2563EB);
        break;
      case 'BIKE':
        bg = const Color(0xFFFAF5FF);
        text = const Color(0xFF9333EA);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        text = const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: text.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

