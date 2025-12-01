import 'dart:math';
import 'package:flutter/services.dart';

/// Extension for safe list access by index.
/// Returns null if index is out of bounds instead of throwing an error.
extension SafeLookup<E> on List<E> {
  /// Returns the element at [index] or null if out of range.
  E? get(int index) {
    return (index >= 0 && index < length) ? this[index] : null;
  }
}

/// [Tovi] is a TextInputFormatter for numeric input with support for:
/// - thousands separators (thousandsSeparator)
/// - decimal separators (decimalSeparator)
/// - limiting decimal places (maxDecimals)
/// - automatic thousands grouping (applyThousandsGrouping)
/// - enabling/disabling decimal part (enableDecimal)
class Tovi extends TextInputFormatter {
  final String thousandsSeparator;
  final String decimalSeparator;
  final int maxDecimals;
  final bool applyThousandsGrouping;
  final bool enableDecimal;

  Tovi({
    this.thousandsSeparator = ",",
    this.decimalSeparator = ".",
    this.maxDecimals = 2,
    this.applyThousandsGrouping = true,
    this.enableDecimal = true,
  });

  /// Splits the input text into whole and fractional parts.
  /// Cleans all invalid characters except digits and separators.
  (String, String) getParts(String value) {
    final cleanedValue = value.replaceAll(RegExp(r'[^0-9\.,]'), '');
    final valueList = cleanedValue.split("");

    final List<String> wholeItems = [];
    final List<String> fractionItems = [];

    bool isDecimal = false;

    for (final item in valueList) {
      if (item == decimalSeparator) {
        isDecimal = true;
        continue;
      }

      if (isDecimal) {
        if (fractionItems.length >= maxDecimals) {
          break;
        }
        fractionItems.add(item);
      } else {
        wholeItems.add(item);
      }
    }

    return (wholeItems.join(""), fractionItems.join(""));
  }

  /// Formats the whole part of the number with thousands separators.
  String formatThousands(List<String> wholeList) {
    List<String> result = [];
    bool needsInserted = false;

    for (final (i, s) in wholeList.reversed.indexed) {
      final remainder = (i + 1) % 3;

      if (needsInserted) {
        result.add(thousandsSeparator);
        result.add(s);
        needsInserted = false;
      } else {
        result.add(s);
      }

      if (remainder == 0) {
        needsInserted = true;
      }
    }

    return result.reversed.join("");
  }

  int? decimalSeparatorIndex;

  /// Adjusts the cursor position after text formatting.
  /// Considers changes in whole and fractional parts and added/removed separators.
  TextEditingValue correctOffset({
    required String newWhole,
    required String newFraction,
    required String oldWhole,
    required String oldFraction,
    required TextEditingValue oldValue,
    required TextEditingValue newValue,
  }) {
    final wholeDiff = newWhole.length - oldWhole.length;
    final fractionDiff = newFraction.length - oldFraction.length;
    final diff = wholeDiff + fractionDiff;
    int offset = oldValue.selection.end + diff;

    String text = newWhole;

    if (newValue.text.contains(decimalSeparator)) {
      text =
          "$newWhole$decimalSeparator${newFraction.replaceAll(RegExp(r"[.,]"), "")}";
    }

    final oldDecimalSepsCount = oldValue.text
        .split("")
        .where((e) => e == decimalSeparator)
        .length;

    final newDecimalSepsCount = newValue.text
        .split("")
        .where((e) => e == decimalSeparator)
        .length;

    final decimalSepsDiff = newDecimalSepsCount - oldDecimalSepsCount;

    if (decimalSepsDiff == 1) {
      offset += 1;
    }

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: min(offset, text.length)),
    );
  }

  /// Checks if a specific symbol (like thousands separator) was removed.
  /// [s1] - old text, [s2] - new text, [symbol] - symbol to check.
  bool isRemovedSymbol(String s1, String s2, String symbol) {
    bool removed = false;

    final s1Count = s1.split("").where((e) => e == symbol).length;
    final s2Count = s2.split("").where((e) => e == symbol).length;
    final symbolsDiff = s1Count - s2Count;
    final s2Splitted = s2.split("");
    final lenDiff = s1.length - s2.length;

    if (symbolsDiff == 1 && lenDiff == 1) {
      for (int i = 0; i < s1.length; i++) {
        final oldSymbol = s1[i];
        final newSymbol = s2Splitted.get(i);
        if (oldSymbol != newSymbol && oldSymbol == symbol) {
          removed = true;
          break;
        }
      }
    }

    return removed;
  }

  /// Main method that formats text on user input changes.
  /// Applies thousands separators to the whole part and adjusts the cursor.
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final (oldWhole, oldFraction) = getParts(oldValue.text);
    final (newWhole, newFraction) = getParts(newValue.text);

    List<String> cleanedWholeList = newWhole
        .replaceAll(thousandsSeparator, "")
        .split("");

    // Handle removal of separator symbols
    if (isRemovedSymbol(oldValue.text, newValue.text, thousandsSeparator)) {
      final indx = newValue.selection.end - 1;
      if (indx > -1) {
        cleanedWholeList.removeAt(indx);
      }
    }

    final formattedNewWhole = formatThousands(cleanedWholeList);

    return correctOffset(
      newWhole: formattedNewWhole,
      newFraction: newFraction,
      oldWhole: oldWhole,
      oldFraction: oldFraction,
      oldValue: oldValue,
      newValue: newValue,
    );
  }
}
