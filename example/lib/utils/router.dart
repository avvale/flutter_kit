import 'package:flutter_kit/models/router.dart';
import 'package:flutter_kit/models/state/auth_state.dart';
import 'package:flutter_kit/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fk_example/screens/home_screen.dart';
import 'package:fk_example/screens/login_screen.dart';
import 'package:fk_example/screens/register_screen.dart';
import 'package:fk_example/screens/screen_1.dart';
import 'package:fk_example/screens/screen_2a.dart';
import 'package:fk_example/screens/screen_2a1.dart';
import 'package:fk_example/screens/screen_2a2.dart';
import 'package:fk_example/screens/screen_2b.dart';
import 'package:fk_example/screens/screen_2c.dart';
import 'package:fk_example/screens/screen_2c1.dart';
import 'package:fk_example/screens/screen_2c2.dart';
import 'package:fk_example/screens/screen_2c3.dart';
import 'package:fk_example/screens/screen_3a.dart';
import 'package:fk_example/screens/screen_3b.dart';
import 'package:fk_example/widgets/drawer_layout.dart';
import 'package:fk_example/widgets/tabs_layout.dart';

final _rootNavKey = GlobalKey<NavigatorState>();
final _homeNavKey = GlobalKey<NavigatorState>();
final _screen1NavKey = GlobalKey<NavigatorState>();
final _screen2NavKey = GlobalKey<NavigatorState>();
final _screen2aNavKey = GlobalKey<NavigatorState>();
final _screen2bNavKey = GlobalKey<NavigatorState>();
final _screen2cNavKey = GlobalKey<NavigatorState>();
final _screen3NavKey = GlobalKey<NavigatorState>();
final _screen3aNavKey = GlobalKey<NavigatorState>();
final _screen3bNavKey = GlobalKey<NavigatorState>();

final appRouter = FkRouter(
  navigatorKey: _rootNavKey,
  initialLocation: HomeScreen.routeName,
  routes: [
    FkRoute(
      path: LoginScreen.routeName,
      builder: (context, state) => const LoginScreen(),
    ),
    FkRoute(
      path: RegisterScreen.routeName,
      builder: (context, state) => const RegisterScreen(),
    ),
    FkRouteTree(
      builder: (context, state, navigationShell) {
        return DrawerLayout(navigationShell: navigationShell);
      },
      branches: [
        // Home branch
        FkRouteTreeBranch(
          navigatorKey: _homeNavKey,
          initialLocation: HomeScreen.routeName,
          routes: [
            FkRoute(
              path: HomeScreen.routeName,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScreen(),
              ),
            ),
          ],
        ),
        // Screen 1 branch
        FkRouteTreeBranch(
          navigatorKey: _screen1NavKey,
          initialLocation: Screen1.routeName,
          routes: [
            FkRoute(
              path: Screen1.routeName,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: Screen1(),
              ),
            ),
          ],
        ),
        // Screen 2 branch (Tabs)
        FkRouteTreeBranch(
          navigatorKey: _screen2NavKey,
          initialLocation: Screen2a.routeName,
          routes: [
            FkRouteTree(
              builder: (context, state, navigationShell) {
                return TabsLayout(
                  navigationShell: navigationShell,
                  tabs: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.candlestick_chart),
                      label: 'Candlestick',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.call),
                      label: 'Call',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.chair_rounded),
                      label: 'Chair',
                    ),
                  ],
                );
              },
              branches: [
                FkRouteTreeBranch(
                  navigatorKey: _screen2aNavKey,
                  initialLocation: Screen2a.routeName,
                  routes: [
                    FkRoute(
                      path: Screen2a.routeName,
                      pageBuilder: (context, state) => const NoTransitionPage(
                        child: Screen2a(),
                      ),
                      routes: [
                        FkRoute(
                          path: Screen2a1.routeName,
                          builder: (context, state) => const Screen2a1(),
                        ),
                        FkRoute(
                          path: Screen2a2.routeName,
                          builder: (context, state) => const Screen2a2(),
                        ),
                      ],
                    ),
                  ],
                ),
                FkRouteTreeBranch(
                  navigatorKey: _screen2bNavKey,
                  initialLocation: Screen2b.routeName,
                  routes: [
                    FkRoute(
                      path: Screen2b.routeName,
                      pageBuilder: (context, state) => const NoTransitionPage(
                        child: Screen2b(),
                      ),
                    ),
                  ],
                ),
                FkRouteTreeBranch(
                  navigatorKey: _screen2cNavKey,
                  initialLocation: Screen2c.routeName,
                  routes: [
                    FkRoute(
                      path: Screen2c.routeName,
                      pageBuilder: (context, state) => const NoTransitionPage(
                        child: Screen2c(),
                      ),
                      routes: [
                        FkRoute(
                          path: Screen2c1.routeName,
                          builder: (context, state) => const Screen2c1(),
                        ),
                        FkRoute(
                          path: Screen2c2.routeName,
                          builder: (context, state) => const Screen2c2(),
                        ),
                        FkRoute(
                          path: Screen2c3.routeName,
                          builder: (context, state) => const Screen2c3(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Screen 3 branch (Tabs)
        FkRouteTreeBranch(
          navigatorKey: _screen3NavKey,
          initialLocation: Screen3a.routeName,
          routes: [
            FkRouteTree(
              builder: (context, state, navigationShell) {
                return TabsLayout(
                  navigationShell: navigationShell,
                  tabs: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.business),
                      label: 'Business',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.school),
                      label: 'School',
                    ),
                  ],
                );
              },
              branches: [
                FkRouteTreeBranch(
                  navigatorKey: _screen3aNavKey,
                  initialLocation: Screen3a.routeName,
                  routes: [
                    FkRoute(
                      path: Screen3a.routeName,
                      pageBuilder: (context, state) => const NoTransitionPage(
                        child: Screen3a(),
                      ),
                    ),
                  ],
                ),
                FkRouteTreeBranch(
                  navigatorKey: _screen3bNavKey,
                  initialLocation: Screen3b.routeName,
                  routes: [
                    FkRoute(
                      path: Screen3b.routeName,
                      pageBuilder: (context, state) => const NoTransitionPage(
                        child: Screen3b(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
  redirect: (
    BuildContext context,
    GoRouterState state,
    ValueNotifier<FkAuthState> auth,
  ) {
    final loggedIn = existsNotEmpty(auth.value.accessToken);
    final loggingIn = state.matchedLocation == LoginScreen.routeName ||
        state.matchedLocation == RegisterScreen.routeName;

    if (!loggedIn) {
      if (loggingIn) {
        return null;
      } else {
        return '/login';
      }
    }

    if (loggingIn) {
      return '/';
    }

    return null;
  },
);
