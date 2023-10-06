import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

enum TxSize { xl2, xl, l, m, s, xs, xs2 }

enum TxColor { black, grey, white, blue, red }

enum TxWeight { normal, w500, w600, bold }

enum TxAlign { left, center, right }

enum TxStyle { normal, italic }

enum TxDecoration { normal, underline }

const Map<TxSize, double> _txSizes = {
  TxSize.xl2: 28,
  TxSize.xl: 24,
  TxSize.l: 20,
  TxSize.m: 16,
  TxSize.s: 14,
  TxSize.xs: 12,
  TxSize.xs2: 10,
};
const Map<TxColor, Color> _txColors = {
  TxColor.black: Colors.black,
  TxColor.grey: Colors.grey,
  TxColor.white: Colors.white,
  TxColor.blue: Colors.blue,
  TxColor.red: Colors.red,
};
const Map<TxWeight, FontWeight> _txWeights = {
  TxWeight.normal: FontWeight.normal,
  TxWeight.w500: FontWeight.w500,
  TxWeight.w600: FontWeight.w600,
  TxWeight.bold: FontWeight.bold,
};
const Map<TxAlign, TextAlign> _txAligns = {
  TxAlign.left: TextAlign.left,
  TxAlign.center: TextAlign.center,
  TxAlign.right: TextAlign.right,
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
  final TxSize size;

  /// Color of the text.
  final TxColor color;

  /// Weight of the text.
  final TxWeight weight;

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
  final TxSize? minSize;

  /// Wrapper around Text widget which provides an unified way to style text
  /// wasily allowing features like autosize, multiline, etc.
  const Tx(
    this.text, {
    Key? key,
    this.size = TxSize.m,
    this.color = TxColor.black,
    this.weight = TxWeight.normal,
    this.style = TxStyle.normal,
    this.decoration = TxDecoration.normal,
    this.align = TxAlign.left,
    this.maxLines = 1,
    this.autoSize = false,
    this.minSize,
  }) : super(key: key);

  /// Returns the corresponding Color object based on the provided TxColor.
  static Color getColorByTxColor(TxColor color) => _txColors[color]!;

  /// Returns a TextStyle object based on the Tx parameters.
  static TextStyle getStyle({
    TxSize size = TxSize.m,
    TxColor color = TxColor.black,
    TxWeight weight = TxWeight.normal,
    TxStyle style = TxStyle.normal,
    TxDecoration decoration = TxDecoration.normal,
  }) {
    return TextStyle(
      fontSize: _txSizes[size]!,
      color: _txColors[color]!,
      fontWeight: _txWeights[weight]!,
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
        minFontSize: _txSizes[minSize ?? size]!,
        overflow: TextOverflow.ellipsis,
        textAlign: _txAligns[align]!,
        style: TextStyle(
          fontSize: _txSizes[size]!,
          color: _txColors[color]!,
          fontWeight: _txWeights[weight]!,
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
          fontSize: _txSizes[size]!,
          color: _txColors[color]!,
          fontWeight: _txWeights[weight]!,
          fontStyle: _txStyles[style]!,
          decoration: _txDecorations[decoration]!,
        ),
      );
    }
  }
}
