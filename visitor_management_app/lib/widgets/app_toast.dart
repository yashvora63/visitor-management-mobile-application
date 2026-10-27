import 'dart:ui';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:visitor_management_app/constants/strings.dart';
import 'package:visitor_management_app/utils/device/device_utils.dart';
import 'package:visitor_management_app/utils/locale/app_localization.dart';

class AppToast {
  static OverlayEntry? _currentEntry;

  static void show({
    Color accentColor = Colors.red,
    required String title,
    required String subtitle,
    bool isTextColorChange = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final context = Strings.appNavigatorKey.currentContext;

    if (context == null) return;

    final overlay = Overlay.of(context);

    // Remove previous toast if exists
    _currentEntry?.remove();

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: DeviceUtils.responsive(context, mobile: 7.h, tablet: 24.px),
        left: 16,
        right: 16,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: DeviceUtils.responsive(
                context,
                mobile: 100.w,
                tablet: 450.px,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: _ToastCard(
                entry: entry,
                accentColor: accentColor,
                title: title,
                subtitle: subtitle,
                isTextColorChange: isTextColorChange,
              ),
            ),
          ),
        ),
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    Future.delayed(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
      if (_currentEntry == entry) {
        _currentEntry = null;
      }
    });
  }

  // SUCCESS
  static void showSuccess({
    required String message,
    String title = Strings.successTitleText,
  }) {
    show(accentColor: Colors.green, title: title, subtitle: message);
  }

  // ERROR
  static void showError({
    required String message,
    String title = Strings.errorTitleText,
  }) {
    show(accentColor: Colors.red, title: title, subtitle: message);
  }

  // WARNING
  static void showWarning({
    required String message,
    String title = Strings.warningTitleText,
  }) {
    show(accentColor: Colors.orange, title: title, subtitle: message);
  }
}

class _ToastCard extends StatefulWidget {
  final OverlayEntry entry;
  final Color accentColor;
  final String title;
  final String subtitle;
  final bool isTextColorChange;

  const _ToastCard({
    required this.entry,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.isTextColorChange,
  });

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        if (widget.entry.mounted) {
          widget.entry.remove();
        }
        if (AppToast._currentEntry == widget.entry) {
          AppToast._currentEntry = null;
        }
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                height: DeviceUtils.responsive(
                  context,
                  mobile: 72.px,
                  tablet: 76.px,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    195,
                    0,
                    0,
                    0,
                  ).withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: widget.accentColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      decoration: BoxDecoration(
                        color: widget.accentColor,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(
                              context,
                            ).translate(widget.title),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: DeviceUtils.responsive(
                                context,
                                mobile: 15.px,
                                tablet: 16.px,
                              ),
                              fontWeight: FontWeight.w700,
                              color: widget.accentColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: DeviceUtils.responsive(
                                context,
                                mobile: 13.px,
                                tablet: 14.px,
                              ),
                              color: widget.isTextColorChange
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
