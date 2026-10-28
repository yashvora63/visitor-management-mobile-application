import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:visitor_management_app/constants/colors.dart';
import 'package:visitor_management_app/constants/strings.dart';
import 'package:visitor_management_app/di/components/service_locator.dart';
import 'package:intl/intl.dart';
import 'package:visitor_management_app/models/visitors_list/visitors_model.dart';
import 'package:visitor_management_app/stores/visitor_list/visitor_list_store.dart';
import 'package:visitor_management_app/widgets/app_toast.dart';

class VisitorDetailScreen extends StatefulWidget {
  final String visitorId;
  final VisitorListModel? initialVisitor;

  const VisitorDetailScreen({
    super.key,
    required this.visitorId,
    this.initialVisitor,
  });

  @override
  State<VisitorDetailScreen> createState() => _VisitorDetailScreenState();
}

class _VisitorDetailScreenState extends State<VisitorDetailScreen> {
  final VisitorListStore _visitorListStore = getIt<VisitorListStore>();

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      await _visitorListStore.getVisitorDetail(widget.visitorId);
    } catch (_) {
      // Error handled by store
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.goldLight : AppColors.primaryGold;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
    final borderColor =
        isDark ? AppColors.darkCardBorder : AppColors.lightBorder;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkScaffoldBg : AppColors.lightScaffoldBg,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkScaffoldBg : AppColors.lightScaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: Text(
          Strings.visitorDetails,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: primaryGold, size: 22),
            tooltip: 'Refresh',
            onPressed: _fetchDetail,
          ),
          IconButton(
            icon: Icon(Icons.share_outlined, color: primaryGold, size: 21),
            tooltip: 'Share Pass',
            onPressed: () {
              Clipboard.setData(
                ClipboardData(
                  text:
                      'Visitor Pass #${widget.visitorId}\nName: ${_getName()}\nProject: ${_getProject()}\nStatus: ${_getStatus()}',
                ),
              );
              AppToast.showSuccess(
                message: 'Visitor pass details copied to clipboard!',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Observer(
        builder: (context) {
          final isDetailLoading = _visitorListStore.isDetailLoading;
          final detail = _visitorListStore.visitorDetail;
          final initial = widget.initialVisitor;

          // If no data is available at all and it's loading, show skeleton
          if (detail == null && initial == null && isDetailLoading) {
            return _buildLoadingSkeleton(isDark, primaryGold);
          }

          // If fetch failed and no initial data
          if (detail == null && initial == null) {
            return _buildErrorState(isDark, primaryGold, textPrimary, textSecondary);
          }

          final name = detail?.name.isNotEmpty == true
              ? detail!.name
              : (initial?.name.isNotEmpty == true ? initial!.name : 'Visitor');

            final mobile =  detail?.mobile.toString() ??  '-';
          final email = detail?.email ?? initial?.email ?? '-';
          final visitorType =
              detail?.visitorType ?? initial?.visitorType ?? 'Visitor';
          final project = detail?.project ?? initial?.project ?? '-';
          final purpose = detail?.purpose ?? initial?.purpose ?? '-';
          final status = detail?.status ?? initial?.status ?? 'Registered';

          final checkIn = _formatDateTime(
            detail?.checkInTime?.toIso8601String(),
            initial?.checkInTime?.toIso8601String(),
            fallback: 'Not Checked In',
          );
          final checkOut = _formatDateTime(
            detail?.checkOutTime?.toIso8601String(),
            initial?.checkOutTime?.toIso8601String(),
            fallback: 'Not Checked Out',
          );
           final createdAt = _formatDateTime(
            detail?.createdAt.toString(),
            initial?.createdAt.toString(),
            fallback: 'Recently',
          );
           final id = detail?.id ?? initial?.id ?? widget.visitorId;

          return RefreshIndicator(
            color: primaryGold,
            backgroundColor: cardBg,
            onRefresh: _fetchDetail,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              children: [
                // Real-time API sync indicator
                if (isDetailLoading && initial != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: primaryGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: primaryGold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryGold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Updating latest visitor details from server...',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: primaryGold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Hero Identity Card
                _buildHeroCard(
                  isDark: isDark,
                  primaryGold: primaryGold,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  name: name,
                  visitorType: visitorType,
                  status: status,
                  id: id,
                ),

                const SizedBox(height: 16),

                // Digital QR Pass Card
                _buildDigitalQrPass(
                  isDark: isDark,
                  primaryGold: primaryGold,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  id: id,
                  name: name,
                  project: project,
                  status: status,
                ),

                const SizedBox(height: 16),

                // Visit & Project Details Card
                _buildSectionCard(
                  isDark: isDark,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  title: 'Visit & Property Info',
                  icon: Icons.apartment_rounded,
                  primaryGold: primaryGold,
                  textPrimary: textPrimary,
                  children: [
                    _buildInfoRow(
                      icon: Icons.business_rounded,
                      label: Strings.project,
                      value: project,
                      isDark: isDark,
                      primaryGold: primaryGold,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const Divider(height: 20, thickness: 0.6),
                    _buildInfoRow(
                      icon: Icons.assignment_outlined,
                      label: Strings.purposeOfVisit,
                      value: purpose,
                      isDark: isDark,
                      primaryGold: primaryGold,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const Divider(height: 20, thickness: 0.6),
                    _buildInfoRow(
                      icon: Icons.badge_outlined,
                      label: Strings.visitorType,
                      value: visitorType,
                      isDark: isDark,
                      primaryGold: primaryGold,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Contact Information Card
                _buildSectionCard(
                  isDark: isDark,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  title: 'Contact Information',
                  icon: Icons.contact_phone_outlined,
                  primaryGold: primaryGold,
                  textPrimary: textPrimary,
                  children: [
                    _buildInfoRow(
                      icon: Icons.phone_rounded,
                      label: Strings.mobileNumber,
                      value: mobile,
                      isDark: isDark,
                      primaryGold: primaryGold,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      trailing: IconButton(
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 18,
                          color: primaryGold,
                        ),
                        tooltip: 'Copy Phone',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: mobile));
                          AppToast.showSuccess(message: 'Phone number copied!');
                        },
                      ),
                    ),
                    const Divider(height: 20, thickness: 0.6),
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: Strings.email,
                      value: email,
                      isDark: isDark,
                      primaryGold: primaryGold,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      trailing: IconButton(
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 18,
                          color: primaryGold,
                        ),
                        tooltip: 'Copy Email',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: email));
                          AppToast.showSuccess(message: 'Email address copied!');
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Timeline / Activity Card
                _buildSectionCard(
                  isDark: isDark,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  title: 'Access Timeline',
                  icon: Icons.schedule_rounded,
                  primaryGold: primaryGold,
                  textPrimary: textPrimary,
                  children: [
                    _buildTimelineTile(
                      isDark: isDark,
                      primaryGold: primaryGold,
                      title: Strings.createdAt,
                      subtitle: createdAt,
                      icon: Icons.how_to_reg_rounded,
                      dotColor: primaryGold,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isFirst: true,
                    ),
                    _buildTimelineTile(
                      isDark: isDark,
                      primaryGold: primaryGold,
                      title: Strings.checkInTime,
                      subtitle: checkIn,
                      icon: Icons.login_rounded,
                      dotColor: AppColors.successGreen,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    _buildTimelineTile(
                      isDark: isDark,
                      primaryGold: primaryGold,
                      title: Strings.checkOutTime,
                      subtitle: checkOut,
                      icon: Icons.logout_rounded,
                      dotColor: AppColors.errorRed,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      isLast: true,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Gate Action (Check-In / Check-Out) Card
                _buildActionCard(
                  id: id,
                  name: name,
                  project: project,
                  status: status,
                  isDark: isDark,
                  primaryGold: primaryGold,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(
    String? primary,
    String? secondary, {
    required String fallback,
  }) {
    String val = '';
    if (primary != null &&
        primary.trim().isNotEmpty &&
        primary.toLowerCase() != 'null') {
      val = primary.trim();
    } else if (secondary != null &&
        secondary.trim().isNotEmpty &&
        secondary.toLowerCase() != 'null') {
      val = secondary.trim();
    }
    if (val.isEmpty) return fallback;

    final dt = DateTime.tryParse(val);
    if (dt != null) {
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt.toLocal());
    }
    return val;
  }


  String _getName() {
    return _visitorListStore.visitorDetail?.name ??
        widget.initialVisitor?.name ??
        'Visitor';
  }

  String _getProject() {
    return _visitorListStore.visitorDetail?.project ??
        widget.initialVisitor?.project ??
        '';
  }

  String _getStatus() {
    return _visitorListStore.visitorDetail?.status ??
        widget.initialVisitor?.status ??
        'Registered';
  }

  // ================= Check-In / Check-Out Actions =================

  Widget _buildActionCard({
    required String id,
    required String name,
    required String project,
    required String status,
    required bool isDark,
    required Color primaryGold,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final s = status.toLowerCase().trim();
    final isRegistered =
        s == 'registered' || s.contains('register') || s == 'status 3';
    final isCheckedIn =
        s == 'checked in' || s.contains('check_in') || s == 'status 1';
    final isCheckedOut =
        s == 'checked out' || s.contains('check_out') || s == 'status 2';

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.swap_horizontal_circle_outlined,
                color: primaryGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Gate Action',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isRegistered) ...[
            Text(
              'Visitor is currently registered and awaiting entry at the gate.',
              style: TextStyle(fontSize: 13, color: textSecondary, height: 1.4),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.login_rounded, size: 20),
                label: const Text(
                  'Check In Visitor',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _confirmAndCheckIn(id, name, project),
              ),
            ),
          ] else if (isCheckedIn) ...[
            Text(
              'Visitor has checked in and is currently on the premises.',
              style: TextStyle(fontSize: 13, color: textSecondary, height: 1.4),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text(
                  'Check Out Visitor',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _confirmAndCheckOut(id, name, project),
              ),
            ),
          ] else if (isCheckedOut) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.errorRed.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      size: 20, color: AppColors.errorRed),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Visit Completed. This visitor has checked out and the visit session has concluded.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmAndCheckIn(
      String id, String name, String project) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nowFormatted =
        DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.login_rounded,
                  color: AppColors.successGreen, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Confirm Check-In',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'Are you sure you want to Check In '),
                  TextSpan(
                      text: name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' into '),
                  TextSpan(
                      text: project,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: '?'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 16, color: AppColors.successGreen),
                  const SizedBox(width: 8),
                  Text(
                    nowFormatted,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(Strings.cancel,
                style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm Check-In',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _visitorListStore.checkInVisitor(id);
        AppToast.showSuccess(message: '$name checked in successfully!');
        _fetchDetail();
      } catch (e) {
        AppToast.showError(
            message: e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _confirmAndCheckOut(
      String id, String name, String project) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nowFormatted =
        DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded,
                  color: AppColors.errorRed, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Confirm Check-Out',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'Are you sure you want to Check Out '),
                  TextSpan(
                      text: name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: '? This will mark the visit as completed.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 16, color: AppColors.errorRed),
                  const SizedBox(width: 8),
                  Text(
                    nowFormatted,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(Strings.cancel,
                style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm Check-Out',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _visitorListStore.checkOutVisitor(id);
        AppToast.showSuccess(message: '$name checked out successfully!');
        _fetchDetail();
      } catch (e) {
        AppToast.showError(
            message: e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  // ================= UI Helpers =================

  Widget _buildHeroCard({
    required bool isDark,
    required Color primaryGold,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required String name,
    required String visitorType,
    required String status,
    required String id,
  }) {
    final statusColor = _getStatusColor(status);
    final initials = name.trim().isNotEmpty
        ? name
            .trim()
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'V';

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : AppColors.primaryGold.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with gold border ring
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      primaryGold,
                      isDark ? AppColors.goldGlow : AppColors.goldDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryGold.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Name & Pass ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.goldContainerDark
                                : AppColors.goldContainerLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: primaryGold.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            'PASS #$id',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: primaryGold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            visitorType,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, thickness: 0.6),
          const SizedBox(height: 14),
          // Status bar inside hero
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Status',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalQrPass({
    required bool isDark,
    required Color primaryGold,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required String id,
    required String name,
    required String project,
    required String status,
  }) {
    final qrData = 'SUMADHURA-PASS:$id|$name|$project|$status';

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColors.primaryGold.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.qr_code_2_rounded, color: primaryGold, size: 22),
              const SizedBox(width: 10),
              Text(
                'Digital Gate Pass',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ENCRYPTED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: primaryGold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // QR container with golden inner card
          Center(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryGold.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryGold.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 160.0,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF1C1A17),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF1C1A17),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Scan pass at security checkpoint or front-desk terminal',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required String title,
    required IconData icon,
    required Color primaryGold,
    required Color textPrimary,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryGold, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required Color primaryGold,
    required Color textPrimary,
    required Color textSecondary,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkInputBg
                : AppColors.goldContainerLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.8,
            ),
          ),
          child: Icon(icon, size: 18, color: primaryGold),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }

  Widget _buildTimelineTile({
    required bool isDark,
    required Color primaryGold,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color dotColor,
    required Color textPrimary,
    required Color textSecondary,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicator column with line
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: dotColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: dotColor, width: 1.5),
              ),
              child: Icon(icon, size: 14, color: dotColor),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: isDark ? AppColors.darkBorder : AppColors.lightDivider,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

  Widget _buildLoadingSkeleton(bool isDark, Color primaryGold) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: primaryGold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Fetching visitor details...',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    bool isDark,
    Color primaryGold,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 38,
                color: AppColors.errorRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to Load Visitor Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your network connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchDetail,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
