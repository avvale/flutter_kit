import 'package:flutter/material.dart';
import 'package:flutter_kit/widgets/tx.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {
  static const routeName = '/register';

  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Register'),
            ElevatedButton(
              onPressed: () {
                context.pop();
                // context.go(LoginScreen.routeName);
              },
              child: const Tx('Volver al login'),
            )
          ],
        ),
      ),
    );
  }
}
