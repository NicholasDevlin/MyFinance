import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandSeparatorInputFormatter extends TextInputFormatter {
  static final NumberFormat _formatter = NumberFormat('#,##0.##');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // If empty, return as is
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Extract only digits and a single decimal
    String raw = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');

    // Allow trailing decimal dot: "123."
    bool hasTrailingDot = raw.endsWith('.');

    // Split into integer and decimals
    List<String> parts = raw.split('.');

    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';

    // Prevent multiple decimals
    if (parts.length > 2) {
      integerPart = parts[0];
      decimalPart = parts.sublist(1).join('');
    }

    // Format the integer part only
    String formattedInteger = '';
    if (integerPart.isNotEmpty) {
      formattedInteger = _formatter.format(int.parse(integerPart)); // integer only
    }

    // Build final formatted text
    String formatted;

    if (decimalPart.isNotEmpty) {
      formatted = '$formattedInteger.$decimalPart';
    } else if (hasTrailingDot) {
      formatted = '$formattedInteger.';
    } else {
      formatted = formattedInteger;
    }

    // Cursor: place at end (most stable option)
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Get the numeric value (double)
  static double? getNumericValue(String formattedText) {
    String digitsOnly = formattedText.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(digitsOnly);
  }
}

/// Controller extension
extension ThousandSeparatorController on TextEditingController {
  double? get numericValue => ThousandSeparatorInputFormatter.getNumericValue(text);

  void setNumericValue(double value) {
    text = NumberFormat('#,##0.##').format(value);
  }
}