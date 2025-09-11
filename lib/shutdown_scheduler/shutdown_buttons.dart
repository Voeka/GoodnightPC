import 'package:flutter/material.dart';

class ShutdownButtons extends StatelessWidget {
  final void Function(int) scheduleShutdown;
  final VoidCallback cancelShutdown;

  const ShutdownButtons({
    super.key,
    required this.scheduleShutdown,
    required this.cancelShutdown,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(104, 255, 153, 0), width: 3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              buildButton('30 минут', () => scheduleShutdown(1800)),
              buildButton('1 час', () => scheduleShutdown(3600)),
              buildButton('Выключить', () => scheduleShutdown(0), isRed: true),
            ],
          ),
        ),
        const SizedBox(height: 20),
        buildButton('Отмена', cancelShutdown, isCancel: true),
      ],
    );
  }

  Widget buildButton(String text, VoidCallback onPressed,
      {bool isRed = false, bool isCancel = false}) {
    return SizedBox(
      width: 150,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: isCancel ? Colors.green : Colors.orange, width: 3),
          backgroundColor: isRed ? Colors.red : Colors.transparent,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        child: Text(text),
      ),
    );
  }
}
