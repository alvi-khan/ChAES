import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chaes/DragDropContainer.dart';
import 'package:chaes/LoadingIndicator.dart';
import 'package:chaes/PasswordDialog.dart';
import 'package:chaes/ToastHandler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:cryptography/cryptography.dart';
import 'package:crypto/crypto.dart';

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
  var crypt = AesCrypt();
  var algorithm = Xchacha20.poly1305Aead();
  String password = "";

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

  Future<bool> encrypt(File file) async {
    if (!encrypting)  return false;
    if (useAes) {
      if (file.path.endsWith(".aes"))  return false;
      await compute(crypt.encryptFileSync, file.path);
    } else {
      if (file.path.endsWith(".enc")) return false;
      var secretKey = await algorithm.newSecretKeyFromBytes(sha256.convert(utf8.encode(password)).bytes);
      var secretBox = await algorithm.encrypt(await file.readAsBytes(), secretKey: secretKey);
      File out = File("${file.path}.enc");
      await out.writeAsBytes(secretBox.concatenation());
    }
    return true;
  }

  Future<bool> decrypt(File file) async {
    if (encrypting) return false;
    if (useAes) {
      if (!file.path.endsWith(".aes"))  return false;
      await compute(crypt.decryptFileSync, file.path);
    } else {
      if (!file.path.endsWith(".enc"))  return false;
      var secretKey = await algorithm.newSecretKeyFromBytes(sha256.convert(utf8.encode(password)).bytes);
      SecretBox secretBox = SecretBox.fromConcatenation(
          await file.readAsBytes(),
          nonceLength: algorithm.nonceLength,
          macLength: algorithm.macAlgorithm.macLength
      );
      var data = await algorithm.decrypt(secretBox, secretKey: secretKey);
      File out = File(file.path.substring(0, file.path.length - 4));
      await out.writeAsBytes(data);
    }
    return true;
  }

  void processFiles(List<File> files) async {
    setState(() => totalFiles = files.length);
    setState(() => processing = true);
    // allows time for UI to update
    await Future.delayed(const Duration(seconds: 1));

    bool success = false;
    currentFile = 0;

    String password = await getPassword();
    if (password.isNotEmpty) {
      crypt.setPassword(password);
      this.password = password;
    }
    else {
      setState(() => processing = false);
      toast.error();
      return;
    }

    for (File file in files) {
      setState(() => currentFile = currentFile + 1);
      success = encrypting ? await encrypt(file) : await decrypt(file);
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
                      onChanged: (useAes) => setState(() => this.useAes = useAes),
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
