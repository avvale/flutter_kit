import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

abstract class TxSize {
  static const double xl3 = 32;
  static const double xl2 = 28;
  static const double xl = 24;
  static const double l = 20;
  static const double m2 = 18;
  static const double m = 16;
  static const double s = 14;
  static const double xs = 12;
  static const double xs2 = 10;
  static const double xs3 = 8;
}

abstract class TxColor {
  static const Color black = Color(0xff000000);
  static const Color darkGrey = Color(0xff3d3d3d);
  static const Color grey = Color(0xff7d7d7d);
  static const Color lightGrey = Color(0xffc4c4c4);
  static const Color white = Color(0xffffffff);
  static const Color blue = Color(0xff0000ff);
  static const Color red = Color(0xffff0000);
}

abstract class TxWeight {
  static const FontWeight light = FontWeight.w300;
  static const FontWeight w400 = FontWeight.w400;
  static const FontWeight normal = FontWeight.normal;
  static const FontWeight w500 = FontWeight.w500;
  static const FontWeight w600 = FontWeight.w600;
  static const FontWeight bold = FontWeight.bold;
}

// enum TxWeight { normal, w500, w600, bold }

enum TxAlign { left, center, right, justify }

enum TxStyle { normal, italic }

enum TxDecoration { normal, underline }

const Map<TxAlign, TextAlign> _txAligns = {
  TxAlign.left: TextAlign.left,
  TxAlign.center: TextAlign.center,
  TxAlign.right: TextAlign.right,
  TxAlign.justify: TextAlign.justify,
};
const Map<TxStyle, FontStyle> _txStyles = {
  TxStyle.normal: FontStyle.normal,
  TxStyle.italic: FontStyle.italic,
};
const Map<TxDecoration, TextDecoration> _txDecorations = {
  TxDecoration.normal: TextDecoration.none,
  TxDecoration.underline: TextDecoration.underline,
};

class Tx extends StatelessWidget {
  /// Text to be displayed.
  final String text;

  /// Size of the text.
  final double size;

  /// Color of the text.
  final Color? color;

  /// Weight of the text.
  final FontWeight weight;

  /// Style of the text.
  final TxStyle style;

  /// Decoration of the text.
  final TxDecoration decoration;

  /// Alignment of the text.
  final TxAlign align;

  /// Maximum number of lines of the text.
  final int? maxLines;

  /// Whether the text should be autosized or not.
  final bool autoSize;

  /// Minimum size of the text when using autoSize.
  final double? minSize;

  /// Wrapper around Text widget which provides an unified way to style text
  /// wasily allowing features like autosize, multiline, etc.
  const Tx(
    this.text, {
    Key? key,
    this.size = TxSize.m,
    this.color,
    this.weight = TxWeight.normal,
    this.style = TxStyle.normal,
    this.decoration = TxDecoration.normal,
    this.align = TxAlign.left,
    this.maxLines = 1,
    this.autoSize = false,
    this.minSize,
  }) : super(key: key);

  /// Returns a TextStyle object based on the Tx parameters.
  static TextStyle getStyle({
    double size = TxSize.m,
    Color color = TxColor.black,
    FontWeight weight = TxWeight.normal,
    TxStyle style = TxStyle.normal,
    TxDecoration decoration = TxDecoration.normal,
  }) {
    return TextStyle(
      fontSize: size,
      color: color,
      fontWeight: weight,
      fontStyle: _txStyles[style]!,
      decoration: _txDecorations[decoration]!,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (autoSize) {
      return AutoSizeText(
        text,
        maxLines: maxLines,
        minFontSize: minSize ?? size,
        overflow: TextOverflow.ellipsis,
        textAlign: _txAligns[align]!,
        style: TextStyle(
          fontSize: size,
          color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: weight,
          fontStyle: _txStyles[style]!,
          decoration: _txDecorations[decoration]!,
        ),
      );
    } else {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: _txAligns[align]!,
        style: TextStyle(
          fontSize: size,
          color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: weight,
          fontStyle: _txStyles[style]!,
          decoration: _txDecorations[decoration]!,
        ),
      );
    }
  }
}
