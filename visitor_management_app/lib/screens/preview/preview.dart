import 'package:sizer/sizer.dart';
import '../../constants/colors.dart';
import '../../constants/strings.dart';
import 'package:flutter/material.dart';
import '../../di/components/service_locator.dart';
import '../bottom_navigation/bottom_navigation.dart';
import '../../stores/navigation/navigation_store.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  final NavigationStore _navigationStore = getIt<NavigationStore>();

  final List<OnboardingItem> _slides = const [
    OnboardingItem(
      badge: "SUMADHURA GUEST PASS",
      title: "Seamless Visitor\nRegistration",
      description:
          "Register visitors, clients, and vendors in seconds. Capture visit purpose, assign residential projects, and maintain structured records with smart validations.",
      icon: Icons.badge_outlined,
      accentColor: AppColors.primaryGold,
    ),
    OnboardingItem(
      badge: "DIGITAL PASSES",
      title: "Instant QR Code\nGeneration",
      description:
          "Automatically generate encrypted QR code passes upon successful registration. Display and share passes for contactless front-desk identification.",
      icon: Icons.qr_code_2_rounded,
      accentColor: AppColors.goldLight,
    ),
    OnboardingItem(
      badge: "REAL-TIME SECURITY",
      title: "Fast Check-In &\nLive Monitoring",
      description:
          "Scan visitor QR passes using device camera for 1-tap check-in and check-out. Monitor live on-site occupancy and statistics on your dashboard.",
      icon: Icons.verified_user_outlined,
      accentColor: AppColors.primaryGold,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await _navigationStore.saveNavigationRes(screenName: "bottom_navigation");
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const BottomNavigation(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _onNextPressed() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.goldLight : AppColors.primaryGold;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkScaffoldBg
          : AppColors.lightScaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Logo & Skip Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppColors.darkCardBg : Colors.white,
                          border: Border.all(
                            color: primaryGold.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryGold.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            "assets/icon/icon.png",
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.apartment_rounded,
                              color: primaryGold,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.5.w),
                      Text(
                        Strings.companyName,
                        style: TextStyle(
                          fontSize: 13.px,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < _totalPages - 1)
                    TextButton(
                      onPressed: _completeOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.5.h,
                        ),
                      ),
                      child: Text(
                        "Skip",
                        style: TextStyle(
                          fontSize: 11.px,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // Middle: Swipable PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: _totalPages,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),

                        // Visual Illustration Card with Gold Ring Accents
                        _buildHeroIllustration(slide, isDark, primaryGold),

                        const Spacer(),

                        // Badge Tag
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.5.w,
                            vertical: 0.6.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.goldContainerDark
                                : AppColors.goldContainerLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: primaryGold.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            slide.badge,
                            style: TextStyle(
                              fontSize: 9.px,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: primaryGold,
                            ),
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // Title
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 19.px,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),

                        SizedBox(height: 1.5.h),

                        // Description
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Text(
                            slide.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.5.px,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),

                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Controls
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.5.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Smooth Dots / Pill Indicator
                  Row(
                    children: List.generate(_totalPages, (index) {
                      final isSelected = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 7),
                        height: 7,
                        width: isSelected ? 26 : 7,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryGold
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.18)
                                    : Colors.black.withValues(alpha: 0.12)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),

                  // Next / Get Started Action Button
                  GestureDetector(
                    onTap: _onNextPressed,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                        horizontal: _currentPage == _totalPages - 1
                            ? 5.w
                            : 4.5.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryGold,
                            isDark ? AppColors.goldGlow : AppColors.goldDark,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: primaryGold.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == _totalPages - 1
                                ? "Get Started"
                                : "Next",
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkScaffoldBg
                                  : Colors.white,
                              fontSize: 11.5.px,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            _currentPage == _totalPages - 1
                                ? Icons.arrow_forward_rounded
                                : Icons.arrow_forward_ios_rounded,
                            size: 14.px,
                            color: isDark
                                ? AppColors.darkScaffoldBg
                                : Colors.white,
                          ),
                        ],
                      ),
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

  Widget _buildHeroIllustration(
    OnboardingItem slide,
    bool isDark,
    Color primaryGold,
  ) {
    return Container(
      width: 68.w,
      height: 28.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.darkCardBg : Colors.white,
        border: Border.all(
          color: primaryGold.withValues(alpha: 0.22),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGold.withValues(alpha: 0.12),
            blurRadius: 32,
            spreadRadius: 4,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Outer Ring
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppColors.goldContainerDark.withValues(alpha: 0.5)
                  : AppColors.goldContainerLight.withValues(alpha: 0.7),
            ),
          ),
          // Inner Glowing Icon
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  primaryGold.withValues(alpha: 0.2),
                  primaryGold.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: primaryGold.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Icon(slide.icon, size: 42.px, color: primaryGold),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String badge;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  const OnboardingItem({
    required this.badge,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}
