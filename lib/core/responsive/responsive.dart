/// Docelix responsive foundation.
///
/// Usage:
/// ```dart
/// import 'package:docelix_mobileapp/core/responsive/responsive.dart';
///
/// // In a widget:
/// final rs = context.rs;
/// Text('Title', style: TextStyle(fontSize: context.sp(18)));
/// Text('Caption', style: context.appText.caption());
/// AppText('Net profit', role: AppTextRole.titleSm);
/// // Legacy width*fraction fonts:
/// fontSize: width.fontSizeW(0.022)  // or rs.fs(0.022)
/// Padding(padding: EdgeInsets.all(context.s(16)));
///
/// // Cap width on tablet:
/// return ResponsivePage(child: ...);
/// ```
library;

export 'responsive_breakpoints.dart';
export 'responsive_extensions.dart';
export 'responsive_metrics.dart';
export 'responsive_scope.dart';
export 'responsive_service.dart';
export 'responsive_text.dart';
export 'responsive_widgets.dart';
