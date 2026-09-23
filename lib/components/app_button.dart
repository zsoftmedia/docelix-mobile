import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

// Loading
  final bool isLoading;
  final double loadingSize;
  final double loadingStrokeWidth;

// Size
  final double? width;
  final double? height;

// Colors
  final Color backgroundColor;
  final Color disabledBackgroundColor;
  final Color foregroundColor;
  final Color loadingColor;

// Style
  final double borderRadius;
  final double elevation;
  final double fontSize;
  final FontWeight fontWeight;

// Optional icon
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;

// Border
  final Color? borderColor;
  final double borderWidth;

  const AppButton({
    super.key,

    required this.text,
    required this.onPressed,

    this.isLoading = false,

    this.loadingSize = 22,
    this.loadingStrokeWidth = 2.5,

    this.width = double.infinity,
    this.height = 50,

    this.backgroundColor = Colors.blue,
    this.disabledBackgroundColor = Colors.blue,
    this.foregroundColor = Colors.white,
    this.loadingColor = Colors.white,

    this.borderRadius = 4,
    this.elevation = 0,

    this.fontSize = 16,
    this.fontWeight = FontWeight.w700,

    this.icon,
    this.leading,
    this.trailing,

    this.borderColor,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = isLoading || onPressed == null;

    return SizedBox(
      width: width,
      height: height,

      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,

          disabledBackgroundColor: disabledBackgroundColor,

          foregroundColor: foregroundColor,

          disabledForegroundColor: foregroundColor,

          elevation: elevation,

          padding: EdgeInsets.zero,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),

            side: borderColor != null
                ? BorderSide(
              color: borderColor!,
              width: borderWidth,
            )
                : BorderSide.none,
          ),
        ),

        child: isLoading
            ? SizedBox(
          width: loadingSize,
          height: loadingSize,

          child: CircularProgressIndicator(
            strokeWidth: loadingStrokeWidth,

            valueColor: AlwaysStoppedAnimation<Color>(
              loadingColor,
            ),
          ),
        )

            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,

          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 8),
            ],

            if (icon != null) ...[
              Icon(icon),
              const SizedBox(width: 8),
            ],

            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: foregroundColor,
              ),
            ),

            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}