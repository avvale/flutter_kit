import 'package:flutter/widgets.dart';
import 'package:flutter_kit/models/router.dart';
import 'package:flutter_kit/models/state/auth_state.dart';
import 'package:flutter_kit/models/state/router_state.dart';
import 'package:flutter_kit/providers/auth_provider.dart';
import 'package:flutter_kit/utils/debugger.dart';
import 'package:flutter_kit/utils/helpers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router_provider.g.dart';

const _initialState = FkRouterState();

@Riverpod(keepAlive: true)
class Router extends _$Router {
  @override
  FkRouterState build() => _initialState;

  void initialize(FkRouter router) {
    if (state.isInitialized) {
      return;
    }

    final isAuth = ValueNotifier<FkAuthState>(ref.read(authProvider));

    ref
      ..onDispose(isAuth.dispose)
      ..listen(
        authProvider,
        (previous, next) {
          Debugger.log('Auth changed; refreshing router: $next');

          isAuth.value = next;
        },
      );

    state = state.copyWith(
      isInitialized: true,
      router: generateRouter(router, isAuth, ref),
    );
  }
}
