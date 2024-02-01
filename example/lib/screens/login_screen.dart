import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kit/providers/auth_provider.dart';
import 'package:flutter_kit/providers/l10n_provider.dart';
import 'package:flutter_kit/widgets/tx.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod101/screens/home_screen.dart';
import 'package:riverpod101/screens/register_screen.dart';

class LoginScreen extends ConsumerWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Login'),
            Text(context.tr('skipForNow')),
            ElevatedButton(
              onPressed: () {
                ref.read(l10nProvider.notifier).changeLang('en', context);
              },
              child: const Tx('ENG'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(l10nProvider.notifier).changeLang('es', context);
              },
              child: const Tx('ESP'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).debugLogin();
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
