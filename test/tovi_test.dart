import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tovi/tovi.dart';

void main() {
  group('Tovi', () {
    final f = Tovi();

    test("adds comma on increase", () {
      final oldValue = TextEditingValue(text: "100");
      final newValue = TextEditingValue(text: "1000");
      final value = f.formatEditUpdate(oldValue, newValue);

      expect(value.text, equals("1,000"));
    });

    test("deletes comma correctly", () {
      final oldValue = TextEditingValue(
        text: "1,100",
        selection: TextSelection.collapsed(offset: 2),
      );
      final newValue = TextEditingValue(
        text: "1100",
        selection: TextSelection.collapsed(offset: 1),
      );
      final value = f.formatEditUpdate(oldValue, newValue);

      expect(value.text, equals("100"));
    });

    test("typing digit at end", () {
      final oldValue = TextEditingValue(text: "1,234");
      final newValue = TextEditingValue(text: "1,2345");
      final value = f.formatEditUpdate(oldValue, newValue);

      expect(value.text, "12,345");
    });

    test("typing digit in the middle", () {
      final oldValue = TextEditingValue(
        text: "12,345",
        selection: TextSelection.collapsed(offset: 2),
      );
      final newValue = TextEditingValue(
        text: "123,45",
        selection: TextSelection.collapsed(offset: 3),
      );

      final value = f.formatEditUpdate(oldValue, newValue);
      expect(
        value.text,
        "123,45".replaceAll(",", "").length == 5 ? "12,345" : "12345",
      );
    });

    test("delete from middle", () {
      final oldValue = TextEditingValue(
        text: "12,345",
        selection: TextSelection.collapsed(offset: 3),
      );

      final newValue = TextEditingValue(
        text: "12,45",
        selection: TextSelection.collapsed(offset: 2),
      );

      final value = f.formatEditUpdate(oldValue, newValue);
      expect(value.text, "1,245");
    });

    test("delete last digit", () {
      final oldValue = TextEditingValue(
        text: "1,234",
        selection: TextSelection.collapsed(offset: 5),
      );

      final newValue = TextEditingValue(
        text: "1,23",
        selection: TextSelection.collapsed(offset: 4),
      );

      final value = f.formatEditUpdate(oldValue, newValue);
      expect(value.text, "123");
    });

    test("paste plain digits", () {
      final oldValue = TextEditingValue(text: "");
      final newValue = TextEditingValue(
        text: "123456",
        selection: TextSelection.collapsed(offset: 6),
      );

      final value = f.formatEditUpdate(oldValue, newValue);
      expect(value.text, "123,456");
    });

    test("paste with commas", () {
      final oldValue = TextEditingValue(text: "");
      final newValue = TextEditingValue(
        text: "1,234,567",
        selection: TextSelection.collapsed(offset: 9),
      );

      final value = f.formatEditUpdate(oldValue, newValue);
      expect(value.text, "1,234,567");
    });

    test("paste in middle of number", () {
      final oldValue = TextEditingValue(
        text: "12,345",
        selection: TextSelection.collapsed(offset: 3),
      );

      final newValue = TextEditingValue(
        text: "12,999345",
        selection: TextSelection.collapsed(offset: 6),
      );

      final value = f.formatEditUpdate(oldValue, newValue);
      expect(
        value.text,
        "129,993,45".replaceAll(",", "").length > 6 ? "12,999,345" : value.text,
      );
    });

    test("replace selection", () {
      final oldValue = TextEditingValue(
        text: "12,345",
        selection: TextSelection(baseOffset: 0, extentOffset: 2),
      );

      final newValue = TextEditingValue(
        text: "99,345",
        selection: TextSelection.collapsed(offset: 2),
      );

      final value = f.formatEditUpdate(oldValue, newValue);
      expect(value.text, "99,345");
    });

    test("replace middle selection", () {
      final oldValue = TextEditingValue(
        text: "12,345",
        selection: TextSelection(baseOffset: 1, extentOffset: 4),
      );

      final newValue = TextEditingValue(
        text: "145",
        selection: TextSelection.collapsed(offset: 1),
      );

      final value = f.formatEditUpdate(oldValue, newValue);
      expect(value.text, "145");
    });

    test("empty -> digit", () {
      final value = f.formatEditUpdate(
        TextEditingValue(text: ""),
        TextEditingValue(text: "5"),
      );

      expect(value.text, "5");
    });

    test("very long number", () {
      final newValue = TextEditingValue(
        text: "123456789012345",
        selection: TextSelection.collapsed(offset: 15),
      );

      final value = f.formatEditUpdate(TextEditingValue(text: ""), newValue);

      expect(value.text, "123,456,789,012,345");
    });

    test("letters ignored", () {
      final value = f.formatEditUpdate(
        TextEditingValue(text: ""),
        TextEditingValue(text: "123a45"),
      );

      expect(value.text, "12,345");
    });

    test("symbols ignored", () {
      final value = f.formatEditUpdate(
        TextEditingValue(text: "1,000"),
        TextEditingValue(text: "1,00@0"),
      );

      expect(value.text, "1,000");
    });
  });
}
