import 'dart:convert';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../di/components/service_locator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../visitor_detail/visitor_detail_screen.dart';
import '../../models/visitors_list/visitors_model.dart';
import '../../stores/visitor_list/visitor_list_store.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/visitor_detail/visitor_detail_model.dart';
import '../visitor_registration/visitor_registration_screen.dart';

class QrScannerScreen extends StatefulWidget {
  final bool isActive;

  const QrScannerScreen({super.key, this.isActive = true});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final VisitorListStore _visitorListStore = getIt<VisitorListStore>();

  late final MobileScannerController _scannerController;
  late final AnimationController _scanAnimationController;

  bool _isProcessing = false;
  bool _isExecutingAction = false;
  bool _hasCameraPermission = false;
  bool _isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scannerController = MobileScannerController(
      autoStart: false,
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 1000,
      formats: const [BarcodeFormat.qrCode],
    );

    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _checkAndRequestPermission();
  }

  @override
  void didUpdateWidget(covariant QrScannerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _isProcessing = false;
        _isExecutingAction = false;
        if (_hasCameraPermission && !_scannerController.value.isRunning) {
          try {
            _scannerController.start();
          } catch (_) {}
        }
      } else {
        if (_scannerController.value.isRunning) {
          try {
            _scannerController.stop();
          } catch (_) {}
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_hasCameraPermission || !widget.isActive) return;

    if (state == AppLifecycleState.resumed) {
      if (!_isProcessing && !_scannerController.value.isRunning) {
        try {
          _scannerController.start();
        } catch (_) {}
      }
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (_scannerController.value.isRunning) {
        try {
          _scannerController.stop();
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanAnimationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  // ================= Permissions =================

  Future<void> _checkAndRequestPermission() async {
    setState(() => _isCheckingPermission = true);

    final status = await Permission.camera.status;
    if (status.isGranted) {
      if (mounted) {
        setState(() {
          _hasCameraPermission = true;
          _isCheckingPermission = false;
        });
        if (widget.isActive && !_scannerController.value.isRunning) {
          try {
            _scannerController.start();
          } catch (_) {}
        }
      }
      return;
    }

    final result = await Permission.camera.request();
    if (mounted) {
      setState(() {
        _hasCameraPermission = result.isGranted;
        _isCheckingPermission = false;
      });

      if (result.isGranted &&
          widget.isActive &&
          !_scannerController.value.isRunning) {
        try {
          _scannerController.start();
        } catch (_) {}
      }
    }
  }

  // ================= QR Parsing & Validation =================

  /// Extracts the unique visitor ID from diverse QR formats:
  /// - Plain ID (e.g. "VIS001", "1")
  /// - Sumadhura Pass format: "SUMADHURA-PASS:VIS001|Rahul|Project A|Registered"
  /// - JSON format: {"id": "VIS001", ...}
  /// - URL format: ".../visitors/VIS001"
  /// - Pass prefix: "PASS #VIS001" or "#VIS001"
  String? _extractVisitorId(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    // 1. Sumadhura Gate Pass format
    if (trimmed.toUpperCase().startsWith('SUMADHURA-PASS:')) {
      final payload = trimmed.substring('SUMADHURA-PASS:'.length);
      final parts = payload.split('|');
      if (parts.isNotEmpty && parts[0].trim().isNotEmpty) {
        return parts[0].trim();
      }
    }

    // 2. JSON format
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map && decoded['id'] != null) {
          final idStr = decoded['id'].toString().trim();
          if (idStr.isNotEmpty) return idStr;
        }
      } catch (_) {}
    }

    // 3. URL format
    if (trimmed.contains('/visitors/')) {
      final segs = trimmed.split('/visitors/');
      if (segs.length > 1) {
        final possibleId = segs[1].split('?').first.split('/').first.trim();
        if (possibleId.isNotEmpty) return possibleId;
      }
    }

    // 4. Colon / Pipe separated: PASS:VIS001 or VIS001|...
    if (trimmed.contains(':')) {
      final parts = trimmed.split(':');
      final last = parts.last.split('|').first.trim();
      if (last.isNotEmpty && !last.contains(' ') && last.length <= 40) {
        return last;
      }
    }

    if (trimmed.contains('|')) {
      final first = trimmed.split('|').first.trim();
      if (first.isNotEmpty && !first.contains(' ') && first.length <= 40) {
        return first;
      }
    }

    // 5. Pass prefix format (e.g. "PASS #VIS001", "#VIS001")
    if (trimmed.toUpperCase().startsWith('PASS #') ||
        trimmed.toUpperCase().startsWith('PASS#')) {
      final idOnly = trimmed
          .replaceAll(RegExp(r'pass\s*#?', caseSensitive: false), '')
          .trim();
      if (idOnly.isNotEmpty) return idOnly;
    }
    if (trimmed.startsWith('#')) {
      final idOnly = trimmed.substring(1).trim();
      if (idOnly.isNotEmpty) return idOnly;
    }

    // 6. Standard raw ID (e.g. VIS001, 1, 42)
    if (!trimmed.contains(' ') &&
        !trimmed.contains('\n') &&
        trimmed.length <= 40) {
      return trimmed;
    }

    return null;
  }

  // ================= Scanning Handler =================

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || !widget.isActive) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    final visitorId = _extractVisitorId(rawValue);

    // 1. Validation: Invalid QR Code
    if (visitorId == null) {
      setState(() => _isProcessing = true);
      HapticFeedback.mediumImpact();
      if (mounted) {
        _showInvalidQrDialog(rawValue);
      }
      return;
    }

    // 2. Retrieve Visitor details from API
    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();
    if (mounted) {
      _lookupVisitor(visitorId);
    }
  }

  Future<void> _lookupVisitor(String visitorId) async {
    _isProcessing = true;
    _showLoadingDialog('Verifying Visitor Pass #$visitorId...');

    try {
      final visitor = await _visitorListStore.getVisitorDetail(visitorId);

      // Close loading dialog
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (visitor == null) {
        if (mounted) {
          _showVisitorNotFoundDialog(visitorId);
        }
        return;
      }

      // Display Visitor Information & Status modal with Check-In / Check-Out options
      if (mounted) {
        _showVisitorIdentifiedSheet(visitor);
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (mounted) {
        _showVisitorNotFoundDialog(visitorId);
      }
    }
  }

  // ================= Dialogs & Modals =================

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark
              ? AppColors.darkCardBg
              : AppColors.lightCardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.8,
                    color: isDark ? AppColors.goldLight : AppColors.primaryGold,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Invalid QR Code feedback dialog
  void _showInvalidQrDialog(String rawScanned) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.goldLight : AppColors.primaryGold;

    _isProcessing = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.errorRed,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Invalid QR Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Strings.invalidQrCode,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Text(
                'Scanned Content:\n${rawScanned.length > 80 ? '${rawScanned.substring(0, 80)}...' : rawScanned}',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text(
              'Scan Again',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ).then((_) {
      _resumeScanner();
    });
  }

  /// Visitor Not Found in API dialog
  void _showVisitorNotFoundDialog(String visitorId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.goldLight : AppColors.primaryGold;

    _isProcessing = true;

    showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warningAmber.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_off_rounded,
                color: AppColors.warningAmber,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Visitor Not Found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No visitor record found for Pass ID #$visitorId.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please ensure the visitor has been registered in the system or scan a valid gate pass.',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop('register');
            },
            child: Text(
              'Register Visitor',
              style: TextStyle(color: primaryGold, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(ctx).pop('scan_again');
            },
            child: const Text(
              'Scan Again',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ).then((action) {
      _resumeScanner();
      if (mounted && action == 'register') {
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) => const VisitorRegistrationScreen(),
              ),
            )
            .then((_) {
              _resumeScanner();
            });
      }
    });
  }

  /// Visitor Identification Bottom Sheet showing visitor profile and check-in / check-out options
  void _showVisitorIdentifiedSheet(VisitorDetailModel visitor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.goldLight : AppColors.primaryGold;
    final sheetBg = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final statusLower = visitor.status.toLowerCase().trim();
    final isRegistered =
        statusLower == 'registered' ||
        statusLower.contains('register') ||
        statusLower == 'status 3';
    final isCheckedIn =
        statusLower == 'checked in' ||
        statusLower.contains('check_in') ||
        statusLower == 'status 1';
    final isCheckedOut =
        statusLower == 'checked out' ||
        statusLower.contains('check_out') ||
        statusLower == 'status 2';

    final Color statusColor = isCheckedIn
        ? AppColors.successGreen
        : (isCheckedOut ? AppColors.errorRed : AppColors.warningAmber);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(bottomSheetContext).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Badge & Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryGold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: primaryGold.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: primaryGold,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'PASS #${visitor.id}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: primaryGold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        color: textSecondary,
                        onPressed: () {
                          Navigator.of(bottomSheetContext).pop();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Visitor Name & Visitor Type
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              visitor.name.isNotEmpty
                                  ? visitor.name
                                  : 'Visitor',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              visitor.visitorType.isNotEmpty
                                  ? visitor.visitorType
                                  : 'General Visitor',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              visitor.status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  const Divider(height: 1, thickness: 0.8),
                  const SizedBox(height: 14),

                  // Information Grid / Rows
                  _buildDetailItem(
                    icon: Icons.apartment_rounded,
                    label: Strings.project,
                    value: visitor.project.isNotEmpty
                        ? visitor.project
                        : 'Not assigned',
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    primaryGold: primaryGold,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailItem(
                    icon: Icons.assignment_outlined,
                    label: Strings.purposeOfVisit,
                    value: visitor.purpose.isNotEmpty
                        ? visitor.purpose
                        : 'General',
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    primaryGold: primaryGold,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailItem(
                    icon: Icons.phone_rounded,
                    label: Strings.mobileNumber,
                    value: visitor.mobile.isNotEmpty ? visitor.mobile : '-',
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    primaryGold: primaryGold,
                  ),
                  if (visitor.checkInTime != null) ...[
                    const SizedBox(height: 10),
                    _buildDetailItem(
                      icon: Icons.login_rounded,
                      label: Strings.checkInTime,
                      value: DateFormat(
                        'dd MMM yyyy, hh:mm a',
                      ).format(visitor.checkInTime!.toLocal()),
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      primaryGold: AppColors.successGreen,
                    ),
                  ],
                  if (visitor.checkOutTime != null) ...[
                    const SizedBox(height: 10),
                    _buildDetailItem(
                      icon: Icons.logout_rounded,
                      label: Strings.checkOutTime,
                      value: DateFormat(
                        'dd MMM yyyy, hh:mm a',
                      ).format(visitor.checkOutTime!.toLocal()),
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      primaryGold: AppColors.errorRed,
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Business Rule Status Notifications
                  if (isCheckedIn)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.infoBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.infoBlue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: AppColors.infoBlue,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Visitor is currently checked in. Duplicate check-in is not permitted. You can record check-out below.',
                              style: TextStyle(
                                fontSize: 12,
                                color: textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (isCheckedOut)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 20,
                            color: AppColors.errorRed,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Visit completed. Visitors who have checked out cannot be checked in again.',
                              style: TextStyle(
                                fontSize: 12,
                                color: textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ================= Action Buttons =================
                  if (isRegistered) ...[
                    // Primary Action: CHECK IN
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.login_rounded, size: 20),
                        label: const Text(
                          'Check In Visitor',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          // Trigger Confirmation Popup before updating check-in info
                          _showCheckInConfirmationDialog(
                            parentContext: bottomSheetContext,
                            visitor: visitor,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else if (isCheckedIn) ...[
                    // Primary Action: CHECK OUT
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout_rounded, size: 20),
                        label: const Text(
                          'Check Out Visitor',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorRed,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          // Trigger Confirmation Popup before updating check-out info
                          _showCheckOutConfirmationDialog(
                            parentContext: bottomSheetContext,
                            visitor: visitor,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Secondary Action: VIEW FULL DETAILS (Proper Redirection)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      icon: Icon(
                        Icons.visibility_outlined,
                        size: 18,
                        color: primaryGold,
                      ),
                      label: Text(
                        'View Full Visitor Profile',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: primaryGold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: primaryGold.withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(bottomSheetContext).pop();
                        _redirectToVisitorDetail(visitor.id).then((_) {
                          _resumeScanner();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      if (!_isExecutingAction) {
        _resumeScanner();
      }
    });
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryGold,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: primaryGold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: primaryGold),
        ),
        const SizedBox(width: 12),
        Column(
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
            const SizedBox(height: 1),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================= Confirmation Popups =================

  /// Check-In Confirmation Popup before updating status
  void _showCheckInConfirmationDialog({
    required BuildContext parentContext,
    required VisitorDetailModel visitor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nowFormatted = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(DateTime.now());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (confirmContext) => AlertDialog(
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
              child: const Icon(
                Icons.login_rounded,
                color: AppColors.successGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Confirm Check-In',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
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
                    text: visitor.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' into '),
                  TextSpan(
                    text: visitor.project,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 15,
                        color: AppColors.successGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Entry Timestamp',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 23),
                    child: Text(
                      nowFormatted,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(confirmContext).pop(),
            child: Text(
              Strings.cancel,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              _isExecutingAction = true;
              Navigator.of(confirmContext).pop(); // close confirm dialog
              Navigator.of(parentContext).pop(); // close bottom sheet

              await _performCheckIn(visitor.id);
            },
            child: const Text(
              'Confirm Check-In',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  /// Check-Out Confirmation Popup before updating status
  void _showCheckOutConfirmationDialog({
    required BuildContext parentContext,
    required VisitorDetailModel visitor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nowFormatted = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(DateTime.now());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (confirmContext) => AlertDialog(
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
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.errorRed,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Confirm Check-Out',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
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
                    text: visitor.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text: '? This will mark the visit as completed.',
                  ),
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
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 15,
                        color: AppColors.errorRed,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Exit Timestamp',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 23),
                    child: Text(
                      nowFormatted,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(confirmContext).pop(),
            child: Text(
              Strings.cancel,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              _isExecutingAction = true;
              Navigator.of(confirmContext).pop(); // close confirm dialog
              Navigator.of(parentContext).pop(); // close bottom sheet

              await _performCheckOut(visitor.id);
            },
            child: const Text(
              'Confirm Check-Out',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ================= API Operations & Redirection =================

  Future<void> _performCheckIn(String visitorId) async {
    _showLoadingDialog('Recording Check-In with server...');

    try {
      final updated = await _visitorListStore.checkInVisitor(visitorId);

      // Close loading dialog
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      AppToast.showSuccess(
        message: '${updated.name} has been successfully checked in!',
      );

      // Proper redirection to Visitor Details Screen
      if (mounted) {
        await _redirectToVisitorDetail(visitorId, initialVisitor: updated);
      }
    } catch (e) {
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      AppToast.showError(message: e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _isExecutingAction = false;
      _resumeScanner();
    }
  }

  Future<void> _performCheckOut(String visitorId) async {
    _showLoadingDialog('Recording Check-Out with server...');

    try {
      final updated = await _visitorListStore.checkOutVisitor(visitorId);

      // Close loading dialog
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      AppToast.showSuccess(
        message: '${updated.name} has been successfully checked out!',
      );

      // Proper redirection to Visitor Details Screen
      if (mounted) {
        await _redirectToVisitorDetail(visitorId, initialVisitor: updated);
      }
    } catch (e) {
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      AppToast.showError(message: e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _isExecutingAction = false;
      _resumeScanner();
    }
  }

  /// Proper Redirection to Visitor Details Screen as per assignment specifications
  Future<void> _redirectToVisitorDetail(
    String visitorId, {
    VisitorListModel? initialVisitor,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VisitorDetailScreen(
          visitorId: visitorId,
          initialVisitor: initialVisitor,
        ),
      ),
    );
  }

  void _resumeScanner() {
    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        if (_hasCameraPermission && widget.isActive) {
          if (!_scannerController.value.isRunning) {
            try {
              _scannerController.start();
            } catch (_) {}
          }
        }
      }
    });
  }

  // ================= Manual Pass ID Entry =================

  void _showManualIdDialog() {
    final textController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.goldLight : AppColors.primaryGold;

    // Pause barcode detections while user is typing in dialog
    setState(() => _isProcessing = true);

    showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryGold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.keyboard_outlined,
                color: primaryGold,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Enter Pass ID',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the visitor Pass ID (e.g., VIS001, 1) to retrieve details:',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: textController,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. VIS001',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextHint,
                ),
                prefixIcon: Icon(Icons.tag_rounded, color: primaryGold),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkInputBg
                    : AppColors.lightInputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryGold, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
            },
            child: Text(
              Strings.cancel,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final id = textController.text.trim();
              if (id.isEmpty) {
                AppToast.showError(message: 'Please enter a valid Visitor ID');
                return;
              }
              Navigator.of(dialogCtx).pop(id);
            },
            child: const Text(
              'Verify Pass',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ).then((enteredId) {
      if (enteredId != null && enteredId.trim().isNotEmpty) {
        final visitorId =
            _extractVisitorId(enteredId.trim()) ?? enteredId.trim();
        _isProcessing = true;
        _lookupVisitor(visitorId);
      } else {
        // Cancelled, tapped outside, or went back via gesture
        _resumeScanner();
      }
    });
  }

  // ================= Build View =================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.goldLight : AppColors.primaryGold;
    final canPop = Navigator.of(context).canPop();

    if (_isCheckingPermission) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: primaryGold)),
      );
    }

    if (!_hasCameraPermission) {
      return _buildPermissionDeniedView(isDark, primaryGold);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Live Camera Preview
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.videocam_off_rounded,
                      size: 48,
                      color: AppColors.errorRed,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Camera error: ${error.errorCode.name}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),

          // 2. Custom Viewfinder Overlay with Animated Laser Beam
          AnimatedBuilder(
            animation: _scanAnimationController,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ScannerOverlayPainter(
                  scanProgress: _scanAnimationController.value,
                  primaryColor: primaryGold,
                ),
              );
            },
          ),

          // 3. Header Controls & Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (canPop)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Back',
                      ),
                    ),
                  if (canPop) const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          Strings.qrScanner,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          'Scan visitor gate pass',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Torch Toggle
                  ValueListenableBuilder<MobileScannerState>(
                    valueListenable: _scannerController,
                    builder: (context, state, child) {
                      final isTorchOn = state.torchState == TorchState.on;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: isTorchOn
                              ? primaryGold
                              : Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isTorchOn
                                ? Icons.flash_on_rounded
                                : Icons.flash_off_rounded,
                            color: isTorchOn ? Colors.black : Colors.white,
                            size: 20,
                          ),
                          onPressed: () => _scannerController.toggleTorch(),
                          tooltip: 'Toggle Flashlight',
                        ),
                      );
                    },
                  ),

                  // Camera Switch
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.cameraswitch_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => _scannerController.switchCamera(),
                      tooltip: 'Switch Camera',
                    ),
                  ),

                  // Manual ID Entry
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.keyboard_outlined,
                        color: primaryGold,
                        size: 20,
                      ),
                      onPressed: _showManualIdDialog,
                      tooltip: 'Enter Pass ID',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Bottom Instruction & Quick Entry Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.center_focus_strong_rounded,
                          size: 16,
                          color: primaryGold,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Align visitor QR code inside the frame',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _showManualIdDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: primaryGold.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryGold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            size: 17,
                            color: primaryGold,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Enter Pass ID manually',
                            style: TextStyle(
                              color: primaryGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedView(bool isDark, Color primaryGold) {
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkScaffoldBg
          : AppColors.lightScaffoldBg,
      appBar: AppBar(title: const Text('Camera Access')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 42,
                  color: AppColors.errorRed,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Camera Permission Required',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Camera access is required to scan visitor QR passes for check-in and check-out at checkpoints.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.settings_rounded, size: 18),
                label: const Text('Grant Camera Access'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  await openAppSettings();
                  _checkAndRequestPermission();
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _showManualIdDialog,
                child: Text(
                  'Or Enter Pass ID Manually',
                  style: TextStyle(
                    color: primaryGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= Custom Viewfinder Overlay Painter =================

class _ScannerOverlayPainter extends CustomPainter {
  final double scanProgress;
  final Color primaryColor;

  _ScannerOverlayPainter({
    required this.scanProgress,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const scanBoxSize = 260.0;
    final left = (size.width - scanBoxSize) / 2;
    final top = (size.height - scanBoxSize) / 2 - 20;
    final rect = Rect.fromLTWH(left, top, scanBoxSize, scanBoxSize);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    // Dark background mask with transparent scan window cutout
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRRect(rrect);
    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawPath(overlayPath, bgPaint);

    // Subtle window border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, borderPaint);

    // Luxury Golden Corner Brackets
    final cornerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const cornerLength = 26.0;
    const cornerRadius = 24.0;

    // Top-Left
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerRadius + cornerLength)
        ..lineTo(left, top + cornerRadius)
        ..quadraticBezierTo(left, top, left + cornerRadius, top)
        ..lineTo(left + cornerRadius + cornerLength, top),
      cornerPaint,
    );

    // Top-Right
    canvas.drawPath(
      Path()
        ..moveTo(left + scanBoxSize - cornerRadius - cornerLength, top)
        ..lineTo(left + scanBoxSize - cornerRadius, top)
        ..quadraticBezierTo(
          left + scanBoxSize,
          top,
          left + scanBoxSize,
          top + cornerRadius,
        )
        ..lineTo(left + scanBoxSize, top + cornerRadius + cornerLength),
      cornerPaint,
    );

    // Bottom-Left
    canvas.drawPath(
      Path()
        ..moveTo(left, top + scanBoxSize - cornerRadius - cornerLength)
        ..lineTo(left, top + scanBoxSize - cornerRadius)
        ..quadraticBezierTo(
          left,
          top + scanBoxSize,
          left + cornerRadius,
          top + scanBoxSize,
        )
        ..lineTo(left + cornerRadius + cornerLength, top + scanBoxSize),
      cornerPaint,
    );

    // Bottom-Right
    canvas.drawPath(
      Path()
        ..moveTo(
          left + scanBoxSize - cornerRadius - cornerLength,
          top + scanBoxSize,
        )
        ..lineTo(left + scanBoxSize - cornerRadius, top + scanBoxSize)
        ..quadraticBezierTo(
          left + scanBoxSize,
          top + scanBoxSize,
          left + scanBoxSize,
          top + scanBoxSize - cornerRadius,
        )
        ..lineTo(
          left + scanBoxSize,
          top + scanBoxSize - cornerRadius - cornerLength,
        ),
      cornerPaint,
    );

    // Animated Golden Laser Beam
    final laserY = top + (scanBoxSize * scanProgress);
    final laserPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          primaryColor.withValues(alpha: 0.0),
          primaryColor.withValues(alpha: 0.9),
          primaryColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(left + 12, laserY, scanBoxSize - 24, 2.5))
      ..strokeWidth = 2.5;

    canvas.drawLine(
      Offset(left + 14, laserY),
      Offset(left + scanBoxSize - 14, laserY),
      laserPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanProgress != scanProgress ||
        oldDelegate.primaryColor != primaryColor;
  }
}
