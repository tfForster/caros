import 'package:flutter/material.dart';


Future<String?> showAlert(BuildContext context, String title, String placeholder, String cancelButton, String okButton, String defaultValue) async {
  final anwser = TextEditingController();
  anwser.text = defaultValue;
  bool ok = false;
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: anwser,
              autofocus: true,
              decoration: InputDecoration(
                hintText: placeholder
              )
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, '');
            },
            child: Text(cancelButton),
          ),
          FilledButton.tonal(
            onPressed: () {
              ok = true;
              Navigator.pop(context, anwser.text);
            },
            child: Text(okButton),
          )
        ],
      );
    },
  );
  if (ok) return anwser.text;
  return null;
}
