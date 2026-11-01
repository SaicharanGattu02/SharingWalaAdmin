import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color? iconBgColor;
  final String? trend;
  final bool isTrendPositive;
  final VoidCallback? onTap;
  final bool isSelected;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    this.iconBgColor,
    this.trend,
    this.isTrendPositive = true,
    this.onTap,
    this.isSelected = false,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isClickable = widget.onTap != null;

    final cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isSelected
              ? widget.iconColor
              : (_isHovered ? widget.iconColor.withValues(alpha: 0.5) : AppColors.lightBorder),
          width: widget.isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isSelected
                ? widget.iconColor.withValues(alpha: 0.2)
                : (_isHovered
                    ? widget.iconColor.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.03)),
            blurRadius: widget.isSelected || _isHovered ? 16 : 8,
            offset: Offset(0, _isHovered ? 6 : 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13,
                    color: widget.isSelected
                        ? const Color(0xFF0F172A)
                        : (_isHovered ? const Color(0xFF0F172A) : null),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.iconBgColor ?? widget.iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.value,
            style: AppTextStyles.h1.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          if (widget.subtitle != null || widget.trend != null)
            Row(
              children: [
                if (widget.trend != null) ...[
                  Icon(
                    widget.isTrendPositive ? Icons.trending_up : Icons.trending_down,
                    size: 16,
                    color: widget.isTrendPositive ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.trend!,
                    style: TextStyle(
                      color: widget.isTrendPositive ? AppColors.success : AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (widget.subtitle != null)
                  Expanded(
                    child: Text(
                      widget.subtitle!,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );

    if (isClickable) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
