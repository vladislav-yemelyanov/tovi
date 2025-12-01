# Tovi

![Logo](https://github.com/vladislav-yemelyanov/tovi/blob/main/logo.png)

This package provides a single class for formatting user input in a text field in Dart/Flutter applications.

## Features

🐥 Effortless Number Formatting – automatically formats user input in real-time.

🐥 Custom Separators – choose your preferred thousands and decimal separators.

🐥 Decimal Control – limit decimal places and handle fractions seamlessly.

🐥 Smart Deletion – removes digits or separators without breaking the format.

🐥 Cursor-Friendly – keeps the caret in the right position as you type.

🐥 Plug & Play – works instantly with any Flutter TextField.

## Installation

1. Add the dependency

Open your pubspec.yaml and add the package:

```dart
dependencies:
  tovi: ^1.0.0
```

Then run:

```dart
flutter pub get
```

2. Import the package

In your Dart/Flutter file, import the formatter:

```dart
import 'package:tovi/tovi.dart';
```

3. Use in a TextField

Apply the Tovi formatter to any TextField using the inputFormatters property:

```dart
TextField(
  keyboardType: TextInputType.numberWithOptions(decimal: true),
  inputFormatters: [
    Tovi(
      thousandsSeparator: ",",
      decimalSeparator: ".",
      maxDecimals: 2,
    ),
  ],
  decoration: InputDecoration(
    labelText: "Enter amount",
  ),
)
```

💡 Tip: You can customize separators, enable/disable decimals, and set the maximum decimal precision to fit your use case.
