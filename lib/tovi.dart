import 'dart:math';

import 'package:flutter/services.dart';

extension SafeLookup<E> on List<E> {
  E? get(int index) {
    return (index >= 0 && index < length) ? this[index] : null;
  }
}

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

  bool isRemovedSymbol(String s1, String s2, String symbol) {
    // s1 - old text
    // s2 - new text

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

    // whole - 1,000,000
    // fraction - 00

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
