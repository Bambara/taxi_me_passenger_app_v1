import 'package:flutter/material.dart';

import '../core/constants/constants.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget(
      {Key? key,
      required this.hintText,
      required this.label,
      required this.isRequired,
      required this.txtCtrl,
      required this.fontSize,
      required this.secret,
      required this.heightFactor,
      required this.widthFactor,
      required this.inputType})
      : super(key: key);

  final String hintText;
  final String label;
  final bool isRequired;
  final bool secret;
  final TextEditingController txtCtrl;
  final double fontSize;
  final double heightFactor;
  final double widthFactor;
  final TextInputType inputType;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        label.isEmpty
            ? SizedBox(height: screenHeight * 0.005)
            : Container(
                width: screenWidth * (widthFactor - 0.05),
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: screenHeight * 0.005, top: screenHeight * 0.01),
                child: Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: screenWidth * Constants.textFontSize, color: Colors.black54),
                    ),
                    SizedBox(width: screenWidth * 0.002),
                    isRequired
                        ? Text(
                            "*",
                            style: TextStyle(fontSize: screenWidth * Constants.textFontSize, color: Colors.red),
                          )
                        : const Text(""),
                  ],
                ),
              ),
        Container(
          width: screenWidth * widthFactor,
          height: screenHeight * heightFactor,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(Constants.boarderRadius)),
            border: Border.all(color: Colors.black54, width: 0.5),
          ),
          child: Center(
            child: SizedBox(
              width: screenWidth * (widthFactor - 0.1),
              child: TextField(
                style: TextStyle(fontSize: screenWidth * fontSize),
                keyboardType: inputType,
                textInputAction: TextInputAction.next,
                controller: txtCtrl,
                obscureText: secret,
                autocorrect: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  // labelText: widget.hintText,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
