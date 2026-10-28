import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_section_card.dart';
import '../../widgets/app_dropdown_field.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../di/components/service_locator.dart';
import '../../widgets/app_instruction_banner.dart';
import '../../widgets/visitor_pass_bottom_sheet.dart';
import '../../models/visitors_list/visitors_model.dart';
import '../../stores/visitor_list/visitor_list_store.dart';
import '../../stores/visitor_registration/visitor_registration_store.dart';

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
  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _projectController;
  late final TextEditingController _purposeController;

  bool get _isEditing => widget.visitorToEdit != null;

  @override
  void initState() {
    super.initState();
    _registrationStore.initForm(visitor: widget.visitorToEdit);

    _nameController = TextEditingController(text: _registrationStore.name);
    _mobileController = TextEditingController(text: _registrationStore.mobile);
    _emailController = TextEditingController(text: _registrationStore.email);
    _projectController =
        TextEditingController(text: _registrationStore.project);
    _purposeController =
        TextEditingController(text: _registrationStore.purpose);

    _nameController.addListener(
      () => _registrationStore.setName(_nameController.text),
    );
    _mobileController.addListener(
      () => _registrationStore.setMobile(_mobileController.text),
    );
    _emailController.addListener(
      () => _registrationStore.setEmail(_emailController.text),
    );
    _projectController.addListener(
      () => _registrationStore.setProject(_projectController.text),
    );
    _purposeController.addListener(
      () => _registrationStore.setPurpose(_purposeController.text),
    );

    // Pre-fetch visitors to ensure accurate uniqueness checking
    if (_visitorListStore.visitorList.isEmpty) {
      _visitorListStore.getVisitorList();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _projectController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _mobileController.clear();
    _emailController.clear();
    _projectController.clear();
    _purposeController.clear();
    _registrationStore.resetForm();
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

    try {
      final created = await _registrationStore.submitForm(
        isEditing: _isEditing,
        existingId: widget.visitorToEdit?.id,
        existingCreatedAt: widget.visitorToEdit?.createdAt?.toIso8601String(),
        existingVisitors: _visitorListStore.visitorList,
      );

      if (!mounted) return;

      // Immediately update MobX store in memory for instant dashboard reactivity
      _visitorListStore.addOrUpdateVisitor(created);

      // Sync visitor list with server in real-time
      try {
        await _visitorListStore.getVisitorList();
      } catch (_) {}

      if (!mounted) return;

      widget.onRegistrationSuccess?.call();

      // Automatically clear form after successful submission so no manual clear/refresh is needed
      if (!_isEditing) {
        _resetForm();
      }

      VisitorPassBottomSheet.show(
        context: context,
        visitor: created,
        isEditing: _isEditing,
        onRegisterAnother: () {
          if (!_isEditing) {
            _resetForm();
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(
        message: _registrationStore.errorStore.errorMessage.isNotEmpty
            ? _registrationStore.errorStore.errorMessage
            : e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.goldLight : AppColors.primaryGold;
    final scaffoldBg = isDark
        ? AppColors.darkScaffoldBg
        : AppColors.lightScaffoldBg;
    final borderColor = isDark
        ? AppColors.darkCardBorder
        : AppColors.lightBorder;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                icon: Icon(Icons.refresh_rounded, color: primaryGold, size: 22),
                tooltip: 'Reset Form',
                onPressed: _resetForm,
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: Form(
              key: _formKey,
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  // Header Instruction Banner
                  AppInstructionBanner(
                    title: _isEditing
                        ? 'Modify Visitor Profile'
                        : 'New Visitor Onboarding',
                    description:
                        'Enter visitor details accurately. Upon registration, an identification QR code pass is automatically generated.',
                  ),

                  const SizedBox(height: 18),

                  // Section 1: Personal Information
                  AppSectionCard(
                    title: 'Personal Information',
                    icon: Icons.person_outline_rounded,
                    children: [
                      // Visitor Name (Required)
                      AppTextField(
                        controller: _nameController,
                        label: 'Visitor Name *',
                        hint: 'Enter full name',
                        icon: Icons.person_rounded,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
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
                      AppTextField(
                        controller: _mobileController,
                        label: 'Mobile Number *',
                        hint: '10-digit mobile number',
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
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
                      AppTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'visitor@example.com (Optional)',
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
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

                  // Section 2: Visit Information
                  AppSectionCard(
                    title: 'Visit Information',
                    icon: Icons.apartment_rounded,
                    children: [
                      // Visitor Type Dropdown (Customer, Vendor, Other)
                      Observer(
                        builder: (_) => AppDropdownField<String>(
                          label: 'Visitor Type *',
                          value: _registrationStore.selectedVisitorType,
                          icon: Icons.category_rounded,
                          items: _registrationStore.visitorTypes,
                          onChanged: (val) {
                            if (val != null) {
                              _registrationStore.setVisitorType(val);
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Project Input Field (Text Input instead of dropdown)
                      AppTextField(
                        controller: _projectController,
                        label: 'Project *',
                        hint: 'Enter project name',
                        icon: Icons.domain_rounded,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Project name is required.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      // Purpose of Visit (Required)
                      AppTextField(
                        controller: _purposeController,
                        label: 'Purpose of Visit *',
                        hint: 'e.g. Site Visit, Discussion, Meeting',
                        icon: Icons.assignment_rounded,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
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
                        children: _registrationStore.commonPurposes.map((p) {
                          final isSelected =
                              _purposeController.text.trim() == p;
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
                              _purposeController.text = p;
                              _registrationStore.setPurpose(p);
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
                                side: BorderSide(
                                  color: borderColor,
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              onPressed: isLoading ? null : _submitForm,
                              child: isLoading
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              isDark
                                                  ? AppColors.darkScaffoldBg
                                                  : Colors.white,
                                            ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
        ),
      ),
    );
  }
}
