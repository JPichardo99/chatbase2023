import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackbar(BuildContext contex, String msg, Color color) {
    ScaffoldMessenger.of(contex).showSnackBar(SnackBar(
      content: Text(msg, style: TextStyle(fontFamily: 'Poppins')),
      duration: Duration(seconds: 2),
      backgroundColor: color.withOpacity(0.8),
    ));
  }
}
