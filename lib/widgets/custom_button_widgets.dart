import 'package:flutter/material.dart';

import '../user_dashboard/user_dashboard_styles.dart';

class CustomButtonWidget extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color color;
  final VoidCallback onClicked;

  const CustomButtonWidget({
    required this.text,
    required this.onClicked,
    required this.textColor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Material(
          borderRadius: BorderRadius.circular(10.0),
          color: color,
          child: MaterialButton(
            minWidth: MediaQuery.of(context).size.width,
            onPressed: onClicked,
            child: Container(
              alignment: Alignment.center,
              child: Text(text, textAlign: TextAlign.center, style: UserDashBoardStyles().textButton(UserDashBoardStyles.fontWhiteColor)),
            ),
          ),
        ),
      );
}
