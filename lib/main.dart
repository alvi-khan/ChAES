import 'dart:async';
import 'dart:io';

import 'package:aes_decrypt/DragDropContainer.dart';
import 'package:aes_decrypt/LoadingIndicator.dart';
import 'package:aes_decrypt/PasswordDialog.dart';
import 'package:aes_decrypt/ToastHandler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  void setWindowSize() async {
    Size windowSize = const Size(500, 600);
    await DesktopWindow.setWindowSize(windowSize);
    await DesktopWindow.setMinWindowSize(windowSize);
    await DesktopWindow.setMaxWindowSize(windowSize);
  }

  @override
  Widget build(BuildContext context) {
    setWindowSize();
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyHomePage()
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool processing = false;
  int currentFile = 1;
  late ToastHandler toast;
  var crypt = AesCrypt();

  @override
  void initState() {
    super.initState();
    toast = ToastHandler(context);
    crypt.setOverwriteMode(AesCryptOwMode.rename);
  }

  Future<String> getPassword() async {
    TextEditingController controller = TextEditingController();
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PasswordDialog(controller: controller);
        }
    );
    return controller.text;
  }

  void processFiles(List<File> files) async {
    setState(() => processing = true);
    // allows time for UI to update
    await Future.delayed(const Duration(seconds: 1));

    String password = await getPassword();
    if (password.isNotEmpty)  crypt.setPassword(password);

    bool error = false;
    currentFile = 0;

    for (File file in files) {
      setState(() => currentFile = currentFile + 1);
      if (!file.path.endsWith(".aes")) {
        error = true;
        continue;
      }

      // compute isolates operation so main UI doesn't freeze
      await compute(crypt.decryptFileSync, file.path).catchError((err) {
        error = true;
        return "";
      });
    }

    setState(() => processing = false);
    error ? toast.error() : toast.success();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Container(
        child: processing ? const LoadingIndicator() :
        DragDropContainer(
            onDrag: (files) => processFiles(files)
        ),
      ),
    );
  }
}