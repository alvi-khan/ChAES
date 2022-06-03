import 'package:flutter/material.dart';

class PasswordDialog extends StatelessWidget {
  const PasswordDialog({Key? key, required this.controller}) : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Colors.blueGrey.shade900,
      title: const Text(
          "Enter Password",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 20)
      ),
      content: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          isDense: true,
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueGrey.shade200)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        ),
        cursorColor: Colors.white,
        onSubmitted: (text) => Navigator.of(context).pop(),
        obscureText: true,
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              primary: Colors.blueGrey.shade400
            ),
            child: const Text("Submit"),
          ),
        )
      ],
      actionsPadding: const EdgeInsets.only(bottom: 20),
    );
  }
}