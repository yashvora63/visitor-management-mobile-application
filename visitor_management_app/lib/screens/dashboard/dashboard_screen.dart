import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';

import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../di/components/service_locator.dart';
import '../../models/visitors_list/visitors_model.dart';
import '../../stores/visitor_list/visitor_list_store.dart';
import '../../widgets/dashboard_stat_card.dart';
import '../visitor_detail/visitor_detail_screen.dart';
import '../visitor_list/visitor_list_screen.dart';
import '../visitor_registration/visitor_registration_screen.dart';
import '../qr_scanner/qr_scanner_screen.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(int index)? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final VisitorListStore _visitorListStore = getIt<VisitorListStore>();

  @override
  void initState() {
    super.initState();
    _fetchVisitors();
  }

  Future<void> _fetchVisitors() async {
    try {
      await _visitorListStore.getVisitorList();
    } catch (_) {
      // Error handled in store
    }
  }

  void _navigateToTab(int index, {String? statusFilter}) {
    if (statusFilter != null) {
      _visitorListStore.filterByStatus(statusFilter);
    }
    if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(index);
    } else {
      Widget target;
      switch (index) {
        case 1:
          target = const VisitorListScreen();
          break;
        case 2:
          target = const VisitorRegistrationScreen();
          break;
        case 3:
          target = const QrScannerScreen();
          break;
        default:
          return;
      }
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => target));
    }
  }

  String _formatTime(dynamic val) {
    if (val == null) return '-';
    if (val is DateTime) {
      return DateFormat('dd MMM, hh:mm a').format(val.toLocal());
    }
    final raw = val.toString().trim();
    if (raw.isEmpty || raw.toLowerCase() == 'null') return '-';
    final dt = DateTime.tryParse(raw);
    if (dt != null) {
      return DateFormat('dd MMM, hh:mm a').format(dt.toLocal());
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.goldLight : AppColors.primaryGold;
    final scaffoldBg = isDark
        ? AppColors.darkScaffoldBg
        : AppColors.lightScaffoldBg;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
    final borderColor = isDark
        ? AppColors.darkCardBorder
        : AppColors.lightBorder;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final formattedDate = DateFormat('EEEE, d MMMM yyyy')
        .format(DateTime.now());

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Strings.appName,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          // Live Pulse Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.goldContainerDark
                  : AppColors.goldContainerLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryGold.withValues(alpha: 0.35),
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
                    color: AppColors.successGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.successGreen.withValues(alpha: 0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Live',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: primaryGold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: primaryGold, size: 22),
            tooltip: 'Refresh Dashboard',
            onPressed: _fetchVisitors,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: primaryGold,
        backgroundColor: cardBg,
        onRefresh: _fetchVisitors,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Welcome & Overview Banner
            _buildWelcomeBanner(
              isDark: isDark,
              primaryGold: primaryGold,
              cardBg: cardBg,
              borderColor: borderColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),

            const SizedBox(height: 20),

            // Statistics Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Key Metrics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  'Auto-synced',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Three Required Statistics Cards
            Observer(
              builder: (_) {
                final isLoading =
                    _visitorListStore.loading &&
                    _visitorListStore.allVisitors.isEmpty;

                if (isLoading) {
                  return _buildStatsSkeleton(isDark, borderColor, cardBg);
                }

                final totalToday = _visitorListStore.totalVisitorsToday;
                final checkedIn = _visitorListStore.currentlyCheckedIn;
                final checkedOut = _visitorListStore.checkedOutToday;

                return Column(
                  children: [
                    // Card 1: Total Visitors Today (Prominent Hero Stat Card)
                    DashboardStatCard(
                      title: Strings.totalVisitorsToday,
                      value: totalToday.toString(),
                      subtitle: 'Visitors registered today on local date',
                      icon: Icons.groups_rounded,
                      accentColor: primaryGold,
                      onTap: () => _navigateToTab(1, statusFilter: 'All'),
                    ),
                    const SizedBox(height: 12),
                    // Cards 2 & 3: Currently Checked In & Checked Out Today (Side by side)
                    Row(
                      children: [
                        Expanded(
                          child: DashboardStatCard(
                            title: Strings.currentlyCheckedIn,
                            value: checkedIn.toString(),
                            subtitle: 'Active on premises',
                            icon: Icons.how_to_reg_rounded,
                            accentColor: AppColors.successGreen,
                            onTap: () =>
                                _navigateToTab(1, statusFilter: 'Checked In'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DashboardStatCard(
                            title: Strings.checkedOutToday,
                            value: checkedOut.toString(),
                            subtitle: 'Exited premises',
                            icon: Icons.logout_rounded,
                            accentColor: AppColors.errorRed,
                            onTap: () =>
                                _navigateToTab(1, statusFilter: 'Checked Out'),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Quick Shortcuts Section (PDF Functional Requirement)
            Text(
              'Quick Shortcuts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),
            _buildQuickShortcuts(
              isDark: isDark,
              primaryGold: primaryGold,
              cardBg: cardBg,
              borderColor: borderColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),

            const SizedBox(height: 24),

            // Recent Visitor Activity Preview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Visitor Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                GestureDetector(
                  onTap: () => _navigateToTab(1, statusFilter: 'All'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primaryGold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: primaryGold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Recent Visitors List
            Observer(
              builder: (_) {
                final isLoading =
                    _visitorListStore.loading &&
                    _visitorListStore.allVisitors.isEmpty;
                final recents = _visitorListStore.recentVisitors;

                if (isLoading) {
                  return _buildRecentSkeleton(isDark, borderColor, cardBg);
                }

                if (recents.isEmpty) {
                  return _buildEmptyActivity(
                    isDark: isDark,
                    primaryGold: primaryGold,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  );
                }

                return Column(
                  children: recents.map((visitor) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildRecentVisitorTile(
                        context: context,
                        visitor: visitor,
                        isDark: isDark,
                        primaryGold: primaryGold,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ================= Welcome Banner =================

  Widget _buildWelcomeBanner({
    required bool isDark,
    required Color primaryGold,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColors.primaryGold.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryGold,
                  isDark ? AppColors.goldGlow : AppColors.goldDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: primaryGold.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.apartment_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Strings.companyName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Front-Desk & Security Activity Portal',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= Quick Shortcuts =================

  Widget _buildQuickShortcuts({
    required bool isDark,
    required Color primaryGold,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      children: [
        // Register Visitor
        Expanded(
          child: _buildShortcutButton(
            icon: Icons.person_add_rounded,
            label: Strings.registerVisitor,
            color: primaryGold,
            isDark: isDark,
            cardBg: cardBg,
            borderColor: borderColor,
            textPrimary: textPrimary,
            onTap: () => _navigateToTab(2),
          ),
        ),
        const SizedBox(width: 10),
        // Scan QR Code
        Expanded(
          child: _buildShortcutButton(
            icon: Icons.qr_code_scanner_rounded,
            label: Strings.scanQrCode,
            color: isDark ? AppColors.goldLight : AppColors.goldDark,
            isDark: isDark,
            cardBg: cardBg,
            borderColor: borderColor,
            textPrimary: textPrimary,
            onTap: () => _navigateToTab(3),
          ),
        ),
        const SizedBox(width: 10),
        // Visitor List
        Expanded(
          child: _buildShortcutButton(
            icon: Icons.badge_outlined,
            label: Strings.visitors,
            color: textSecondary,
            isDark: isDark,
            cardBg: cardBg,
            borderColor: borderColor,
            textPrimary: textPrimary,
            onTap: () => _navigateToTab(1, statusFilter: 'All'),
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.1),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= Recent Activity Tile =================

  Widget _buildRecentVisitorTile({
    required BuildContext context,
    required VisitorListModel visitor,
    required bool isDark,
    required Color primaryGold,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final statusColor = _getStatusColor(visitor.status);
    final initials = visitor.name.trim().isNotEmpty
        ? visitor.name
              .trim()
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join()
              .toUpperCase()
        : 'V';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VisitorDetailScreen(
                visitorId: visitor.id,
                initialVisitor: visitor,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryGold.withValues(alpha: 0.14),
                  border: Border.all(
                    color: primaryGold.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: primaryGold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visitor.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      visitor.checkInTime != null
                          ? '${visitor.project} • In: ${_formatTime(visitor.checkInTime)}'
                          : '${visitor.project} • ${visitor.mobile}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      visitor.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11,
                color: textSecondary.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
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

  // ================= Skeletons & Empty State =================

  Widget _buildStatsSkeleton(bool isDark, Color borderColor, Color cardBg) {
    return Column(
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 1),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 1),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentSkeleton(bool isDark, Color borderColor, Color cardBg) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildEmptyActivity({
    required bool isDark,
    required Color primaryGold,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 36,
            color: textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 10),
          Text(
            'No Recent Visitors',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'New visitor check-ins and registrations will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: textSecondary),
          ),
        ],
      ),
    );
  }
}
