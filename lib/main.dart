import 'dart:io';
import 'package:bitsdojo_window_platform_interface/window.dart';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

void main() {
  runApp(MyApp());

  // Настройка окна приложения
  doWhenWindowReady(() {
    final win = appWindow;
    win.minSize = Size(300, 200);
    win.show();

    // Устанавливаем иконку для окна
    win.setIcon('assets/icon.ico');
  });
}

extension on DesktopWindow {
  void setIcon(String s) {}
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ShutdownScheduler(),
    );
  }
}

class ShutdownScheduler extends StatefulWidget {
  @override
  _ShutdownSchedulerState createState() => _ShutdownSchedulerState();
}

class _ShutdownSchedulerState extends State<ShutdownScheduler>
    with TrayListener {
  TextEditingController _controller = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _initTray(); // Инициализация меню в системном трее
    trayManager.addListener(this); // Добавляем слушателя для трея
  }

  // Инициализация меню в системном трее
  void _initTray() async {
    await trayManager.setIcon(
      'assets/icon.ico',
    ); // Устанавливаем иконку для трея
    trayManager.setToolTip("Меню управления");

    // Создание элементов меню для трея
    trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(
            label: 'Открыть',
            onClick: (MenuItem item) {
              appWindow.show(); // Открытие окна при клике на "Открыть"
            },
          ),
          MenuItem(
            label: 'Выход',
            onClick: (MenuItem item) {
              exit(0); // Завершение приложения
            },
          ),
        ],
      ),
    );
  }

  // Функция планирования выключения
  void scheduleShutdown(int seconds) {
    Process.run('shutdown', ['/s', '/t', '$seconds'])
        .then((_) {
          showCustomToast('Выключение через ${seconds ~/ 60} минут');
        })
        .catchError((error) {
          showCustomToast('Ошибка: $error');
        });
  }

  // Функция отмены выключения
  void cancelShutdown() {
    Process.run('shutdown', ['/a'])
        .then((_) {
          showCustomToast('Выключение отменено');
        })
        .catchError((error) {
          showCustomToast('Ошибка: $error');
        });
  }

  // Функция для отображения уведомлений
  void showCustomToast(String message) {
    scaffoldKey.currentState?.hideCurrentSnackBar();
    scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(message, style: TextStyle(color: Colors.white)),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => scaffoldKey.currentState?.hideCurrentSnackBar(),
            ),
          ],
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
        duration: Duration(seconds: 5),
      ),
    );
  }

  @override
  void dispose() {
    trayManager.removeListener(this); // Убираем слушателя трея
    trayManager.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xFF2C2C2C),
      appBar: AppBar(
        title: Text('Меню управления', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1F1F1F),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Текст с оставшимся временем
            Text(
              _controller.text.isEmpty
                  ? 'Введите время'
                  : 'Выключение через ${_controller.text} минут',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 10),

            // Поле ввода минут
            SizedBox(
              width: 150,
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Минуты',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.yellow, width: 2),
                  ),
                ),
                onChanged: (value) {
                  setState(() {}); // Обновляем текст при вводе
                },
                onSubmitted: (value) {
                  int minutes = int.tryParse(value) ?? 0;
                  if (minutes > 0) {
                    scheduleShutdown(minutes * 60);
                  } else {
                    showCustomToast('Введите корректное число минут');
                  }
                },
              ),
            ),
            SizedBox(height: 20),

            // Блок кнопок выключения
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(104, 255, 153, 0),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  buildButton('30 минут', () => scheduleShutdown(1800)),
                  buildButton('1 час', () => scheduleShutdown(3600)),
                  buildButton(
                    'Выключить',
                    () => scheduleShutdown(0),
                    isRed: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Кнопка отмены
            buildButton('Отмена', cancelShutdown, isCancel: true),
          ],
        ),
      ),
    );
  }

  // Виджет для кнопок
  Widget buildButton(
    String text,
    VoidCallback onPressed, {
    bool isRed = false,
    bool isCancel = false,
  }) {
    return SizedBox(
      width: 150,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isCancel ? Colors.green : Colors.orange,
            width: 3,
          ),
          backgroundColor: isRed ? Colors.red : Colors.transparent,
          foregroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        child: Text(text),
      ),
    );
  }

  // Обработка кликов по значку в трее
  @override
  void onTrayIconMouseDown() {
    appWindow.show();
  }
}

// flutter pub get
// 
// flutter pub add tray_manager bitsdojo_window


// flutter run -d windows
// 
// flutter build windows --release