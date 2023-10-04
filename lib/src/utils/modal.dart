import 'package:flutter/material.dart';

class Modal {
  static void show(
    BuildContext context, {
    required Widget child,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Scaffold(
          body: SafeArea(
            child: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
