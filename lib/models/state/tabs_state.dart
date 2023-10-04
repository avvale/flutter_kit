import 'package:flutter/material.dart';
import 'package:flutter_kit/models/routing.dart';

class TabsState {
  final int selectedIndex;
  final List<FxNavigator> tabsNavigator;
  final bool isInitialized;
  final BuildContext? tabsContext;

  const TabsState({
    required this.selectedIndex,
    required this.tabsNavigator,
    required this.isInitialized,
    this.tabsContext,
  });

  TabsState copyWith({
    int? selectedIndex,
    List<FxNavigator>? tabsNavigator,
    bool? isInitialized,
    BuildContext? tabsContext,
  }) {
    return TabsState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      tabsNavigator: tabsNavigator ?? this.tabsNavigator,
      isInitialized: isInitialized ?? this.isInitialized,
      tabsContext: tabsContext ?? this.tabsContext,
    );
  }
}
