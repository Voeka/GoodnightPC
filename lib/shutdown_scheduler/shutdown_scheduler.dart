import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'shutdown_buttons.dart';

class ShutdownScheduler extends StatefulWidget {
  const ShutdownScheduler({super.key});

  @override
  _ShutdownSchedulerState createState() => _ShutdownSchedulerState();
}

class _ShutdownSchedulerState extends State<ShutdownScheduler> {
  final TextEditingController _controller = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  bool isDarkmode = false; 

  void scheduleShutdown(int seconds) {
    Process.run('shutdown', ['/s', '/t', '$seconds']).then((_) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Выключение через ${seconds ~/ 60} минут')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Ошибка: $error')),
      );
    });
  }

  void cancelShutdown() {
    Process.run('shutdown', ['/a']).then((_) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        const SnackBar(content: Text('Выключение отменено')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Ошибка: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFF2C2C2C),
      appBar: AppBar(
        title: const Text('Меню управления', style: TextStyle(color: Colors.white)),
        // actions: <Widget>[
        //   IconButton(
        //     icon: const Icon(Icons.settings, color: Colors.orange),
        //     onPressed: () {
        //       showDialog(
        //         context: context,
        //         builder: (BuildContext context) {
        //           return StatefulBuilder(
        //             builder: (BuildContext context, StateSetter setState) {
        //               return Dialog(
        //                 backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        //                 insetPadding: const EdgeInsets.all(20),
        //                 child: Container(
        //                   padding: const EdgeInsets.all(20),
        //                   decoration: BoxDecoration(
        //                     color: const Color(0xFF2C2C2C),
        //                     borderRadius: BorderRadius.circular(21),
        //                     border: Border.all(
        //                       color: Colors.orange,
        //                       width: 3,
        //                     ),
        //                   ),
        //                   child: Column(
        //                     mainAxisSize: MainAxisSize.min,
        //                     children: [
        //                       const Text(
        //                         'Настройки',
        //                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        //                       ),
        //                       const SizedBox(height: 20),
        //                       const Text('Тут твои настройки', style: TextStyle(color: Colors.white)),
        //                       Switch(value: isDarkmode, activeColor: Colors.orange, onChanged: (val) {
        //                         setState(() => isDarkmode = val);
        //                       }),
        //                       const SizedBox(height: 20),
        //                       ElevatedButton(
        //                         onPressed: () => Navigator.of(context).pop(),
        //                         style: ElevatedButton.styleFrom(
        //                           backgroundColor: Colors.orange,
        //                           shape: RoundedRectangleBorder(
        //                             borderRadius: BorderRadius.circular(20),
        //                           ),
        //                         ),
        //                         child: const Text('Закрыть', style: TextStyle(color:  Color(0xFF2C2C2C) )),
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //               );
        //             },
        //           );
        //         },
        //       );
        //     },
        //   )
        // ],
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
                    ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
                      const SnackBar(content: Text('Введите корректное число минут')),
                    );
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
}
