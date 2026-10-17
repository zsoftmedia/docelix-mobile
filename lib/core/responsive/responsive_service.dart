import 'package:docelix_mobileapp/core/responsive/responsive_breakpoints.dart';
import 'package:docelix_mobileapp/core/responsive/responsive_metrics.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// GetX-backed holder for the latest [ResponsiveMetrics].
///
/// Prefer `context.rs` in widgets. Use this service only when a BuildContext
/// is unavailable (controllers, helpers). Always call after first frame.
class ResponsiveService extends GetxService {
  final Rxn<ResponsiveMetrics> metrics = Rxn<ResponsiveMetrics>();

  ResponsiveMetrics get current {
    final value = metrics.value;
    if (value != null) return value;

    // Safe fallback before first frame / scope attach.
    return const ResponsiveMetrics(
      size: Size(
        ResponsiveBreakpoints.designWidth,
        ResponsiveBreakpoints.designHeight,
      ),
      orientation: Orientation.portrait,
      deviceType: AppDeviceType.phone,
      scale: 1,
      textScaleFactor: 1,
    );
  }

  AppDeviceType get deviceType => current.deviceType;
  bool get isPhone => current.isPhone;
  bool get isTabletOrLarger => current.isTabletOrLarger;

  void updateMetrics(ResponsiveMetrics next) {
    final prev = metrics.value;
    if (prev == next) return;
    metrics.value = next;
  }

  double s(double value) => current.s(value);
  double sp(double value) => current.sp(value);
  double wp(double fraction) => current.wp(fraction);
}
