import 'package:adgo_mobile/themes/utils.dart';
import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomTextField extends ConsumerStatefulWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? icon;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ProviderListenable<ValidationResult>? validationProvider;
  final int? maxLines;
  final int? maxLength;
  final bool showPasswordToggle; 

  const CustomTextField({
    Key? key,
    this.controller,
    this.validator,
    this.onChanged,
    this.icon,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.validationProvider,
    this.maxLines = 1,
    this.maxLength,
    this.showPasswordToggle = false, 
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends ConsumerState<CustomTextField> {
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Initialize password visibility based on obscureText
    _isPasswordVisible = !widget.obscureText;
  }
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }
  Widget build(BuildContext context) {

     final validationResult = widget.validationProvider != null
        ? ref.watch(widget.validationProvider!)
        : ValidationResult.success();

  // For obscureText fields, ensure maxLines is always 1
    final actualMaxLines = widget.obscureText ? 1 : widget.maxLines;
    final shouldObscureText = widget.obscureText && !_isPasswordVisible;

    return TextFormField(
      maxLength: widget.maxLength,
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      obscureText: shouldObscureText,
      keyboardType: widget.keyboardType,
      maxLines: actualMaxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: primaryLightColor.withAlpha((0.08 * 255).toInt()),
        errorText: validationResult.isValid ? null : validationResult.error,
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: primaryDarkColor.withAlpha((0.4 * 255).toInt()),
          fontSize: 16,
        ),
        prefixIcon: widget.icon != null
            ? Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
                child: Icon(
                  widget.icon,
                  color: primaryDarkColor.withAlpha((0.5 * 255).toInt()),
                  size: 22,
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: widget.showPasswordToggle && widget.obscureText
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: primaryDarkColor.withAlpha((0.5 * 255).toInt()),
                  size: 22,
                ),
                onPressed: _togglePasswordVisibility,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryLightColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }
}
