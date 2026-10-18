import 'package:docelix_mobileapp/core/responsive/responsive_breakpoints.dart';
import 'package:docelix_mobileapp/core/responsive/responsive_extensions.dart';
import 'package:docelix_mobileapp/core/responsive/responsive_metrics.dart';
import 'package:docelix_mobileapp/core/responsive/responsive_scope.dart';
import 'package:flutter/material.dart';

/// Rebuilds when viewport metrics change.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, ResponsiveMetrics rs) builder;

  @override
  Widget build(BuildContext context) {
    final rs = ResponsiveScope.of(context);
    return builder(context, rs);
  }
}

/// Centers content and caps width on tablet / iPad.
class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final capped = maxWidth ?? rs.contentMaxWidth;

    return ColoredBox(
      color: backgroundColor ?? Colors.transparent,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: capped),
          child: Padding(
            padding: padding ?? rs.pagePadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Horizontal page padding that adapts by device.
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.includeVertical = false,
  });

  final Widget child;
  final bool includeVertical;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    return Padding(
      padding: includeVertical
          ? rs.pagePadding
          : EdgeInsets.symmetric(horizontal: rs.pagePaddingH),
      child: child,
    );
  }
}

/// Simple adaptive gap (uses scaled tokens on tablet, width-% on phone).
class ResponsiveGap extends StatelessWidget {
  const ResponsiveGap({
    super.key,
    this.phoneWidthFraction = 0.03,
    this.tabletToken,
    this.axis = Axis.vertical,
  });

  final double phoneWidthFraction;
  final double? tabletToken;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final size = context.rs.space(
      phoneWidthFraction,
      tabletToken: tabletToken,
    );
    return axis == Axis.vertical
        ? SizedBox(height: size)
        : SizedBox(width: size);
  }
}

/// Grid that picks column count from [ResponsiveMetrics] (or override).
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.columns,
    this.spacing,
    this.runSpacing,
    this.childAspectRatio,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
    this.padding = EdgeInsets.zero,
  });

  final List<Widget> children;
  final int? columns;
  final double? spacing;
  final double? runSpacing;
  final double? childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final cols = columns ?? rs.listColumns;
    final gap = spacing ?? rs.s(12);
    final runGap = runSpacing ?? gap;

    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      crossAxisSpacing: gap,
      mainAxisSpacing: runGap,
      childAspectRatio: childAspectRatio ?? (rs.isPhone ? 1.55 : 1.7),
      children: children,
    );
  }
}

/// Constrains modal / bottom-sheet content width on large screens.
class ResponsiveSheetBody extends StatelessWidget {
  const ResponsiveSheetBody({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom +
        MediaQuery.paddingOf(context).bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: rs.sheetMaxWidth),
        child: Padding(
          padding: padding ??
              EdgeInsets.fromLTRB(
                rs.pagePaddingH,
                rs.s(16),
                rs.pagePaddingH,
                rs.s(16) + bottomInset,
              ),
          child: child,
        ),
      ),
    );
  }
}

/// Centers and caps dialog / alert width on tablet / iPad.
class ResponsiveDialogBody extends StatelessWidget {
  const ResponsiveDialogBody({
    super.key,
    required this.child,
    this.maxWidth,
  });

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? rs.sheetMaxWidth,
        ),
        child: child,
      ),
    );
  }
}

/// Two-pane shell for tablet: optional side panel + body.
class ResponsiveSplitView extends StatelessWidget {
  const ResponsiveSplitView({
    super.key,
    required this.primary,
    this.secondary,
    this.primaryFlex = 5,
    this.secondaryFlex = 4,
    this.breakpointUsesSplit = true,
  });

  final Widget primary;
  final Widget? secondary;
  final int primaryFlex;
  final int secondaryFlex;
  final bool breakpointUsesSplit;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final showSplit =
        breakpointUsesSplit && rs.isTabletOrLarger && secondary != null;

    if (!showSplit) return primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: primaryFlex, child: primary),
        VerticalDivider(width: 1, color: Colors.black.withValues(alpha: 0.08)),
        Expanded(flex: secondaryFlex, child: secondary!),
      ],
    );
  }
}

/// Value that switches by device type without rebuilding callers manually.
T responsiveValue<T>(
  BuildContext context, {
  required T phone,
  T? compactTablet,
  T? tablet,
  T? largeTablet,
}) {
  final rs = context.rs;
  switch (rs.deviceType) {
    case AppDeviceType.phone:
      return phone;
    case AppDeviceType.compactTablet:
      return compactTablet ?? tablet ?? phone;
    case AppDeviceType.tablet:
      return tablet ?? compactTablet ?? phone;
    case AppDeviceType.largeTablet:
      return largeTablet ?? tablet ?? compactTablet ?? phone;
  }
}

/// Centered, width-capped column for auth / simple forms (phone full width).
class ResponsiveAuthShell extends StatelessWidget {
  const ResponsiveAuthShell({
    super.key,
    required this.child,
    this.horizontalPadding,
  });

  final Widget child;
  final double? horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final padH = horizontalPadding ??
        (rs.isPhone ? rs.wp(0.07) : rs.s(24));

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: rs.authFormMaxWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padH),
            child: child,
          ),
        ),
      ),
    );
  }
}
