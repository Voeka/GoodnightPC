import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'app_window.dart';
import 'shutdown_scheduler/shutdown_scheduler.dart';

void main() {
  runApp(const MyApp());

  doWhenWindowReady(() {
    AppWindow.setupWindow(
      minSize: const Size(300, 600),
      initialSize: const Size(300, 600),
      alignment: Alignment.center,
      iconPath: 'assets/app_ico.ico',
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ShutdownScheduler(),
    );
  }
}
