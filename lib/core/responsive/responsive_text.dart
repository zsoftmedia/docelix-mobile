import 'package:docelix_mobileapp/core/responsive/responsive_breakpoints.dart';
import 'package:docelix_mobileapp/core/responsive/responsive_extensions.dart';
import 'package:docelix_mobileapp/core/responsive/responsive_metrics.dart';
import 'package:flutter/material.dart';

/// Readable typography floors / caps (logical px before final clamp in [sp]).
class AppTextTokens {
  AppTextTokens._();

  /// Never render body/caption copy below this after scaling.
  static const double minReadable = 12;

  /// Soft floor for overline / dense chips (still readable).
  static const double minDense = 11;

  static const double maxDisplay = 40;

  // Design-token bases (at designWidth 390, scale 1.0)
  static const double display = 28;
  static const double headline = 22;
  static const double title = 18;
  static const double titleSm = 16;
  static const double body = 15;
  static const double bodySm = 14;
  static const double label = 13;
  static const double caption = 12;
  static const double overline = 11;
  static const double amountLg = 26;
  static const double amount = 16;
}

/// Semantic text roles for Docelix UI.
enum AppTextRole {
  /// Large hero numbers (e.g. net profit).
  display,

  /// Screen / section headlines.
  headline,

  /// Card / list titles.
  title,

  /// Secondary titles.
  titleSm,

  /// Primary body copy.
  body,

  /// Compact body.
  bodySm,

  /// Field labels, chip text.
  label,

  /// Helper / meta under values.
  caption,

  /// Uppercase section tags (e.g. FINANCIAL OVERVIEW).
  overline,

  /// Standard money figures in KPI tiles.
  amount,

  /// Large money figures.
  amountLg,
}

/// Typed styles built from current [ResponsiveMetrics].
class AppTextStyles {
  AppTextStyles(this.rs);

  factory AppTextStyles.of(BuildContext context) => AppTextStyles(context.rs);

  final ResponsiveMetrics rs;

  TextStyle role(
    AppTextRole role, {
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    final base = switch (role) {
      AppTextRole.display => rs.sp(AppTextTokens.display, min: 22, max: AppTextTokens.maxDisplay),
      AppTextRole.headline => rs.sp(AppTextTokens.headline, min: 18),
      AppTextRole.title => rs.sp(AppTextTokens.title, min: 16),
      AppTextRole.titleSm => rs.sp(AppTextTokens.titleSm, min: 14),
      AppTextRole.body => rs.sp(AppTextTokens.body, min: 13),
      AppTextRole.bodySm => rs.sp(AppTextTokens.bodySm, min: 13),
      AppTextRole.label => rs.sp(AppTextTokens.label, min: AppTextTokens.minReadable),
      AppTextRole.caption => rs.sp(AppTextTokens.caption, min: AppTextTokens.minReadable),
      AppTextRole.overline => rs.sp(AppTextTokens.overline, min: AppTextTokens.minDense),
      AppTextRole.amount => rs.sp(AppTextTokens.amount, min: 14),
      AppTextRole.amountLg => rs.sp(AppTextTokens.amountLg, min: 20, max: AppTextTokens.maxDisplay),
    };

    final weight = fontWeight ??
        switch (role) {
          AppTextRole.display || AppTextRole.amountLg => FontWeight.w700,
          AppTextRole.headline || AppTextRole.title || AppTextRole.amount =>
            FontWeight.w600,
          AppTextRole.overline => FontWeight.w500,
          _ => FontWeight.w400,
        };

    final tracking = letterSpacing ??
        switch (role) {
          AppTextRole.overline => 1.0,
          AppTextRole.display || AppTextRole.amountLg => -0.4,
          _ => null,
        };

    return TextStyle(
      fontSize: base,
      fontWeight: weight,
      color: color,
      letterSpacing: tracking,
      height: height,
      decoration: decoration,
    );
  }

  TextStyle display({Color? color, FontWeight? fontWeight}) =>
      role(AppTextRole.display, color: color, fontWeight: fontWeight);

  TextStyle headline({Color? color, FontWeight? fontWeight}) =>
      role(AppTextRole.headline, color: color, fontWeight: fontWeight);

  TextStyle title({Color? color, FontWeight? fontWeight}) =>
      role(AppTextRole.title, color: color, fontWeight: fontWeight);

  TextStyle titleSm({Color? color, FontWeight? fontWeight}) =>
      role(AppTextRole.titleSm, color: color, fontWeight: fontWeight);

  TextStyle body({Color? color, FontWeight? fontWeight}) =>
      role(AppTextRole.body, color: color, fontWeight: fontWeight);

  TextStyle bodySm({Color? color, FontWeight? fontWeight}) =>
      role(AppTextRole.bodySm, color: color, fontWeight: fontWeight);

  TextStyle label({Color? color, FontWeight? fontWeight}) =>
      role(AppTextRole.label, color: color, fontWeight: fontWeight);

  TextStyle caption({Color? color, FontWeight? fontWeight}) =>
      role(AppTextRole.caption, color: color, fontWeight: fontWeight);

  TextStyle overline({Color? color, FontWeight? fontWeight}) =>
      role(AppTextRole.overline, color: color, fontWeight: fontWeight);

  TextStyle amount({Color? color, FontWeight? fontWeight}) =>
      role(AppTextRole.amount, color: color, fontWeight: fontWeight);

  TextStyle amountLg({Color? color, FontWeight? fontWeight}) =>
      role(AppTextRole.amountLg, color: color, fontWeight: fontWeight);
}

/// Convenience text widget using [AppTextRole].
class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    this.role = AppTextRole.body,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.letterSpacing,
    this.height,
    this.softWrap,
  });

  final String data;
  final AppTextRole role;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? letterSpacing;
  final double? height;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.of(context).role(
      role,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );

    return Text(
      data,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

extension AppTextContextX on BuildContext {
  AppTextStyles get appText => AppTextStyles.of(this);
}

extension ResponsiveFontMetricsX on ResponsiveMetrics {
  /// Maps legacy `width * fraction` font sizing to a readable scaled size.
  ///
  /// Example: replace `fontSize: width * 0.022` with `rs.fs(0.022)`.
  double fs(double widthFraction) {
    final designPx = widthFraction * ResponsiveBreakpoints.designWidth;
    final boosted =
        designPx < AppTextTokens.minReadable ? AppTextTokens.minReadable : designPx;
    return sp(
      boosted,
      min: AppTextTokens.minDense,
      max: AppTextTokens.maxDisplay,
    );
  }
}

extension LegacyWidthFontX on double {
  /// Readable font from legacy `this * fraction` where `this` is layout width.
  ///
  /// Prefer [ResponsiveMetrics.fs] when [ResponsiveMetrics] is available.
  /// Use this in helpers that only receive a `width` token.
  double fontSizeW(double fraction) {
    final raw = this * fraction;
    if (raw >= AppTextTokens.minReadable) return raw;
    return AppTextTokens.minReadable;
  }
}
