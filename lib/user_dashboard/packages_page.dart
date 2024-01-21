import 'package:flutter/material.dart';

import 'user_dashboard_styles.dart';

class PackagesPage extends StatefulWidget {
  @override
  _PackagesPageState createState() => _PackagesPageState();
}

class _PackagesPageState extends State<PackagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Text(
        "Packages Page",
        style: UserDashBoardStyles().textHeading1(),
      )),
    );
  }
}
