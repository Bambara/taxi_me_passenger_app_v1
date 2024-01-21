import 'package:flutter/material.dart';

import 'user_dashboard_styles.dart';

class FoodsPage extends StatefulWidget {
  @override
  _FoodsPageState createState() => _FoodsPageState();
}

class _FoodsPageState extends State<FoodsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Text(
        "Foods Page",
        style: UserDashBoardStyles().textHeading1(),
      )),
    );
  }
}
