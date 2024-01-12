import 'package:flutter/material.dart';
import 'package:flutter_kit/services/auth_service.dart';
import 'package:flutter_kit/widgets/tx.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod101/screens/home_screen.dart';
import 'package:riverpod101/screens/register_screen.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Login'),
            ElevatedButton(
              onPressed: () {
                FkAuthService().debugLogin();
              },
              child: const Tx('Iniciar sesión'),
            ),
            ElevatedButton(
              onPressed: () {
                context.push(RegisterScreen.routeName);
              },
              child: const Tx('Ir al registro'),
            ),
            ElevatedButton(
              onPressed: () {
                context.go(HomeScreen.routeName);
              },
              child: const Tx('Ir a la home'),
            ),
          ],
        ),
      ),
    );
  }
}
