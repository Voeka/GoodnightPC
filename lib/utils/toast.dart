import 'package:flutter/material.dart';

void showCustomToast(GlobalKey<ScaffoldMessengerState> key, String message) {
  key.currentState?.hideCurrentSnackBar();
  key.currentState?.showSnackBar(
    SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => key.currentState?.hideCurrentSnackBar(),
          ),
        ],
      ),
      backgroundColor: Colors.black87,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      duration: const Duration(seconds: 5),
    ),
  );
}
