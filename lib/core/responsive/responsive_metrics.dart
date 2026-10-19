import 'package:docelix_mobileapp/core/responsive/responsive_breakpoints.dart';
import 'package:flutter/widgets.dart';

/// Snapshot of the current viewport used for adaptive layout decisions.
class ResponsiveMetrics {
  const ResponsiveMetrics({
    required this.size,
    required this.orientation,
    required this.deviceType,
    required this.scale,
    required this.textScaleFactor,
  });

  final Size size;
  final Orientation orientation;
  final AppDeviceType deviceType;

  /// Width scale vs [ResponsiveBreakpoints.designWidth], clamped.
  final double scale;

  /// System text scale (accessibility).
  final double textScaleFactor;

  double get width => size.width;
  double get height => size.height;
  double get shortestSide => size.shortestSide;
  double get longestSide => size.longestSide;

  bool get isPhone => deviceType.isPhone;
  bool get isCompactTablet => deviceType.isCompactTablet;
  bool get isTablet => deviceType.isRegularTablet;
  bool get isLargeTablet => deviceType.isLargeTablet;
  bool get isTabletOrLarger => deviceType.isTabletOrLarger;
  bool get isLandscape => orientation == Orientation.landscape;
  bool get isPortrait => orientation == Orientation.portrait;

  /// Max width for readable page content (centered on tablet+).
  double get contentMaxWidth {
    switch (deviceType) {
      case AppDeviceType.phone:
        return width;
      case AppDeviceType.compactTablet:
        return isLandscape
            ? ResponsiveBreakpoints.regularTabletContentMaxWidth
            : ResponsiveBreakpoints.compactTabletContentMaxWidth;
      case AppDeviceType.tablet:
        return isLandscape
            ? ResponsiveBreakpoints.largeTabletContentMaxWidth
            : ResponsiveBreakpoints.regularTabletContentMaxWidth;
      case AppDeviceType.largeTablet:
        return isLandscape
            ? ResponsiveBreakpoints.largeTabletLandscapeContentMaxWidth
            : ResponsiveBreakpoints.largeTabletContentMaxWidth;
    }
  }

  /// Narrow column for login / signup / simple forms.
  double get authFormMaxWidth {
    if (isPhone) return width;
    if (isLargeTablet) {
      return ResponsiveBreakpoints.authFormMaxWidthLarge;
    }
    return ResponsiveBreakpoints.authFormMaxWidth;
  }

  /// Default horizontal page gutter.
  double get pagePaddingH {
    switch (deviceType) {
      case AppDeviceType.phone:
        return width * 0.045;
      case AppDeviceType.compactTablet:
        return isLandscape ? 32 : 24;
      case AppDeviceType.tablet:
        return isLandscape ? 40 : 28;
      case AppDeviceType.largeTablet:
        return isLandscape ? 48 : 36;
    }
  }

  /// Default vertical page gutter.
  double get pagePaddingV {
    switch (deviceType) {
      case AppDeviceType.phone:
        return width * 0.035;
      case AppDeviceType.compactTablet:
        return 20;
      case AppDeviceType.tablet:
        return 24;
      case AppDeviceType.largeTablet:
        return 28;
    }
  }

  EdgeInsets get pagePadding => EdgeInsets.symmetric(
        horizontal: pagePaddingH,
        vertical: pagePaddingV,
      );

  /// List / card grid columns.
  int get listColumns {
    if (isPhone) return 1;
    if (isCompactTablet) return isLandscape ? 2 : 1;
    if (isTablet) return 2;
    return isLandscape ? 3 : 2;
  }

  /// KPI / dashboard tile columns.
  int get kpiColumns {
    if (isPhone) return 2;
    if (isCompactTablet) return isLandscape ? 3 : 2;
    if (isTablet) return isLandscape ? 4 : 3;
    return isLandscape ? 4 : 3;
  }

  /// Form field columns (create screens).
  int get formColumns {
    if (isPhone) return 1;
    if (isCompactTablet && isPortrait) return 1;
    return 2;
  }

  /// Land / module hub grid columns.
  int get moduleColumns {
    if (isPhone) return 2;
    if (isCompactTablet) return isLandscape ? 3 : 2;
    if (isTablet) return isLandscape ? 4 : 3;
    return isLandscape ? 4 : 3;
  }

  /// Dialog / bottom-sheet max width.
  double get sheetMaxWidth {
    if (isPhone) return width;
    if (isCompactTablet) return 480;
    if (isTablet) return 520;
    return 560;
  }

  // ── Scaling helpers ──────────────────────────────────────────────

  double s(double value) => value * scale;

  /// Scales a design font size and clamps to a readable range.
  ///
  /// Defaults keep captions ≥ 11–12px even on small phones / min scale.
  double sp(
    double value, {
    double min = 11,
    double max = 40,
  }) {
    final scaled = value * scale;
    final withA11y = scaled * textScaleFactor.clamp(1.0, 1.3);
    return withA11y.clamp(min, max).toDouble();
  }

  double wp(double fraction) => width * fraction;

  double hp(double fraction) => height * fraction;

  /// Prefer [s] on tablet; width-% on phone (migration helper).
  double space(double phoneWidthFraction, {double? tabletToken}) {
    if (isPhone) return wp(phoneWidthFraction);
    return s(
      tabletToken ?? (phoneWidthFraction * ResponsiveBreakpoints.designWidth),
    );
  }

  factory ResponsiveMetrics.fromMediaQuery(MediaQueryData media) {
    final size = media.size;
    final deviceType = _deviceTypeFor(size);
    // Scale from shortest side so landscape phones/tablets don't explode.
    final rawScale =
        size.shortestSide / ResponsiveBreakpoints.designWidth;
    final scale = rawScale.clamp(
      ResponsiveBreakpoints.minScale,
      ResponsiveBreakpoints.maxScale,
    );

    return ResponsiveMetrics(
      size: size,
      orientation: media.orientation,
      deviceType: deviceType,
      scale: scale.toDouble(),
      textScaleFactor: media.textScaler.scale(1),
    );
  }

  static AppDeviceType _deviceTypeFor(Size size) {
    final shortest = size.shortestSide;
    final width = size.width;

    if (shortest < ResponsiveBreakpoints.phoneMaxShortest) {
      return AppDeviceType.phone;
    }
    if (shortest <= ResponsiveBreakpoints.compactTabletMaxShortest) {
      return AppDeviceType.compactTablet;
    }
    if (shortest <= ResponsiveBreakpoints.regularTabletMaxShortest &&
        width < ResponsiveBreakpoints.expandedWidth) {
      return AppDeviceType.tablet;
    }
    // Wide landscape 10" iPad or any 12.9" class.
    if (shortest >= ResponsiveBreakpoints.largeTabletMinShortest ||
        width >= ResponsiveBreakpoints.expandedWidth) {
      return AppDeviceType.largeTablet;
    }
    return AppDeviceType.tablet;
  }

  @override
  bool operator ==(Object other) {
    return other is ResponsiveMetrics &&
        other.size == size &&
        other.orientation == orientation &&
        other.deviceType == deviceType &&
        other.scale == scale &&
        other.textScaleFactor == textScaleFactor;
  }

  @override
  int get hashCode => Object.hash(
        size,
        orientation,
        deviceType,
        scale,
        textScaleFactor,
      );
}
