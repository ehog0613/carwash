import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CwDialogs {
  static void exitAlert(BuildContext context, String msg) {
    var repStr = "Exception:";
    if (msg.startsWith(repStr)) msg = msg.substring(repStr.length);
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(msg),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                exit(0);
              },
            ),
          ],
        );
      },
    );
  }

  static void alert(BuildContext context, String msg,
      [VoidCallback? callBack]) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(msg),
          actions: <Widget>[
            TextButton(
              child: Text((callBack == null ? "Close" : "확인")),
              onPressed: () {
                Navigator.pop(context);
                if (callBack != null) {
                  callBack.call();
                }
              },
            ),
          ],
        );
      },
    );
  }

  static void alertLogin(BuildContext context, String msg) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(msg),
          actions: <Widget>[
            TextButton(
              child: const Text("확인"),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/login", (route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  static modalLoading(BuildContext context, [String? msg]) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return Dialog(
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // The loading indicator
                  const CircularProgressIndicator(),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(msg ?? "Loading...")
                ],
              ),
            ),
          );
        });
  }
}
