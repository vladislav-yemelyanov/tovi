import 'package:flutter/material.dart';
import 'package:tovi/tovi.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  TextEditingController controller = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              autofocus: true,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                value = value.replaceAll(",", "");

                final formatted = Tovi().formatEditUpdate(
                  TextEditingValue(),
                  TextEditingValue(text: value),
                );
                controller.text = formatted.text;
              },
              inputFormatters: [Tovi()],
            ),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [Tovi()],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tovi Example
void main() {
  runApp(
    MaterialApp(
      title: 'Tovi Demo',
      home: Scaffold(backgroundColor: Colors.grey, body: MyWidget()),
    ),
  );
}
