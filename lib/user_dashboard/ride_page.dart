import 'package:flutter/material.dart';

import 'user_dashboard_styles.dart';

class RidePage extends StatefulWidget {
  @override
  _RidePageState createState() => _RidePageState();
}

class _RidePageState extends State<RidePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Text(
        "Ride Page",
        style: UserDashBoardStyles().textHeading1(),
      )),
    );
  }
}
