import 'package:flutter/material.dart';

enum SpaceAxis { vertical, horizontal, both }

class Space extends StatelessWidget {
  /// Space size. This value is multiplied by 4 to get the size in pixels.
  final double size;

  /// Space direction.
  final SpaceAxis direction;

  /// Space between widgets.
  const Space({
    Key? key,
    this.size = 0,
    this.direction = SpaceAxis.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (direction) {
      case SpaceAxis.vertical:
        return SizedBox(height: size * 4);
      case SpaceAxis.horizontal:
        return SizedBox(width: size * 4);
      case SpaceAxis.both:
        return SizedBox(height: size * 4, width: size * 4);
    }
  }
}
