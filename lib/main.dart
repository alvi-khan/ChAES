import 'dart:async';
import 'dart:io';

import 'package:chaes/DragDropContainer.dart';
import 'package:chaes/EncryptionUtils.dart';
import 'package:chaes/LoadingIndicator.dart';
import 'package:chaes/ToastHandler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';

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
  bool encrypting = false;
  bool useAes = false;
  int currentFile = 1;
  int totalFiles = 0;
  late ToastHandler toast;
  EncryptionUtils encryptionUtils = EncryptionUtils();

  @override
  void initState() {
    super.initState();
    toast = ToastHandler(context);
  }

  void processFiles(List<File> files) async {
    setState(() => totalFiles = files.length);
    setState(() => processing = true);
    // allows time for UI to update
    await Future.delayed(const Duration(seconds: 1));

    bool success = false;
    currentFile = 0;

    bool havePassword = await encryptionUtils.setPassword(context);
    if (!havePassword) {
      setState(() => processing = false);
      toast.error();
      return;
    }

    for (File file in files) {
      setState(() => currentFile = currentFile + 1);
      success = await compute(encrypting ? encryptionUtils.encrypt : encryptionUtils.decrypt, file);
    }

    setState(() => processing = false);
    success ? toast.success() : toast.error();
    setState(() => currentFile = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Container(
        child: processing ? LoadingIndicator(current: currentFile, total: totalFiles) :
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              DragDropContainer(
                  onDrag: (files) => processFiles(files),
                  encrypting: encrypting,
                  onToggle: (encrypting) => setState(() => this.encrypting = encrypting)
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Use AES Algorithm',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: useAes,
                      onChanged: (useAes) {
                        setState(() => this.useAes = useAes);
                        encryptionUtils.setEncryptionAlgorithm(useAes ? EncryptionAlgorithm.aes : EncryptionAlgorithm.xchacha);
                      },
                      activeColor: Colors.blue.shade200,
                    ),
                  ),
                  const SizedBox(width: 10  , height: 1),
                ],
              ),
              const SizedBox(width: 1, height: 10),
            ]
        )
      ),
    );
  }
}
