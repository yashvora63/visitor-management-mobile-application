import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class VisitorRegistrationScreen extends StatelessWidget {
  const VisitorRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.goldLight : AppColors.primaryGold;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Registration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_alt_1_rounded,
              size: 64,
              color: primaryGold,
            ),
            const SizedBox(height: 16),
            Text(
              'Visitor Registration Screen',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
