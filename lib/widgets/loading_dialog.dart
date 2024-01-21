import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../views/styles.dart';

loadingDialog(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  final safeArea = MediaQuery.of(context).padding.top;
  final themeData = Theme.of(context);

  return Center(
    child: SizedBox(
      height: screenHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SpinKitRing(
            color: primaryColor,
            lineWidth: screenHeight * 0.005,
            size: screenHeight * 0.1,
          ),
          SizedBox(height: screenHeight * 0.01),
          Text("Loading...", style: greyNormalTextStyle),
        ],
      ),
    ),
  );
}
