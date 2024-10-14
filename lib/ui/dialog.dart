import 'package:flutter/material.dart';


Future<bool?> showConfirmDialog(BuildContext context, String title, String message, String cancelButton, String okButton) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Text(cancelButton),
        ),
        FilledButton.tonal(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text(okButton),
        ),
      ],
    ),
  );
  return null;
}
