import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:material_ui/material_ui.dart';

/// M3 motion tokens (m3.material.io/styles/motion/overview).
///
/// M3 Expressive moves with **springs** instead of fixed durations:
/// * **spatial** springs move position, size and shape; they may overshoot.
/// * **effects** springs change colour and opacity; they never overshoot.
/// Each comes in fast, default and slow.
///
/// Values are the official design tokens, copied from Jetpack Compose's
/// generated `ExpressiveMotionTokens` / `StandardMotionTokens` (token
/// version 41.1.19). Flutter's Material library does not ship them yet.
///
/// For screen-to-screen transitions keep using M3 [Durations] + [Easing]
/// (e.g. `Durations.medium4` with `Easing.emphasizedDecelerate`).
enum TashilSpring {
  // Expressive scheme: the default for Tashil.
  fastSpatial(0.6, 800),
  defaultSpatial(0.8, 380),
  slowSpatial(0.8, 200),
  fastEffects(1.0, 3800),
  defaultEffects(1.0, 1600),
  slowEffects(1.0, 800),
  // Standard scheme: calmer, no visible bounce. For dense data screens.
  standardFastSpatial(0.9, 1400),
  standardDefaultSpatial(0.9, 700),
  standardSlowSpatial(0.9, 300);

  const TashilSpring(this.dampingRatio, this.stiffness);

  final double dampingRatio;
  final double stiffness;

  SpringDescription get description => SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: stiffness,
    ratio: dampingRatio,
  );

  /// Time for the spring to settle from 0 to 1 (within 0.1%).
  Duration get duration => _durations[this] ??= _settle();

  Duration _settle() {
    final sim = SpringSimulation(description, 0, 1, 0);
    var t = 0.0;
    var settledSince = 0.0;
    const step = 1 / 240;
    while (t < 3) {
      t += step;
      if ((sim.x(t) - 1).abs() < 0.001 && sim.dx(t).abs() < 0.01) {
        settledSince += step;
        if (settledSince > 0.05) break;
      } else {
        settledSince = 0;
      }
    }
    return Duration(milliseconds: (t * 1000).ceil());
  }

  /// The spring as a [Curve], for implicit animations such as
  /// [AnimatedContainer]. Pair it with [duration].
  Curve get curve => _curves[this] ??= _SpringCurve(this);
}

final _durations = <TashilSpring, Duration>{};
final _curves = <TashilSpring, Curve>{};

class _SpringCurve extends Curve {
  _SpringCurve(TashilSpring spring)
    : _sim = SpringSimulation(spring.description, 0, 1, 0),
      _seconds = spring.duration.inMicroseconds / 1e6;

  final SpringSimulation _sim;
  final double _seconds;

  @override
  double transformInternal(double t) => _sim.x(t * _seconds);
}

/// Shortcuts for implicit animations: `duration: TashilMotion.fast.duration`.
abstract final class TashilMotion {
  static const fast = TashilSpring.fastSpatial;
  static const normal = TashilSpring.defaultSpatial;
  static const slow = TashilSpring.slowSpatial;
  static const fade = TashilSpring.defaultEffects;

  /// Delay between items that enter one after another (FAB menu, lists).
  static const stagger = Duration(milliseconds: 30);

  /// Honour the system "remove animations" setting.
  static Duration scaled(BuildContext context, Duration d) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false ? Duration.zero : d;

  /// Clamp helper for overshooting springs driving values that must stay
  /// in range (opacity).
  static double unit(double v) => math.min(1, math.max(0, v));
}
