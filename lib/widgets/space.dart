// ignore_for_file: use_super_parameters

import 'package:flutter/widgets.dart';

enum SpaceAxis { vertical, horizontal, both }

class Space extends StatelessWidget {
  /// Space size. This value is multiplied by 4 to get the size in pixels.
  final double size;

  /// Axis to apply space.
  final SpaceAxis axis;

  /// Space between widgets.
  const Space({
    Key? key,
    this.size = 0,
    this.axis = SpaceAxis.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (axis) {
      case SpaceAxis.vertical:
        return SizedBox(height: size * 4);
      case SpaceAxis.horizontal:
        return SizedBox(width: size * 4);
      case SpaceAxis.both:
        return SizedBox(height: size * 4, width: size * 4);
    }
  }
}
