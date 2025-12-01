import 'package:flutter/material.dart';
import 'package:tovi/tovi.dart';

/// Tovi Example
void main() {
  runApp(
    MaterialApp(
      title: 'Tovi Demo',
      home: Scaffold(
        backgroundColor: Colors.grey,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  autofocus: true,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [Tovi()],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
