import 'package:flutter/material.dart';

class ToastHandler {
  ToastHandler(this.context);
  BuildContext context;

  void error() {
    Color color = Colors.redAccent.shade400;
    String text = 'Failed to decrypt some files.';
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SnackBarContent(color: color, text: text),
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          duration: const Duration(seconds: 3),
    ));
  }

  void success() {
    Color color = Colors.tealAccent.shade700;
    String text = 'Operation successful.';
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SnackBarContent(color: color, text: text),
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          duration: const Duration(seconds: 3),
        ));
  }
}

class SnackBarContent extends StatelessWidget {
  const SnackBarContent({Key? key, required this.color, required this.text}) : super(key: key);

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            offset: Offset(0.0, 3.0), //(x,y)
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Text(text, textAlign: TextAlign.center),
    );
  }
}