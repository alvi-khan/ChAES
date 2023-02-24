import 'dart:convert';
import 'dart:io';

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:chaes/PasswordDialog.dart';

enum EncryptionAlgorithm {
  aes, xchacha
}

class EncryptionUtils {
  String password = "";
  EncryptionAlgorithm algorithm = EncryptionAlgorithm.xchacha;
  Xchacha20 xchachaCrypt = Xchacha20.poly1305Aead();
  AesCrypt aesCrypt = AesCrypt();

  EncryptionUtils() {
    aesCrypt.setOverwriteMode(AesCryptOwMode.rename);
  }

  Future<bool> setPassword(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PasswordDialog(controller: controller);
        }
    );
    var password = controller.text;
    if (password.isNotEmpty) {
      this.password = password;
      aesCrypt.setPassword(password);
    } else {
      return false;
    }
    return true;
  }

  void setEncryptionAlgorithm(EncryptionAlgorithm algorithm) {
    this.algorithm = algorithm;
  }

  Future<bool> encrypt(File file) async {
    if (algorithm == EncryptionAlgorithm.aes) {
      if (file.path.endsWith(".aes"))  return false;
      aesCrypt.setPassword(password);
      await aesCrypt.encryptFile(file.path);
      return true;
    } else if (algorithm == EncryptionAlgorithm.xchacha) {
      if (file.path.endsWith(".enc")) return false;
      var secretKey = await xchachaCrypt.newSecretKeyFromBytes(sha256.convert(utf8.encode(password)).bytes);
      var contents = await file.readAsBytes();
      var secretBox = await xchachaCrypt.encrypt(contents, secretKey: secretKey);
      File out = File("${file.path}.enc");
      await out.writeAsBytes(secretBox.concatenation());
      return true;
    }
    return false;
  }

  Future<bool> decrypt(File file) async {
    if (algorithm == EncryptionAlgorithm.aes) {
      if (!file.path.endsWith(".aes"))  return false;
      await aesCrypt.decryptFile(file.path);
      return true;
    } else if (algorithm == EncryptionAlgorithm.xchacha) {
      if (!file.path.endsWith(".enc"))  return false;
      var secretKey = await xchachaCrypt.newSecretKeyFromBytes(sha256.convert(utf8.encode(password)).bytes);
      SecretBox secretBox = SecretBox.fromConcatenation(
          await file.readAsBytes(),
          nonceLength: xchachaCrypt.nonceLength,
          macLength: xchachaCrypt.macAlgorithm.macLength
      );
      var data = await xchachaCrypt.decrypt(secretBox, secretKey: secretKey);
      File out = File(file.path.substring(0, file.path.length - 4));
      await out.writeAsBytes(data);
    }
    return true;
  }
}