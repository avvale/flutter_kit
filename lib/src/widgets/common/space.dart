import 'package:flutter/material.dart';

enum SpaceDirection { vertical, horizontal, both }

class Space extends StatelessWidget {
  /// Space size. This value is multiplied by 4 to get the size in pixels.
  final double size;

  /// Space direction.
  final SpaceDirection direction;

  /// Space between widgets.
  const Space({
    Key? key,
    this.size = 0,
    this.direction = SpaceDirection.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (direction) {
      case SpaceDirection.vertical:
        return SizedBox(height: size * 4);
      case SpaceDirection.horizontal:
        return SizedBox(width: size * 4);
      case SpaceDirection.both:
        return SizedBox(height: size * 4, width: size * 4);
    }
  }
}
