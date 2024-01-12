import 'package:flutter/material.dart';

class Screen2a1 extends StatelessWidget {
  static const String routeName = 'screen2a1';

  const Screen2a1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Center(
            child: Text('Screen 2a1'),
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
