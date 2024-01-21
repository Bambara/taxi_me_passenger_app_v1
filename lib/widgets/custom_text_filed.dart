import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../views/styles.dart';

class CustomTextFiled extends StatelessWidget {
  TextEditingController controller;
  TextCapitalization textCapitalization;
  TextInputType keyboardType;
  String type; //phoneNumber || nic || email
  bool readOnly;
  bool enabled;
  int minLine;
  int maxLine;
  String hint;
  TextStyle hintStyle;
  String labelText;
  String prifixIcon;
  bool obscureText;
  double width, height;
  String Function(dynamic) validator;

  CustomTextFiled(
      {super.key,
      required this.controller,
      required this.hint,
      required this.validator,
      this.textCapitalization = TextCapitalization.none,
      this.keyboardType = TextInputType.text,
      required this.type,
      this.readOnly = false,
      this.enabled = true,
      this.minLine = 1,
      this.maxLine = 1,
      this.hintStyle = HintStyle1,
      required this.labelText,
      required this.prifixIcon,
      this.obscureText = false,
      required this.height,
      required this.width});

  static InputBorder enabledBorder =
      const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5.0)), borderSide: BorderSide(color: Colors.black, width: 0.5)); //for some reason can't give through variable

  static InputBorder errorBorder = const OutlineInputBorder(borderSide: BorderSide(color: Colors.red));

  inputFormatter() {
    if (type == "phoneNumber") {
      return [
        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
        FilteringTextInputFormatter.deny(RegExp(r'^0+')),
        FilteringTextInputFormatter.deny(RegExp(r'^94+')),
        LengthLimitingTextInputFormatter(9),
      ];
    }
    if (type == "nic") {
      return [
        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
        FilteringTextInputFormatter.allow(RegExp('[x|X|v|V]')),
        LengthLimitingTextInputFormatter(12),
      ];
    }
    if (type == "number") {
      return [
        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SizedBox(
        width: width ?? MediaQuery.of(context).size.width - 120,
        height: height ?? 45,
        // margin: EdgeInsets.only(left: 20, right: 20, top: 10),
        child: TextFormField(
          style: greyNormalTextStyle,
          maxLines: maxLine,
          minLines: minLine,
          keyboardType: keyboardType,
          autofocus: false,
          inputFormatters: inputFormatter(),
          textCapitalization: textCapitalization,
          validator: validator,
          controller: controller,
          obscureText: obscureText,
          readOnly: readOnly,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: greyNormalTextStyle,
            labelText: labelText,
            labelStyle: greyNormalTextStyle,
            contentPadding: const EdgeInsets.fromLTRB(25.0, 10.0, 20.0, 5.0),
            border: InputBorder.none,
            enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
            errorBorder: errorBorder,
            disabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
            focusedErrorBorder: errorBorder,
            focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
            enabled: enabled,
          ),
        ),
      ),
      // Container(
      //   width: 35,
      //   height: 35,
      //   color: Colors.amber,
      //   margin: EdgeInsets.only(left: 3, top: 7),
      //   child: Image.asset(prifixIcon),
      // )
    ]);
  }
}
