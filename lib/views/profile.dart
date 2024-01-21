import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../Utils/settings.dart';
import '../core/constants/constants.dart';
import '../utils/api_client.dart';
import '../utils/color_constant.dart';
import '../utils/custom_text_style.dart';
import '../utils/dotted_line.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final logger = Logger(printer: PrettyPrinter(), filter: null);

  String _name = '';
  String _email = '';
  String _mobileNumber = '';

  void _getProfileData() async {
    String userID = await Settings.getUserID();
    final data = {'userId': userID};

    final res = await ApiClient().postData(data, '/user/checkInfo');
    final response = jsonDecode(res.body);
    logger.i(response);

    setState(() {
      _name = response['content'][0]['name'];
      _name ??= '';
      _email = response['content'][0]['email'];
      _mobileNumber = response['content'][0]['contactNumber'];
    });

    // String dispatcherID = response['content1'][0]['dispatcher'][0]['dispatcherId'];
  }

  @override
  void initState() {
    super.initState();
    _getProfileData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeArea = MediaQuery.of(context).padding.top;
    final themeData = Theme.of(context);

    return Scaffold(
        backgroundColor: themeData.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: ColorConstant.appOrange,
          foregroundColor: themeData.textTheme.bodyText1!.color,
          title: const Text('Passenger Wallet'),
          centerTitle: true,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(Constants.screenCornerRadius),
              bottomRight: Radius.circular(Constants.screenCornerRadius),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 16, top: 12),
                child: Text(
                  "CONTACT DETAILS",
                  style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.grey),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 16, top: 12),
                child: Text(
                  "Name",
                  style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 16),
                    child: Text(_name, style: CustomTextStyle.mediumTextStyle),
                  ),
                  GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: const Icon(Icons.navigate_next, color: Colors.grey),
                    ),
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 16, top: 12),
                child: Text(
                  "Email",
                  style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 16, top: 4),
                child: Text(_email, style: CustomTextStyle.mediumTextStyle),
              ),
              Container(
                margin: const EdgeInsets.only(left: 16, top: 16),
                child: Text("Mobile Number", style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 16),
                    child: Text(_mobileNumber, style: CustomTextStyle.mediumTextStyle),
                  ),
                  GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: const Icon(
                        Icons.navigate_next,
                        color: Colors.grey,
                      ),
                    ),
                  )
                ],
              ),
              DottedLine(16, 16, 4),
              Container(
                margin: const EdgeInsets.only(left: 16, top: 12),
                child: Text("SECURITY DETAILS", style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.grey)),
              ),
              Container(
                margin: const EdgeInsets.only(left: 16, top: 12),
                child: Text("Password", style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(margin: const EdgeInsets.only(left: 16), child: Text("Change Password", style: CustomTextStyle.mediumTextStyle)),
                  GestureDetector(
                    child: Container(margin: const EdgeInsets.only(right: 8), child: const Icon(Icons.navigate_next, color: Colors.grey)),
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 16, top: 12),
                child: Text("Security Question", style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(margin: const EdgeInsets.only(left: 16), child: Text("Change Security Question", style: CustomTextStyle.mediumTextStyle)),
                  GestureDetector(
                    child: Container(margin: const EdgeInsets.only(right: 8), child: const Icon(Icons.navigate_next, color: Colors.grey)),
                  )
                ],
              ),
              DottedLine(16, 16, 4),
              Container(
                margin: const EdgeInsets.only(left: 16, top: 12),
                child: Text("LANGUAGE", style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.grey)),
              ),
              Container(
                margin: const EdgeInsets.only(left: 16, top: 12),
                child: Text("Select Language", style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(margin: const EdgeInsets.only(left: 16), child: Text("English", style: CustomTextStyle.mediumTextStyle)),
                  GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: const Icon(Icons.navigate_next, color: Colors.grey),
                    ),
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 16, top: 12),
                child: Text("Logout", style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.red)),
              ),
            ],
          ),
        ));
  }
}
