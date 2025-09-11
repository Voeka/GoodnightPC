import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tray_manager/tray_manager.dart';
import 'shutdown_buttons.dart';
import '../utils/toast.dart';

class ShutdownScheduler extends StatefulWidget {
  const ShutdownScheduler({super.key});

  @override
  _ShutdownSchedulerState createState() => _ShutdownSchedulerState();
}

class _ShutdownSchedulerState extends State<ShutdownScheduler> with TrayListener {
  final TextEditingController _controller = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _initTray();
    trayManager.addListener(this);
  }

  // Настройка меню трея
  void _initTray() async {
    await trayManager.setIcon('assets/app_ico.ico');
    trayManager.setToolTip("Меню управления");

    final menu = Menu(
      items: [
        MenuItem(label: 'Открыть', key: 'open'),
        MenuItem(label: 'Выход', key: 'exit'),
      ],
    );

    await trayManager.setContextMenu(menu);
  }

  void scheduleShutdown(int seconds) {
    Process.run('shutdown', ['/s', '/t', '$seconds']).then((_) {
      showCustomToast(scaffoldKey, 'Выключение через ${seconds ~/ 60} минут');
    }).catchError((error) {
      showCustomToast(scaffoldKey, 'Ошибка: $error');
    });
  }

  void cancelShutdown() {
    Process.run('shutdown', ['/a']).then((_) {
      showCustomToast(scaffoldKey, 'Выключение отменено');
    }).catchError((error) {
      showCustomToast(scaffoldKey, 'Ошибка: $error');
    });
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    trayManager.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFF2C2C2C),
      appBar: AppBar(
        title: const Text('Меню управления', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1F1F1F),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _controller.text.isEmpty
                  ? 'Введите время'
                  : 'Выключение через ${_controller.text} минут',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 150,
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Минуты',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.yellow, width: 2),
                  ),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (value) {
                  int minutes = int.tryParse(value) ?? 0;
                  if (minutes > 0) {
                    scheduleShutdown(minutes * 60);
                  } else {
                    showCustomToast(scaffoldKey, 'Введите корректное число минут');
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            ShutdownButtons(
              scheduleShutdown: scheduleShutdown,
              cancelShutdown: cancelShutdown,
            ),
          ],
        ),
      ),
    );
  }

  // Обработка клика по значку трея
  @override
  void onTrayIconMouseDown() => appWindow.show();

  // Обработка клика по пунктам меню трея
  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'open') {
      appWindow.show();
    } else if (menuItem.key == 'exit') {
      exit(0);
    }
  }
}
