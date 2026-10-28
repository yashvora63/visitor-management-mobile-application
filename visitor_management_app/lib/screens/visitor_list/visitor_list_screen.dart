import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:visitor_management_app/constants/colors.dart';
import 'package:visitor_management_app/constants/strings.dart';
import 'package:visitor_management_app/di/components/service_locator.dart';
import 'package:visitor_management_app/models/visitors_list/visitors_model.dart';
import 'package:visitor_management_app/stores/visitor_list/visitor_list_store.dart';
import 'package:visitor_management_app/screens/visitor_detail/visitor_detail_screen.dart';
import 'package:visitor_management_app/screens/visitor_registration/visitor_registration_screen.dart';

class VisitorListScreen extends StatefulWidget {
  const VisitorListScreen({super.key});

  @override
  State<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends State<VisitorListScreen> {
  final VisitorListStore _visitorListStore = getIt<VisitorListStore>();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = const [
    'All',
    'Checked In',
    'Checked Out',
    'Registered',
  ];

  @override
  void initState() {
    super.initState();
    _fetchVisitors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchVisitors() async {
    try {
      await _visitorListStore.getVisitorList();
    } catch (_) {
      // Error handled in store
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
              Strings.visitorList,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Real-time access registry & entry log',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: primaryGold, size: 22),
            tooltip: 'Refresh Visitors',
            onPressed: _fetchVisitors,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: primaryGold,
        backgroundColor: cardBg,
        onRefresh: _fetchVisitors,
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Search Bar
            _buildSearchBar(
              isDark: isDark,
              primaryGold: primaryGold,
              borderColor: borderColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 10),
            // Filter Chips
            _buildFilterChips(
              isDark: isDark,
              primaryGold: primaryGold,
              borderColor: borderColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            const SizedBox(height: 10),
            // Visitor List Content
            Expanded(
              child: Observer(
                builder: (context) {
                  final isLoading = _visitorListStore.loading;
                  final visitors = _visitorListStore.visitorList;
                  final hasError =
                      _visitorListStore.errorStore.errorMessage.isNotEmpty;

                  if (isLoading && visitors.isEmpty) {
                    return _buildLoadingSkeletons(isDark, borderColor, cardBg);
                  }

                  if (hasError && visitors.isEmpty) {
                    return _buildErrorView(
                      isDark: isDark,
                      primaryGold: primaryGold,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    );
                  }

                  if (visitors.isEmpty) {
                    return _buildEmptyView(
                      isDark: isDark,
                      primaryGold: primaryGold,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 4,
                      bottom: 24,
                    ),
                    itemCount: visitors.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final visitor = visitors[index];
                      return _buildVisitorCard(
                        context: context,
                        visitor: visitor,
                        isDark: isDark,
                        primaryGold: primaryGold,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= Search Bar =================

  Widget _buildSearchBar({
    required bool isDark,
    required Color primaryGold,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final inputBg = isDark ? AppColors.darkInputBg : AppColors.lightInputBg;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: inputBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => _visitorListStore.searchVisitor(val),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          cursorColor: primaryGold,
          decoration: InputDecoration(
            hintText: Strings.searchPlaceholder,
            hintStyle: TextStyle(
              fontSize: 13,
              color: textSecondary.withValues(alpha: 0.7),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: primaryGold,
              size: 20,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: textSecondary,
                      size: 18,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _visitorListStore.searchVisitor('');
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // ================= Filter Chips =================

  Widget _buildFilterChips({
    required bool isDark,
    required Color primaryGold,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Observer(
      builder: (_) {
        final currentFilter = _visitorListStore.selectedStatusFilter;

        return SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _filterOptions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final option = _filterOptions[index];
              final isSelected =
                  currentFilter.toLowerCase() == option.toLowerCase();

              return GestureDetector(
                onTap: () {
                  _visitorListStore.filterByStatus(option);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryGold
                        : (isDark
                              ? AppColors.darkCardBg
                              : AppColors.lightCardBg),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? primaryGold : borderColor,
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primaryGold.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isSelected ? Colors.white : textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ================= Visitor Card =================

  Widget _buildVisitorCard({
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

    final hasCheckIn = visitor.checkInTime != null;
    final hasCheckOut = visitor.checkOutTime != null;
    final hasCreatedAt = visitor.createdAt != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VisitorDetailScreen(
                visitorId: visitor.id,
                initialVisitor: visitor,
              ),
            ),
          );
          if (mounted) {
            _fetchVisitors();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.1),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : AppColors.primaryGold.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar, Name & Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
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
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                visitor.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.black.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '#${visitor.id}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 13,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                visitor.mobile,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.goldContainerDark
                                    : AppColors.goldContainerLight,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: primaryGold.withValues(alpha: 0.3),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                visitor.visitorType,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: primaryGold,
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

              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.6),
              const SizedBox(height: 10),

              // Middle Details Row: Project, Status Badge, and Chevron
              Row(
                children: [
                  Icon(Icons.apartment_rounded, size: 14, color: primaryGold),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      visitor.project,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          visitor.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: primaryGold,
                    ),
                    tooltip: 'Edit Visitor',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => VisitorRegistrationScreen(
                            visitorToEdit: visitor,
                            onRegistrationSuccess: _fetchVisitors,
                          ),
                        ),
                      );
                      if (mounted) {
                        _fetchVisitors();
                      }
                    },
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: textSecondary.withValues(alpha: 0.6),
                  ),
                ],
              ),

              // Access Timestamps Row (Check-In / Check-Out / Registration)
              if (hasCheckIn || hasCheckOut) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: borderColor.withValues(alpha: 0.6),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (hasCheckIn)
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.login_rounded,
                                size: 12,
                                color: AppColors.successGreen,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'In: ${_formatTime(visitor.checkInTime)}',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (hasCheckIn && hasCheckOut)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Container(
                            width: 1,
                            height: 12,
                            color: borderColor,
                          ),
                        ),
                      if (hasCheckOut)
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.logout_rounded,
                                size: 12,
                                color: AppColors.errorRed,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Out: ${_formatTime(visitor.checkOutTime)}',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ] else if (hasCreatedAt) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: textSecondary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Registered: ${_formatTime(visitor.createdAt)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ================= State Views =================

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

  Widget _buildLoadingSkeletons(bool isDark, Color borderColor, Color cardBg) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 130,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white12
                          : Colors.black.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(4),
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

  Widget _buildEmptyView({
    required bool isDark,
    required Color primaryGold,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: primaryGold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_search_rounded,
                size: 36,
                color: primaryGold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              Strings.noDataFound,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No visitor records match your active search and filter criteria.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                _visitorListStore.resetFilters();
                setState(() {});
              },
              icon: Icon(Icons.clear_all_rounded, size: 18, color: primaryGold),
              label: Text(
                'Reset Filters',
                style: TextStyle(
                  color: primaryGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryGold.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView({
    required bool isDark,
    required Color primaryGold,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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
              'Failed to load visitors',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _visitorListStore.errorStore.errorMessage.isNotEmpty
                  ? _visitorListStore.errorStore.errorMessage
                  : 'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _fetchVisitors,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
