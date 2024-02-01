import 'package:flutter/material.dart';
import 'package:flutter_kit/providers/auth_provider.dart';
import 'package:flutter_kit/widgets/tx.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  static const routeName = '/';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Tx('Home Screen'),
            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
              child: const Tx('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
