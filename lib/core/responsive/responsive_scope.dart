import 'package:docelix_mobileapp/core/responsive/responsive_metrics.dart';
import 'package:docelix_mobileapp/core/responsive/responsive_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Places [ResponsiveMetrics] in the tree and keeps [ResponsiveService] in sync.
class ResponsiveScope extends StatelessWidget {
  const ResponsiveScope({super.key, required this.child});

  final Widget child;

  static ResponsiveMetrics of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_ResponsiveInherited>();
    assert(
      inherited != null,
      'ResponsiveScope not found. Wrap the app with ResponsiveScope '
      '(see main.dart GetMaterialApp.builder).',
    );
    return inherited!.metrics;
  }

  static ResponsiveMetrics? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ResponsiveInherited>()
        ?.metrics;
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ResponsiveMetrics.fromMediaQuery(MediaQuery.of(context));

    if (Get.isRegistered<ResponsiveService>()) {
      Get.find<ResponsiveService>().updateMetrics(metrics);
    }

    return _ResponsiveInherited(
      metrics: metrics,
      child: child,
    );
  }
}

class _ResponsiveInherited extends InheritedWidget {
  const _ResponsiveInherited({
    required this.metrics,
    required super.child,
  });

  final ResponsiveMetrics metrics;

  @override
  bool updateShouldNotify(_ResponsiveInherited oldWidget) {
    return metrics != oldWidget.metrics;
  }
}
