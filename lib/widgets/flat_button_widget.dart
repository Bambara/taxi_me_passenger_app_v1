import 'package:flutter/material.dart';

import '../core/constants/constants.dart';

class FlatButtonWidget extends StatelessWidget {
  const FlatButtonWidget({Key? key, required this.title, required this.function, required this.heightFactor, required this.widthFactor, required this.bgColor, required this.textColor})
      : super(key: key);

  final String title;
  final Function function;
  final num heightFactor;
  final num widthFactor;
  final Color bgColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final themeData = Theme.of(context);

    return SizedBox(
      width: screenWidth * widthFactor,
      height: screenHeight * heightFactor,
      child: MaterialButton(
        color: bgColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(Constants.boarderRadius),
          ),
        ),
        onPressed: () {
          function.call();
          // widget.loadSignup(context);
        },
        child: Center(
          child: Text(title, style: TextStyle(fontWeight: FontWeight.normal, fontSize: themeData.textTheme.bodyText1!.fontSize, color: textColor)),
        ),
      ),
    );
  }
}
