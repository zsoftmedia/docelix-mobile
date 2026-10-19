import 'package:docelix_mobileapp/core/responsive/responsive_metrics.dart';
import 'package:docelix_mobileapp/core/responsive/responsive_scope.dart';
import 'package:flutter/widgets.dart';

extension ResponsiveContextX on BuildContext {
  /// Current adaptive metrics (requires [ResponsiveScope] above).
  ResponsiveMetrics get rs => ResponsiveScope.of(this);

  /// Shortcut: scale design token (icons, gaps, radii).
  double s(double value) => rs.s(value);

  /// Shortcut: scale font size (readable clamp applied in [ResponsiveMetrics.sp]).
  double sp(double value, {double min = 11, double max = 40}) =>
      rs.sp(value, min: min, max: max);

  /// Shortcut: width * fraction (legacy migration helper).
  double wp(double fraction) => rs.wp(fraction);

  /// Shortcut: height * fraction.
  double hp(double fraction) => rs.hp(fraction);

  bool get isPhone => rs.isPhone;
  bool get isTabletOrLarger => rs.isTabletOrLarger;
}
