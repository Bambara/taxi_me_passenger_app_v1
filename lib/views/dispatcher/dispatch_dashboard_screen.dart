import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:page_transition/page_transition.dart';

import '../../Widgets/loading_dialog.dart';
import '../../core/constants/constants.dart';
import '../../utils/api_client.dart';
import '../../utils/color_constant.dart';
import '../../utils/settings.dart';
import 'dispatch_create_screen.dart';
import 'dispatch_history_screen.dart';

class DispatcherDash extends StatefulWidget {
  @override
  _DispatcherDashState createState() => new _DispatcherDashState();
}

class _DispatcherDashState extends State<DispatcherDash> {
  final _logger = Logger(printer: PrettyPrinter(), filter: null);

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  var response;
  bool loaded = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getDispatcherData();
  }

  getDispatcherData() async {
    String dispatcherId = await Settings.getDispatcherID();
    _logger.i(dispatcherId);
    var res = await ApiClient().getData('/user/getDispatches/$dispatcherId');
    response = json.decode(res.body);
    _logger.i(response);
    setState(() {
      loaded = true;
    });
  }

  Widget _buildSummaryCard(screenWidth) {
    return GestureDetector(
      onTap: () {
        getDispatcherData();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(screenWidth * 0.04)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 4,
              blurRadius: 4,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Text(
                    response['totalDispatchesDone'].toString(),
                    style: const TextStyle(
                      color: Color(0xFFFF9000),
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: const Text(
                    "  Dispatches",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 90),
                  child: const Text(
                    "You Earned",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  child: Text(
                    "LKR ${response['totalDispatchEarnings']}",
                    style: const TextStyle(
                      color: Color(0xFFFF9000),
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeArea = MediaQuery.of(context).padding.top;
    final themeData = Theme.of(context);

    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldState,
      backgroundColor: themeData.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.appOrange,
        foregroundColor: themeData.textTheme.bodyText1!.color,
        title: const Text('Dispatcher Dashboard'),
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(Constants.screenCornerRadius),
            bottomRight: Radius.circular(Constants.screenCornerRadius),
          ),
        ),
      ),
      body: loaded
          ? Container(
              width: screenWidth,
              height: screenHeight,
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildSummaryCard(screenWidth),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: DispatchCreateScreen()));
                    },
                    child: Container(
                      height: screenHeight * 0.23,
                      width: screenWidth,
                      margin: const EdgeInsets.only(top: 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(screenWidth * 0.04)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 4,
                            blurRadius: 4,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 40, top: 30),
                            child: Image.asset(
                              "assets/images/dispatch_banner_02.png",
                              fit: BoxFit.fill,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10, left: 20),
                            child: const Text(
                              "You can dispatch hires and \nget commissions",
                              style: TextStyle(fontSize: 20, color: Colors.black54, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                            ),
                          ),
                          Container(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.chevron_right,
                                size: screenWidth * 0.15,
                                color: Colors.black45,
                              ))
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: DispatcherHistoryScreen()));
                    },
                    child: Container(
                      height: screenHeight * 0.23,
                      width: screenWidth,
                      margin: const EdgeInsets.only(top: 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(screenWidth * 0.04)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 4,
                            blurRadius: 4,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 40, top: 30),
                            child: Image.asset(
                              "assets/images/dispatch_history.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10, left: 20),
                            child: const Text(
                              "View Dispatch History",
                              style: TextStyle(fontSize: 20, color: Colors.black54, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                            ),
                          ),
                          Container(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.chevron_right,
                                size: screenWidth * 0.15,
                                color: Colors.black45,
                              ))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : loadingDialog(context),
    );
  }
}
