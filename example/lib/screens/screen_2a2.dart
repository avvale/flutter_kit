import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Screen2a2 extends StatelessWidget {
  static const String routeName = 'screen2a2';

  const Screen2a2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Center(
            child: Text('Screen 2a2'),
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
