import 'package:flutter/material.dart';
import 'package:flutter_kit/services/auth_service.dart';
import 'package:flutter_kit/widgets/tx.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                FkAuthService().logout();
              },
              child: const Tx('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
