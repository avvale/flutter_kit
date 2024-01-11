import 'package:flutter/material.dart';
import 'package:flutter_kit/models/routing.dart';

class TabsState {
  final int selectedIndex;
  final int initialIndex;
  final List<FkNavigator> tabNavigators;
  final bool isInitialized;
  final BuildContext? tabsContext;
  final FkRoute? currentRoute;

  const TabsState({
    this.selectedIndex = 0,
    this.initialIndex = 0,
    this.tabNavigators = const [],
    this.isInitialized = false,
    this.tabsContext,
    this.currentRoute,
  });

  TabsState copyWith({
    int? selectedIndex,
    int? initialIndex,
    List<FkNavigator>? tabNavigators,
    bool? isInitialized,
    BuildContext? tabsContext,
  }) {
    return TabsState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      initialIndex: initialIndex ?? this.initialIndex,
      tabNavigators: tabNavigators ?? this.tabNavigators,
      isInitialized: isInitialized ?? this.isInitialized,
      tabsContext: tabsContext ?? this.tabsContext,
    );
  }
}
