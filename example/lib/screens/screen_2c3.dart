import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Screen2c3 extends StatelessWidget {
  static const String routeName = 'screen2c3';

  const Screen2c3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Center(
            child: Text('Screen 2c3'),
          ),
          ElevatedButton(
            onPressed: context.pop,
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }
}
