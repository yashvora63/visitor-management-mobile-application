import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final IconData icon;
  final List<T> items;
  final void Function(T?) onChanged;
  final Widget Function(T)? itemBuilder;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.items,
    required this.onChanged,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGold = isDark ? AppColors.goldLight : AppColors.primaryGold;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

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
                  ? itemBuilder!(item)
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
          dropdownColor: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: primaryGold,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              size: 20,
              color: textSecondary,
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
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
                color: primaryGold,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

