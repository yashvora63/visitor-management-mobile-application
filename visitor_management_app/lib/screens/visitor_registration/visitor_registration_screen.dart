import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../di/components/service_locator.dart';
import '../../models/visitors_list/visitors_model.dart';
import '../../stores/visitor_list/visitor_list_store.dart';
import '../../stores/visitor_registration/visitor_registration_store.dart';
import '../../widgets/app_toast.dart';
import '../visitor_detail/visitor_detail_screen.dart';

class VisitorRegistrationScreen extends StatefulWidget {
  final VisitorListModel? visitorToEdit;
  final VoidCallback? onRegistrationSuccess;

  const VisitorRegistrationScreen({
    super.key,
    this.visitorToEdit,
    this.onRegistrationSuccess,
  });

  @override
  State<VisitorRegistrationScreen> createState() =>
      _VisitorRegistrationScreenState();
}

class _VisitorRegistrationScreenState extends State<VisitorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final VisitorRegistrationStore _registrationStore =
      getIt<VisitorRegistrationStore>();
  final VisitorListStore _visitorListStore = getIt<VisitorListStore>();

  // Controllers
  late final TextEditingController _idController;
  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _purposeController;

  // Form selections
  String _selectedVisitorType = 'Customer';
  String _selectedProject = 'Project A';
  String _selectedStatus = Strings.statusRegistered;

  final List<String> _visitorTypes = const ['Customer', 'Vendor', 'Other'];
  final List<String> _projects = const [
    'Project A',
    'Project B',
    'Project C',
    'Project D',
  ];
  final List<String> _statuses = const [
    Strings.statusRegistered,
    Strings.statusCheckedIn,
    Strings.statusCheckedOut,
  ];

  final List<String> _commonPurposes = const [
    'Site Visit',
    'Meeting',
    'Delivery',
    'Maintenance',
    'Interview',
    'Client Discussion',
  ];

  bool get _isEditing => widget.visitorToEdit != null;

  @override
  void initState() {
    super.initState();
    final visitor = widget.visitorToEdit;

    _idController = TextEditingController(
      text: visitor?.id ?? _generateDefaultVisitorId(),
    );
    _nameController = TextEditingController(text: visitor?.name ?? '');
    _mobileController = TextEditingController(text: visitor?.mobile ?? '');
    _emailController = TextEditingController(text: visitor?.email ?? '');
    _purposeController = TextEditingController(text: visitor?.purpose ?? '');

    if (visitor != null) {
      if (_visitorTypes.contains(visitor.visitorType)) {
        _selectedVisitorType = visitor.visitorType;
      }
      if (_projects.contains(visitor.project)) {
        _selectedProject = visitor.project;
      }
      if (_statuses.contains(visitor.status)) {
        _selectedStatus = visitor.status;
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  String _generateDefaultVisitorId() {
    final rand = 100 + Random().nextInt(900);
    return 'VIS$rand';
  }

  void _regenerateId() {
    setState(() {
      _idController.text = _generateDefaultVisitorId();
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _idController.text = _generateDefaultVisitorId();
      _nameController.clear();
      _mobileController.clear();
      _emailController.clear();
      _purposeController.clear();
      _selectedVisitorType = 'Customer';
      _selectedProject = 'Project A';
      _selectedStatus = Strings.statusRegistered;
    });
    _registrationStore.reset();
  }

  Future<void> _submitForm() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      AppToast.showError(
        message: 'Please resolve form validation errors before saving.',
      );
      return;
    }

    final createdAt = _isEditing && widget.visitorToEdit?.createdAt != null
        ? widget.visitorToEdit!.createdAt!.toIso8601String()
        : DateTime.now().toIso8601String();

    // Construct request payload as per requirements:
    // check_in_time and check_out_time should be empty (null)
    final payload = <String, dynamic>{
      'id': _idController.text.trim(),
      'name': _nameController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'email': _emailController.text.trim(),
      'visitor_type': _selectedVisitorType,
      'project': _selectedProject,
      'purpose': _purposeController.text.trim(),
      'status': _selectedStatus,
      'created_at': createdAt,
      'check_in_time': null,
      'check_out_time': null,
    };

    try {
      VisitorListModel? result;
      if (_isEditing) {
        result = await _registrationStore.updateVisitor(
          widget.visitorToEdit!.id,
          payload,
        );
      } else {
        result = await _registrationStore.registerVisitor(payload);
      }

      if (!mounted) return;

      // Sync visitor list & dashboard stats in real-time
      try {
        await _visitorListStore.getVisitorList();
      } catch (_) {}

      widget.onRegistrationSuccess?.call();

      final created =
          result ??
          VisitorListModel(
            id: payload['id'],
            name: payload['name'],
            mobile: payload['mobile'],
            email: payload['email'],
            visitorType: payload['visitor_type'],
            project: payload['project'],
            purpose: payload['purpose'],
            status: payload['status'],
            createdAt: DateTime.tryParse(createdAt),
            checkInTime: null,
            checkOutTime: null,
          );

      _showSuccessConfirmationDialog(created);
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(
        message: _registrationStore.errorStore.errorMessage.isNotEmpty
            ? _registrationStore.errorStore.errorMessage
            : e.toString(),
      );
    }
  }

  void _showSuccessConfirmationDialog(VisitorListModel visitor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.goldLight : AppColors.primaryGold;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                _isEditing
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
                  color: isDark
                      ? AppColors.darkScaffoldBg
                      : AppColors.lightInputBg,
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
                              color: AppColors.warningAmber,
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
                        if (!_isEditing) {
                          _resetForm();
                        } else if (Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        _isEditing ? 'Done' : 'Register Another',
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
                        foregroundColor: isDark
                            ? AppColors.darkScaffoldBg
                            : Colors.white,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.goldLight : AppColors.primaryGold;
    final scaffoldBg =
        isDark ? AppColors.darkScaffoldBg : AppColors.lightScaffoldBg;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
    final borderColor =
        isDark ? AppColors.darkCardBorder : AppColors.lightBorder;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: _isEditing && Navigator.canPop(context)
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: textPrimary,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? Strings.editVisitor : Strings.registerVisitor,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _isEditing
                  ? 'Update registered visitor record'
                  : 'Front-desk visitor check-in pass creation',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: primaryGold,
                size: 22,
              ),
              tooltip: 'Reset Form',
              onPressed: _resetForm,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Header Instruction Banner
              _buildInstructionBanner(
                isDark: isDark,
                primaryGold: primaryGold,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),

              const SizedBox(height: 18),

              // Section 1: Identification & Status
              _buildSectionCard(
                title: 'Pass Identification & Status',
                icon: Icons.badge_outlined,
                primaryGold: primaryGold,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                children: [
                  // Visitor ID Field
                  _buildTextFormField(
                    controller: _idController,
                    label: 'Visitor ID *',
                    hint: 'e.g. VIS005',
                    icon: Icons.tag_rounded,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    suffixIcon: !_isEditing
                        ? IconButton(
                            icon: Icon(
                              Icons.auto_mode_rounded,
                              color: primaryGold,
                              size: 20,
                            ),
                            tooltip: 'Generate Random ID',
                            onPressed: _regenerateId,
                          )
                        : null,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Visitor ID is required.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  // Status Dropdown
                  _buildDropdownField<String>(
                    label: 'Status *',
                    value: _selectedStatus,
                    icon: Icons.info_outline_rounded,
                    items: _statuses,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedStatus = val;
                        });
                      }
                    },
                    itemBuilder: (status) {
                      final color = _getStatusColor(status);
                      return Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Section 2: Visitor Details
              _buildSectionCard(
                title: 'Personal Information',
                icon: Icons.person_outline_rounded,
                primaryGold: primaryGold,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                children: [
                  // Visitor Name (Required)
                  _buildTextFormField(
                    controller: _nameController,
                    label: 'Visitor Name *',
                    hint: 'Enter full name',
                    icon: Icons.person_rounded,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Visitor name is required.';
                      }
                      if (val.trim().length < 2) {
                        return 'Name must be at least 2 characters.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  // Mobile Number (Numeric, Required, exactly 10 digits)
                  _buildTextFormField(
                    controller: _mobileController,
                    label: 'Mobile Number *',
                    hint: '10-digit mobile number',
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Mobile number is required.';
                      }
                      final digits = val.trim();
                      if (digits.length != 10) {
                        return 'Mobile number must be exactly 10 digits.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  // Email Address (Optional, validate when entered)
                  _buildTextFormField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'visitor@example.com (Optional)',
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return null; // Optional
                      }
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(val.trim())) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Section 3: Visit Information
              _buildSectionCard(
                title: 'Visit Information',
                icon: Icons.apartment_rounded,
                primaryGold: primaryGold,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                children: [
                  // Visitor Type Dropdown (Customer, Vendor, Other)
                  _buildDropdownField<String>(
                    label: 'Visitor Type *',
                    value: _selectedVisitorType,
                    icon: Icons.category_rounded,
                    items: _visitorTypes,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedVisitorType = val;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 14),

                  // Project Dropdown (Project A, Project B, Project C, Project D)
                  _buildDropdownField<String>(
                    label: 'Project *',
                    value: _selectedProject,
                    icon: Icons.domain_rounded,
                    items: _projects,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedProject = val;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 14),

                  // Purpose of Visit (Required)
                  _buildTextFormField(
                    controller: _purposeController,
                    label: 'Purpose of Visit *',
                    hint: 'e.g. Site Visit, Discussion, Meeting',
                    icon: Icons.assignment_rounded,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Purpose of visit is required.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  // Quick Purpose Selection Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _commonPurposes.map((p) {
                      final isSelected = _purposeController.text.trim() == p;
                      return ActionChip(
                        label: Text(
                          p,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected ? primaryGold : textSecondary,
                          ),
                        ),
                        backgroundColor: isSelected
                            ? primaryGold.withValues(alpha: 0.15)
                            : isDark
                                ? AppColors.darkInputBg
                                : AppColors.lightInputBg,
                        side: BorderSide(
                          color: isSelected
                              ? primaryGold
                              : isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                          width: 0.8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onPressed: () {
                          setState(() {
                            _purposeController.text = p;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Form Action Buttons
              Observer(
                builder: (_) {
                  final isLoading = _registrationStore.loading;

                  return Row(
                    children: [
                      // Cancel / Reset Button
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textPrimary,
                            side: BorderSide(color: borderColor, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_isEditing &&
                                      Navigator.canPop(context)) {
                                    Navigator.of(context).pop();
                                  } else {
                                    _resetForm();
                                  }
                                },
                          child: Text(
                            _isEditing ? Strings.cancel : 'Clear',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Submit Button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGold,
                            foregroundColor: isDark
                                ? AppColors.darkScaffoldBg
                                : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: isLoading ? null : _submitForm,
                          child: isLoading
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDark
                                          ? AppColors.darkScaffoldBg
                                          : Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isEditing
                                          ? Icons.save_rounded
                                          : Icons.person_add_rounded,
                                      size: 19,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isEditing
                                          ? 'Update Visitor'
                                          : Strings.registerVisitor,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ================= Form Helper Widgets =================

  Widget _buildInstructionBanner({
    required bool isDark,
    required Color primaryGold,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : AppColors.primaryGold.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.how_to_reg_rounded,
              color: primaryGold,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing
                      ? 'Modify Visitor Profile'
                      : 'New Visitor Onboarding',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Enter visitor details accurately. Upon registration, an identification QR code pass is automatically generated.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color primaryGold,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: primaryGold),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          validator: validator,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: textSecondary.withValues(alpha: 0.7),
            ),
            prefixIcon: Icon(icon, size: 20, color: textSecondary),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor:
                isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? AppColors.goldLight : AppColors.primaryGold,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.errorRed,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.errorRed,
                width: 1.5,
              ),
            ),
            errorStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.errorRed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required IconData icon,
    required List<T> items,
    required bool isDark,
    required Color textPrimary,
    required void Function(T?) onChanged,
    Widget Function(T)? itemBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: itemBuilder != null
                  ? itemBuilder(item)
                  : Text(
                      item.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor:
              isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? AppColors.goldLight : AppColors.primaryGold,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              size: 20,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            filled: true,
            fillColor:
                isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? AppColors.goldLight : AppColors.primaryGold,
                width: 1.5,
              ),
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
}

