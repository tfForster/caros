import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';


Future<String?> showNotify(String text, Color color) async {
  BotToast.showCustomNotification(
    toastBuilder: (cancelFunc) {
      return Container(
        width: 600,
        height: 40,
        margin: const EdgeInsets.fromLTRB(0, 10, 10, 0),
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(8))
        ),
        child: Text(text),
      );
    },
    enableSlideOff: true,
    align: Alignment.topRight
  );
  return null;
}
