import 'package:flutter/material.dart';

class CurvedNavigationBar extends StatefulWidget {
  final List<Widget> items;
  final int index;
  final ValueChanged<int>? onTap;
  final bool Function(int value) allowIndexChange;
  final Color? tabBarColor;
  final Color? buttonBackgroundColor;

  /// Widget procedente del paquete "curved_navigation_bar", modificado para
  /// adaptarse al diseño y funcionalidad de la app
  CurvedNavigationBar({
    super.key,
    required this.items,
    this.index = 0,
    this.onTap,
    this.tabBarColor,
    this.buttonBackgroundColor,
    bool Function(int value)? letIndexChange,
  })  : allowIndexChange = letIndexChange ?? ((_) => true),
        assert(items.isNotEmpty),
        assert(0 <= index && index < items.length);

  @override
  CurvedNavigationBarState createState() => CurvedNavigationBarState();
}

class CurvedNavigationBarState extends State<CurvedNavigationBar>
    with SingleTickerProviderStateMixin {
  final Curve _animationCurve = Curves.easeInOutCubic;
  final Duration _animationDuration = const Duration(milliseconds: 300);
  late final int _length;
  late final AnimationController _animationController;
  late Widget _icon;
  late double _pos;
  late double _startingPos;
  int _endingIndex = 0;
  double _buttonHide = 0;

  @override
  void initState() {
    super.initState();
    _length = widget.items.length;
    _pos = widget.index / _length;
    _icon = widget.items[widget.index];
    _startingPos = widget.index / _length;
    _animationController = AnimationController(vsync: this, value: _pos);

    _animationController.addListener(() {
      setState(() {
        final endingPos = _endingIndex / widget.items.length;
        final middle = (endingPos + _startingPos) / 2;

        _pos = _animationController.value;

        if ((endingPos - _pos).abs() < (_startingPos - _pos).abs()) {
          _icon = widget.items[_endingIndex];
        }

        _buttonHide =
            (1 - ((middle - _pos) / (_startingPos - middle)).abs()).abs();
      });
    });
  }

  @override
  void didUpdateWidget(CurvedNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.index != widget.index) {
      final newPosition = widget.index / _length;
      _startingPos = _pos;
      _endingIndex = widget.index;
      _animationController.animateTo(
        newPosition,
        duration: _animationDuration,
        curve: _animationCurve,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      // This way the bottom bar animations don't appear under itself
      clipBehavior: Clip.hardEdge,
      // Needed if clipBehavior is not Clip.none
      decoration: const BoxDecoration(),
      height: 75 + 14,
      width: size.width,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Positioned(
            bottom: -40 - (75.0 - 75),
            left: Directionality.of(context) == TextDirection.rtl
                ? null
                : _pos * size.width,
            right: Directionality.of(context) == TextDirection.rtl
                ? _pos * size.width
                : null,
            width: size.width / _length,
            child: Center(
              child: Transform.translate(
                offset: Offset(
                  0,
                  -(1 - _buttonHide) * 80,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(128),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(1.5),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: widget.buttonBackgroundColor ??
                            Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(128),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _icon,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0 - (75.0 - 75),
            child: CustomPaint(
              painter: _NavCustomPainter(
                _pos,
                _length,
                widget.tabBarColor ?? Theme.of(context).primaryColor,
                Directionality.of(context),
              ),
              child: Container(
                height: 75.0,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0 - (75.0 - 75),
            child: SizedBox(
              height: 100.0,
              child: Row(
                children: widget.items.map(
                  (item) {
                    return _NavButton(
                      onTap: _buttonTap,
                      position: _pos,
                      length: _length,
                      index: widget.items.indexOf(item),
                      child: Center(child: item),
                    );
                  },
                ).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void setPage(int index) {
    _buttonTap(index);
  }

  void _buttonTap(int index) {
    if (!widget.allowIndexChange(index)) {
      return;
    }

    if (widget.onTap != null) {
      widget.onTap!(index);
    }

    final newPosition = index / _length;

    setState(() {
      _startingPos = _pos;
      _endingIndex = index;
      _animationController.animateTo(
        newPosition,
        duration: _animationDuration,
        curve: _animationCurve,
      );
    });
  }
}

class _NavButton extends StatelessWidget {
  final double position;
  final int length;
  final int index;
  final ValueChanged<int> onTap;
  final Widget child;

  const _NavButton({
    required this.onTap,
    required this.position,
    required this.length,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final desiredPosition = 1.0 / length * index;
    final difference = (position - desiredPosition).abs();
    final verticalAlignment = 1 - length * difference;
    final opacity = length * difference;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => onTap(index),
        child: SizedBox(
          height: 75.0,
          child: Transform.translate(
            offset: Offset(
              0,
              difference < 1.0 / length ? verticalAlignment * 40 : 0,
            ),
            child: Opacity(
              opacity: difference < 1.0 / length * 0.99 ? opacity : 1.0,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavCustomPainter extends CustomPainter {
  late double _loc;
  late double _s;
  final Color _color;
  final TextDirection _textDirection;

  _NavCustomPainter(
    double startingLoc,
    int itemsLength,
    this._color,
    this._textDirection,
  ) {
    final span = 1.0 / itemsLength;
    _s = 0.2;
    double l = startingLoc + (span - _s) / 2;
    _loc = _textDirection == TextDirection.rtl ? 0.8 - l : l;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo((_loc - 0.1) * size.width, 0)
      ..cubicTo(
        (_loc + _s * 0.20) * size.width,
        size.height * 0.05,
        _loc * size.width,
        size.height * 0.60,
        (_loc + _s * 0.50) * size.width,
        size.height * 0.60,
      )
      ..cubicTo(
        (_loc + _s) * size.width,
        size.height * 0.60,
        (_loc + _s - _s * 0.20) * size.width,
        size.height * 0.05,
        (_loc + _s + 0.1) * size.width,
        0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}
