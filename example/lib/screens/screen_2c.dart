import 'package:flutter/material.dart';
import 'package:flutter_kit/widgets/tx.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod101/screens/screen_2c1.dart';
import 'package:riverpod101/screens/screen_2c2.dart';
import 'package:riverpod101/screens/screen_2c3.dart';

class Screen2c extends StatelessWidget {
  static const String routeName = '/screen2c';

  const Screen2c({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Center(
            child: Text('Screen 2c'),
          ),
          ElevatedButton(
            onPressed: () {
              context.go('$routeName/${Screen2c1.routeName}');
            },
            child: const Tx('Screen 2c1'),
          ),
          ElevatedButton(
            onPressed: () {
              context.go('$routeName/${Screen2c2.routeName}');
            },
            child: const Tx('Screen 2c2'),
          ),
          ElevatedButton(
            onPressed: () {
              context.go('$routeName/${Screen2c3.routeName}');
            },
            child: const Tx('Screen 2c3'),
          ),
        ],
      ),
    );
  }
}
