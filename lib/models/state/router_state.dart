import 'package:go_router/go_router.dart';

class FkRouterState {
  final bool isInitialized;
  final GoRouter? router;

  const FkRouterState({
    this.isInitialized = false,
    this.router,
  });

  FkRouterState copyWith({
    bool? isInitialized,
    GoRouter? router,
  }) {
    return FkRouterState(
      isInitialized: isInitialized ?? this.isInitialized,
      router: router ?? this.router,
    );
  }
}
