import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_restaurant/constants.dart';

// ignore: must_be_immutable
class TextFormFieldWidget extends StatelessWidget {
  TextEditingController controller;
  String? Function(String?)? validate;
  Function(String?)? onFieldSubmitted;
  String hintText;
  TextInputType? textInputType;
  TextInputAction? textInputAction;
  bool obscureText;

  TextFormFieldWidget({
    Key? key,
    required this.controller,
    required this.validate,
    required this.hintText,
    this.textInputAction,
    this.textInputType,
    this.onFieldSubmitted,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        obscureText: obscureText,
        textAlignVertical: TextAlignVertical.center,
        textInputAction: textInputAction ?? TextInputAction.next,
        validator: validate,
        controller: controller,
        style: const TextStyle(fontSize: 18.0),
        keyboardType: textInputType ?? TextInputType.text,
        cursorColor: Color(COLOR_PRIMARY),
        onFieldSubmitted: onFieldSubmitted,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
          hintText: hintText.tr(),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0)),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).errorColor),
            borderRadius: BorderRadius.circular(25.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).errorColor),
            borderRadius: BorderRadius.circular(25.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(25.0),
          ),
        ));
  }
}

class UnderLineTextFormFieldWidget extends StatelessWidget {
  final TextEditingController? controller;
  final bool? enabled;
  final bool? readOnly;
  final String hintText;
  final String? initialValue;
  final TextInputType textInputType;
  final int? maxLines;
  final Widget? prefix;
  final Widget? suffix;
  final Function()? onTap;
  final InputDecoration? decoration;
  final Function(String)? onChanged;
  final bool? obscureText;
  final FormFieldValidator<String?>? validator;

  const UnderLineTextFormFieldWidget(
      {Key? key,
      this.enabled,
      required this.hintText,
      this.initialValue,
      this.controller,
      this.maxLines,
      this.textInputType = TextInputType.text,
      this.prefix,
      this.onTap,
      this.decoration,
      this.onChanged,
      this.validator,
      this.obscureText,
      this.suffix,
      this.readOnly})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlignVertical: TextAlignVertical.center,
      controller: controller,
      validator: validator,
      readOnly: readOnly ?? false,
      enabled: enabled ?? true,
      obscureText: obscureText ?? false,
      onTap: onTap,
      onChanged: onChanged,
      initialValue: initialValue,
      style: const TextStyle(fontSize: 18.0),
      cursorColor: Colors.grey,
      maxLines: maxLines ?? 1,
      keyboardType: textInputType,
      decoration: InputDecoration(
        errorMaxLines: 4,
        prefixIcon: prefix,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.all(10),
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 14),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder:  OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
