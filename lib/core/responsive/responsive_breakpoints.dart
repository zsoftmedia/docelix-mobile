/// Canonical layout breakpoints for Docelix phone / 7" tablet / 10" iPad+.
///
/// Classification uses **shortest side** so portrait and landscape stay stable
/// on the same device, then orientation refines columns and content width.
///
/// Typical logical shortest sides:
/// - phones: ~320–430
/// - 7" tablets: ~600–700
/// - 10" iPad: ~768–834
/// - 12.9" iPad Pro: ~1024+
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  /// Compact / phone.
  static const double phoneMaxShortest = 599;

  /// Compact tablet (~7") upper bound on shortest side.
  static const double compactTabletMaxShortest = 719;

  /// Regular tablet / 10" iPad upper bound on shortest side.
  static const double regularTabletMaxShortest = 899;

  /// Above this shortest side → large tablet / iPad Pro class.
  static const double largeTabletMinShortest = 900;

  /// Landscape expanded width threshold.
  static const double expandedWidth = 1024;

  /// Design reference width used for proportional scaling (iPhone class).
  static const double designWidth = 390;

  /// Design reference height.
  static const double designHeight = 844;

  /// Soft cap so tablet text/spacing does not become huge.
  static const double maxScale = 1.25;

  /// Soft floor for very small phones.
  static const double minScale = 0.85;

  // Content max widths (centered column)
  static const double compactTabletContentMaxWidth = 560;
  static const double regularTabletContentMaxWidth = 720;
  static const double largeTabletContentMaxWidth = 900;
  static const double largeTabletLandscapeContentMaxWidth = 1100;

  // Auth / narrow form column
  static const double authFormMaxWidth = 440;
  static const double authFormMaxWidthLarge = 480;
}

/// Coarse device bucket used by layouts.
enum AppDeviceType {
  /// Phones (< 600 shortest side).
  phone,

  /// ~7" tablets (600–719 shortest side).
  compactTablet,

  /// ~10" iPad class (720–899 shortest side).
  tablet,

  /// Large iPad / iPad Pro / wide landscape (900+ shortest or very wide).
  largeTablet,
}

extension AppDeviceTypeX on AppDeviceType {
  bool get isPhone => this == AppDeviceType.phone;

  bool get isCompactTablet => this == AppDeviceType.compactTablet;

  bool get isRegularTablet => this == AppDeviceType.tablet;

  bool get isLargeTablet => this == AppDeviceType.largeTablet;

  bool get isTabletOrLarger => this != AppDeviceType.phone;

  String get label {
    switch (this) {
      case AppDeviceType.phone:
        return 'Phone';
      case AppDeviceType.compactTablet:
        return '7\" tablet';
      case AppDeviceType.tablet:
        return '10\" tablet / iPad';
      case AppDeviceType.largeTablet:
        return 'Large iPad / landscape';
    }
  }
}
