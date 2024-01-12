import 'package:flutter/material.dart';

class Screen2c2 extends StatelessWidget {
  static const String routeName = 'screen2c2';

  const Screen2c2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Center(
            child: Text('Screen 2c2'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }
}
