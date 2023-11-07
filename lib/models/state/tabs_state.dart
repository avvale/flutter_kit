import 'package:flutter/material.dart';
import 'package:flutter_kit/models/routing.dart';

class TabsState {
  final int selectedIndex;
  final int initialIndex;
  final List<FxNavigator> tabNavigators;
  final bool isInitialized;
  final BuildContext? tabsContext;

  const TabsState({
    required this.selectedIndex,
    this.initialIndex = 0,
    required this.tabNavigators,
    required this.isInitialized,
    this.tabsContext,
  });

  TabsState copyWith({
    int? selectedIndex,
    int? initialIndex,
    List<FxNavigator>? tabNavigators,
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
