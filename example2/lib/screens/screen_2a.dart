import 'package:flutter/material.dart';
import 'package:flutter_kit/widgets/tx.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod101/screens/screen_2a1.dart';
import 'package:riverpod101/screens/screen_2a2.dart';

class Screen2a extends StatelessWidget {
  static const String routeName = '/screen2a';

  const Screen2a({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Center(
            child: Text('Screen 2a'),
          ),
          ElevatedButton(
            onPressed: () {
              context.go('$routeName/${Screen2a1.routeName}');
            },
            child: const Tx('Screen 2a1'),
          ),
          ElevatedButton(
            onPressed: () {
              context.go('$routeName/${Screen2a2.routeName}');
            },
            child: const Tx('Screen 2a2'),
          ),
        ],
      ),
    );
  }
}
