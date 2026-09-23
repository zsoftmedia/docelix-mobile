import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
// ============================================================
// CONTROLLER
// ============================================================

  final TextEditingController? controller;

// ============================================================
// TEXT
// ============================================================

  final String? hintText;
  final String? labelText;

// ============================================================
// ICONS
// ============================================================

  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;

// ============================================================
// INPUT
// ============================================================

  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;

// ============================================================
// VALIDATION / EVENTS
// ============================================================

  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(String)? onFieldSubmitted;

// ============================================================
// DROPDOWN
// ============================================================

  final bool isDropdown;

  final List<String>? dropdownItems;

  final String? selectedValue;

  final void Function(String?)? onDropdownChanged;

  final IconData dropdownIcon;

// ============================================================
// COLORS
// ============================================================

  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? fillColor;
  final Color? textColor;
  final Color? hintColor;

// ============================================================
// BORDER
// ============================================================

  final double? borderWidth;
  final double? focusedBorderWidth;
  final double? borderRadius;

// ============================================================
// TEXT SIZE
// ============================================================

  final double? fontSize;
  final double? hintFontSize;

// ============================================================
// PADDING
// ============================================================

  final EdgeInsetsGeometry? contentPadding;

// ============================================================
// LINES
// ============================================================

  final int? maxLines;
  final int? minLines;
  final int? maxLength;

// ============================================================
// CAPITALIZATION
// ============================================================

  final TextCapitalization textCapitalization;

  const AppTextField({
    super.key,

// Controller
    this.controller,

// Text
    this.hintText,
    this.labelText,

// Icons
    this.prefixIcon,
    this.prefix,
    this.suffix,

// Input
    this.keyboardType,
    this.inputFormatters,

    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,

// Validation / Events
    this.validator,
    this.onChanged,
    this.onTap,
    this.onFieldSubmitted,

// Dropdown
    this.isDropdown = false,
    this.dropdownItems,
    this.selectedValue,
    this.onDropdownChanged,
    this.dropdownIcon = Icons.keyboard_arrow_down,

// Colors
    this.borderColor = const Color(0xFF333333),
    this.focusedBorderColor = const Color(0xFF222222),
    this.fillColor = Colors.white,
    this.textColor = const Color(0xFF222222),
    this.hintColor = const Color(0xFF9A9A9A),

// Border
    this.borderWidth = 1.2,
    this.focusedBorderWidth = 1.8,
    this.borderRadius = 4,

// Text size
    this.fontSize = 16,
    this.hintFontSize = 16,

// Padding
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 15,
    ),

// Lines
    this.maxLines = 1,
    this.minLines,
    this.maxLength,

// Capitalization
    this.textCapitalization = TextCapitalization.none,
  });

// ============================================================
// BUILD
// ============================================================

  @override
  Widget build(BuildContext context) {
// ----------------------------------------------------------
// DROPDOWN
// ----------------------------------------------------------

    if (isDropdown) {
      return DropdownButtonFormField<String>(
        value: selectedValue,

        items: (dropdownItems ?? [])
            .map(
              (item) => DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                fontSize: fontSize,
                color: textColor,
              ),
            ),
          ),
        )
            .toList(),

        onChanged: enabled
            ? onDropdownChanged
            : null,

        validator: validator,

        icon: Icon(
          dropdownIcon,
          color: textColor,
        ),

        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
        ),

        decoration: _inputDecoration(),
      );
    }

// ----------------------------------------------------------
// NORMAL TEXT FIELD
// ----------------------------------------------------------

    return TextFormField(
      controller: controller,

      keyboardType: keyboardType,
      inputFormatters: inputFormatters,

      obscureText: obscureText,
      readOnly: readOnly,
      enabled: enabled,
      autofocus: autofocus,

      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,

      textCapitalization: textCapitalization,

      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
      ),

      onChanged: onChanged,
      onTap: onTap,
      onFieldSubmitted: onFieldSubmitted,

      validator: validator,

      decoration: _inputDecoration(),
    );
  }

// ============================================================
// INPUT DECORATION
// ============================================================

  InputDecoration _inputDecoration() {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,

      hintStyle: TextStyle(
        color: hintColor,
        fontSize: hintFontSize,
      ),

      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon)
          : null,

      prefix: prefix,
      suffix: suffix,

      contentPadding: contentPadding,

      filled: true,
      fillColor: fillColor,

// --------------------------------------------------------
// BORDER
// --------------------------------------------------------

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          borderRadius!,
        ),
        borderSide: BorderSide(
          color: borderColor!,
          width: borderWidth!,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          borderRadius!,
        ),
        borderSide: BorderSide(
          color: borderColor!,
          width: borderWidth!,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          borderRadius!,
        ),
        borderSide: BorderSide(
          color: focusedBorderColor!,
          width: focusedBorderWidth!,
        ),
      ),

      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          borderRadius!,
        ),
        borderSide: BorderSide(
          color: borderColor!.withOpacity(0.5),
          width: borderWidth!,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          borderRadius!,
        ),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.2,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          borderRadius!,
        ),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.8,
        ),
      ),
    );
  }
}