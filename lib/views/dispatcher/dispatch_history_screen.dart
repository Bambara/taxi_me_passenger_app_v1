import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../core/constants/constants.dart';
import '../../utils/api_client.dart';
import '../../utils/color_constant.dart';
import '../../utils/settings.dart';
import '../../widgets/loading_dialog.dart';

class DispatcherHistoryScreen extends StatefulWidget {
  const DispatcherHistoryScreen({super.key});

  @override
  _DispatcherHistoryScreenState createState() => _DispatcherHistoryScreenState();
}

class _DispatcherHistoryScreenState extends State<DispatcherHistoryScreen> {
  final _logger = Logger(printer: PrettyPrinter(), filter: null);

  final _scaffoldState = GlobalKey();
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
    _logger.i('Dispatcher Id : $dispatcherId');

    var res = await ApiClient().getData('/user/getDispatches/$dispatcherId');
    response = json.decode(res.body);
    _logger.i(response);

    setState(() {
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeArea = MediaQuery.of(context).padding.top;
    final themeData = Theme.of(context);

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        backgroundColor: ColorConstant.appOrange,
        foregroundColor: themeData.textTheme.bodyText1!.color,
        title: const Text('Dispatcher History'),
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(Constants.screenCornerRadius),
            bottomRight: Radius.circular(Constants.screenCornerRadius),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: loaded
          ? Container(
              width: screenWidth,
              height: screenHeight,
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  dispatcherCard(screenWidth),
                  SizedBox(height: screenHeight * 0.02),
                  dispatcherCard(screenWidth),
                  SizedBox(height: screenHeight * 0.02),
                  dispatcherCard(screenWidth),
                ],
              ),
            )
          : loadingDialog(context),
    );
  }

  dispatcherCard(screenWidth) {
    return GestureDetector(
      onTap: () {
        getDispatcherData();
      },
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.02),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                    "LKR " + response['totalDispatchEarnings'].toString(),
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
}
