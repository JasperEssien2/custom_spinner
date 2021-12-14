import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class WaveInfo {
  final Color color;

  ///[verticalShift] value within 1 to 10
  final double verticalShift;
  final double amplitude;
  final double phaseShift;
  final Duration duration;
  final double waveLength;

  final Curve curve;
  double amplitudeAnimationVal;
  double phaseShiftAnimationVal;

  WaveInfo({
    this.color = Colors.blue,
    this.verticalShift = 1,
    this.amplitude = 10,
    this.phaseShift = 0,
    this.curve = Curves.easeInOut,
    this.amplitudeAnimationVal = 1,
    this.phaseShiftAnimationVal = 0,
    this.waveLength = 150,
    this.duration = const Duration(milliseconds: 300),
  });
}

class ColorSetup {
  Color? line1Color;
  Color? line2Color;
  Color? line3Color;

  Color? activeColor;
  Color? defaultColor;
  Color? waveColor;

  ColorSetup(
      {this.line1Color,
      this.line2Color,
      this.line3Color,
      this.activeColor,
      this.defaultColor,
      this.waveColor});
}

class CustomTicker extends Ticker {
  CustomTicker(TickerCallback onTick) : super(onTick);
}

class SwiftdelyTickerProvider implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => CustomTicker(onTick);
}

class MathMixins {
  double verticlePoint({required double x, required WaveInfo wave}) {
    var period = (2 * math.pi / wave.waveLength);

    /// Controls horizontal shift
    var sinX = (x + (wave.phaseShift * wave.phaseShiftAnimationVal));
    return (wave.amplitude * wave.amplitudeAnimationVal) *
            math.sin(period * sinX) +
        wave.verticalShift;
  }
}
