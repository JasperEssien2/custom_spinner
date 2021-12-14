import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'util.dart';

class CustomLoadingWidget extends SingleChildRenderObjectWidget {
  const CustomLoadingWidget({
    Key? key,
    this.loaderSize = 300,
    this.colorSetup,
    this.duration = const Duration(milliseconds: 3000),
    this.curve = Curves.decelerate,
    Widget? child,
  }) : super(key: key, child: child);

  final double loaderSize;
  final ColorSetup? colorSetup;
  final Duration duration;
  final Curve curve;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderCustomLoadingWidget(
      loaderSize: loaderSize,
      colorSetup: colorSetup ?? ColorSetup(),
      duration: duration,
      curve: curve,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderCustomLoadingWidget renderObject) {
    renderObject
      ..loaderSize = loaderSize
      ..duration = duration
      ..animCurve = curve
      ..colorSetup = colorSetup ?? ColorSetup();
  }
}

class _RenderCustomLoadingWidget extends RenderAligningShiftedBox
    with MathMixins {
  late final AnimationController _animationController =
      AnimationController(duration: duration, vsync: SwiftdelyTickerProvider());

  late final Animation _spinnerAnimation;
  Animation? _waveVerticalShiftAnimation;

  _RenderCustomLoadingWidget(
      {required double loaderSize,
      required ColorSetup colorSetup,
      Curve curve = Curves.decelerate,
      RenderBox? child,
      Duration duration = const Duration(milliseconds: 1000)})
      : _loaderSize = loaderSize,
        _colorSetup = colorSetup,
        _duration = duration,
        _animCurve = curve,
        super(
            textDirection: TextDirection.ltr,
            alignment: Alignment.center,
            child: child) {
    _animationController.repeat();

    _setupSpinnerAnimation();
  }

  void _setupSpinnerAnimation() {
    _spinnerAnimation = Tween<double>(begin: 0, end: math.pi * 2).animate(
        CurvedAnimation(curve: animCurve, parent: _animationController))
      ..addListener(() {
        markNeedsPaint();
      });
  }

  double _loaderSize;

  double get loaderSize => _loaderSize;

  set loaderSize(double value) {
    if (value == _loaderSize) return;
    _loaderSize = value;
    markNeedsPaint();
  }

  ColorSetup _colorSetup;

  ColorSetup get colorSetup => _colorSetup;

  set colorSetup(ColorSetup value) {
    if (value == colorSetup) return;
    _colorSetup = value;
    markNeedsPaint();
  }

  Duration _duration;

  Duration get duration => _duration;

  set duration(Duration value) {
    if (value == _duration) return;
    _duration = value;
    markNeedsPaint();
  }

  Curve _animCurve;

  Curve get animCurve => _animCurve;

  set animCurve(Curve value) {
    if (value == _animCurve) return;
    _animCurve = value;
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => false;

  @override
  void performResize() {
    size = computeDryLayout(constraints);
  }

  @override
  void performLayout() {
    size = computeDryLayout(constraints);

    if (child != null) {
      final maxSize = Size.fromRadius(_lineRadius(23));

      child?.layout(BoxConstraints.tight(maxSize), parentUsesSize: true);

      alignChild();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return size.width;
  }

  @override
  double computeMaxIntrinsicHeight(double width) => size.width;

  @override
  double computeMaxIntrinsicWidth(double width) => size.width;

  @override
  double computeMinIntrinsicHeight(double width) => size.width;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final size = math.min(_widthToUse, _loaderSize);

    return Size(size, size);
  }

  double get _widthToUse =>
      math.min(constraints.maxWidth, constraints.maxHeight);

  @override
  void paint(PaintingContext context, Offset offset) {
    _setupWaveHeightAnimation();
    context.pushClipRect(
      true,
      offset,
      Offset.zero & size,
      (context, offset) {
        final canvas = context.canvas;

        canvas.translate(offset.dx, offset.dy);

        _drawArc(
          canvas,
          color: colorSetup.line1Color ?? Colors.red,
          lineRadiusMultiplier: 1,
          startAngle: math.pi,
          sweepAngle: math.pi / 2,
        );

        _drawArc(
          canvas,
          color: colorSetup.line2Color ?? Colors.red.withOpacity(.4),
          lineRadiusMultiplier: 5,
          startAngle: math.pi,
          sweepAngle: math.pi,
        );

        _drawArc(
          canvas,
          color: colorSetup.line3Color ?? Colors.green,
          lineRadiusMultiplier: 9,
          startAngle: math.pi,
          sweepAngle: math.pi / 1.4,
        );

        _drawArc(canvas,
            color: colorSetup.defaultColor ?? Colors.green.withOpacity(.4),
            lineRadiusMultiplier: 18,
            startAngle: math.pi,
            sweepAngle: 2 * math.pi,
            strokeWidth: _spinnerPaintWidth);

        /// DRAW THE SPINNER
        _drawArc(
          canvas,
          color: colorSetup.activeColor ?? Colors.green,
          lineRadiusMultiplier: 18,
          startAngle: _spinnerAnimation.value,
          sweepAngle: math.pi,
          strokeWidth: _spinnerPaintWidth,
        );

        if (child == null) {
          _drawWave(context);
        }
      },
    );
    super.paint(context, offset);
  }

  void _drawArc(
    Canvas canvas, {
    required Color color,
    required double lineRadiusMultiplier,
    required double startAngle,
    required double sweepAngle,
    double strokeWidth = 4,
    PaintingStyle paintingStyle = PaintingStyle.stroke,
  }) {
    final line1Radius = _lineRadius(lineRadiusMultiplier);
    final centerOffset = Offset(size.width / 2, size.width / 2);

    canvas.drawArc(
      Rect.fromCenter(
        center: centerOffset,
        width: line1Radius * 2,
        height: line1Radius * 2,
      ),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = paintingStyle,
    );
  }

  void _drawWave(PaintingContext context) {
    var bounds = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: Size.fromRadius(_waveMaxRadius).width,
        height: Size.fromRadius(_waveMaxRadius).width);
    context.pushClipRRect(
      needsCompositing,
      Offset.zero,
      bounds,
      RRect.fromRectAndRadius(bounds, Radius.circular(_waveMaxRadius)),
      (context, offset) {
        context.canvas.translate(size.width / 2, size.height / 2);

        final path = Path();

        path.reset();

        path.moveTo(-_waveMaxRadius, _waveMaxRadius * 2);

        for (int i = -_waveMaxRadius.toInt(); i < _waveMaxRadius.toInt(); i++) {
          path.lineTo(
            i.toDouble(),
            verticlePoint(
              wave: WaveInfo(
                waveLength: _waveMaxRadius * 2,
                verticalShift: _waveVerticalShiftAnimation?.value,
                amplitude: 5,
              ),
              x: i.toDouble(),
            ),
          );
        }
        path.lineTo(_waveMaxRadius, _waveMaxRadius);

        context.canvas.drawPath(
          path,
          Paint()..color = colorSetup.waveColor ?? Colors.green.withOpacity(.4),
        );
      },
    );
  }

  double get _spinnerPaintWidth => math.max(6, size.width * 0.045);

  double _lineRadius(double multiplier) => //size.width * 0.015
      (size.width - (multiplier * math.max(2.5, size.width * 0.015))) / 2;

  double get _waveMaxRadius => _lineRadius(23);

  void _setupWaveHeightAnimation() {
    /// To prevent overriding the animation
    if (_waveVerticalShiftAnimation != null) return;

    _waveVerticalShiftAnimation =
        Tween<double>(begin: _waveMaxRadius, end: -_waveMaxRadius).animate(
      CurvedAnimation(
        curve: animCurve,
        parent: _animationController,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }
}
