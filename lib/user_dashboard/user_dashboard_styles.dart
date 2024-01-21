import 'package:flutter/material.dart';

class UserDashBoardStyles {
  // ---------------------------- TextStyles ---------------------------- \\

  textHeading1() {
    return TextStyle(color: fontColor, fontSize: 20, fontFamily: "Roboto", fontWeight: FontWeight.w600);
  }

  textHeading2() {
    return TextStyle(color: fontColor, fontSize: 18, fontFamily: "Roboto", fontWeight: FontWeight.w600);
  }

  textSubHeading1() {
    return TextStyle(color: fontColor, fontSize: 16, fontFamily: "Roboto", fontWeight: FontWeight.w500);
  }

  textSubHeading2() {
    return TextStyle(color: fontColor, fontSize: 14, fontFamily: "Roboto", fontWeight: FontWeight.w500);
  }

  textBody1() {
    return TextStyle(color: fontColor, fontSize: 16, fontFamily: "Roboto", fontWeight: FontWeight.w400);
  }

  textBody2() {
    return TextStyle(color: fontColor, fontSize: 14, fontFamily: "Roboto", fontWeight: FontWeight.w400);
  }

  textCustomBody2(Color fontCustomColor) {
    return TextStyle(color: fontCustomColor, fontSize: 14, fontFamily: "Roboto", fontWeight: FontWeight.w400);
  }

  textCaption() {
    return TextStyle(color: fontColor, fontSize: 15, fontFamily: "Roboto", fontWeight: FontWeight.w500);
  }

  textCustomCaption(Color fontCustomColor) {
    return TextStyle(color: fontCustomColor, fontSize: 12, fontFamily: "Roboto", fontWeight: FontWeight.w400);
  }

  textButton(Color buttonFontColor) {
    return TextStyle(color: buttonFontColor, fontSize: 16, fontFamily: "Roboto", fontWeight: FontWeight.w500);
  }

  // ---------------------------- ColorStyles ---------------------------- \\

  static Color scaffoldColor = Colors.white;
  static Color fontColor = Colors.grey.shade900;
  static Color fontWhiteColor = Colors.white;
  static Color quickStartBackground = Colors.grey.shade300;
  static Color iconLiteColor = Colors.grey.shade700;
  static Color redColor = Colors.red;
  static Color transparentBlack = Colors.black87;
  static Color PrimaryColor = Color(0xFFfdc75b);
}
