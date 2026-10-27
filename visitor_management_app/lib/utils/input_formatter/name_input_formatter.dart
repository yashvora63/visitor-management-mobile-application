import 'package:flutter/services.dart';

class NameInputFormatter extends TextInputFormatter {
  NameInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var formattedName = newValue.text;

    // Ensure first letter is capitalized
    if (formattedName.isNotEmpty) {
      formattedName =
          formattedName.substring(0, 1).toUpperCase() +
          formattedName.substring(1).toLowerCase();
    }

    return TextEditingValue(
      text: formattedName,
      selection: TextSelection.collapsed(offset: formattedName.length),
    );
  }
}
