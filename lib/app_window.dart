import 'package:bitsdojo_window/bitsdojo_window.dart';
// ignore: depend_on_referenced_packages
import 'package:bitsdojo_window_platform_interface/window.dart';
import 'package:flutter/material.dart';

class AppWindow {
  static void setupWindow({
    required Size minSize,
    required Size initialSize,
    required Alignment alignment,
    required String iconPath,
  }) {
    final win = appWindow;
    win.minSize = minSize;
    win.size = initialSize;
    win.alignment = alignment;
    win.show();
    win.setIcon(iconPath);
  }
}

extension on DesktopWindow {
  void setIcon(String iconPath) {}
}

extension AppWindowIconExtension on AppWindow {
  void setIconPath(String path) {
    appWindow.setIcon('assets/app_ico.ico');
  }
}