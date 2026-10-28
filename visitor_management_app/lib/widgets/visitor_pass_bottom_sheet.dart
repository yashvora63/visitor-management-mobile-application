import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../constants/colors.dart';
import '../models/visitors_list/visitors_model.dart';
import '../screens/visitor_detail/visitor_detail_screen.dart';

class VisitorPassBottomSheet extends StatelessWidget {
  final VisitorListModel visitor;
  final bool isEditing;
  final VoidCallback? onRegisterAnother;

  const VisitorPassBottomSheet({
    super.key,
    required this.visitor,
    this.isEditing = false,
    this.onRegisterAnother,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required VisitorListModel visitor,
    bool isEditing = false,
    VoidCallback? onRegisterAnother,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VisitorPassBottomSheet(
        visitor: visitor,
        isEditing: isEditing,
        onRegisterAnother: onRegisterAnother,
      ),
    );
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'checked in' || s.contains('check_in') || s == 'status 1') {
      return AppColors.successGreen;
    } else if (s == 'checked out' ||
        s.contains('check_out') ||
        s == 'status 2') {
      return AppColors.errorRed;
    } else {
      return AppColors.warningAmber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.goldLight : AppColors.primaryGold;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightBorder,
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pull Bar
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Success Icon Badge
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.successGreen.withValues(alpha: 0.15),
              border: Border.all(
                color: AppColors.successGreen.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.successGreen,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 14),

          Text(
            isEditing
                ? 'Visitor Updated Successfully!'
                : 'Visitor Registered Successfully!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'A digital QR access pass has been generated for ${visitor.name}.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 18),

          // Digital Pass & QR Code Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkScaffoldBg : AppColors.lightInputBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryGold.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                // QR Code Display
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: visitor.id,
                    version: QrVersions.auto,
                    size: 90,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.lightTextPrimary,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Visitor Quick Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: primaryGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ID: ${visitor.id}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: primaryGold,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        visitor.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${visitor.visitorType} • ${visitor.project}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${visitor.status}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _getStatusColor(visitor.status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textPrimary,
                    side: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRegisterAnother?.call();
                    if (isEditing && Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    isEditing ? 'Done' : 'Register Another',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    foregroundColor:
                        isDark ? AppColors.darkScaffoldBg : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VisitorDetailScreen(
                          visitorId: visitor.id,
                          initialVisitor: visitor,
                        ),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_2_rounded, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'View Pass',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

