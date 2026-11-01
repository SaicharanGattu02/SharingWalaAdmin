import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class ConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmText;
  final Color confirmColor;
  final bool requireReason;
  final String? reasonHint;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.confirmColor = AppColors.primary,
    this.requireReason = false,
    this.reasonHint,
  });

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Text(widget.message, style: AppTextStyles.body),
            if (widget.requireReason) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: widget.reasonHint ?? 'Enter specific reason...',
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.confirmColor,
                    foregroundColor: widget.confirmColor == AppColors.primary
                        ? AppColors.textDark
                        : Colors.white,
                  ),
                  onPressed: () {
                    final reason = _reasonController.text.trim();
                    if (widget.requireReason && reason.isEmpty) return;
                    Navigator.of(context).pop({'confirmed': true, 'reason': reason});
                  },
                  child: Text(widget.confirmText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

