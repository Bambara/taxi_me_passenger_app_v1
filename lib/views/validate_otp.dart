/*
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:otp_screen/otp_screen.dart';

import '../Utils/settings.dart';
import '../user_dashboard/user_dashboard_page.dart';
import '../utils/api_client.dart';
import 'register_account.dart';

class SuccessfulOtpScreen extends StatefulWidget {
  final String mobileNo;
  final String response;

  const SuccessfulOtpScreen(this.mobileNo, this.response, {super.key});

  @override
  _SuccessfulOtpScreen createState() => _SuccessfulOtpScreen();
}

class _SuccessfulOtpScreen extends State<SuccessfulOtpScreen> {
  final _logger = Logger(printer: PrettyPrinter(), filter: null);

  Future<String?> validateOtp(String otp) async {
    var res;

    var data = {'ContactNumber': widget.mobileNo, 'pin': int.parse(otp)};
    if (widget.response == 'signup') {
      res = await ApiClient().postData(data, '/user/validateOTP');
    } else {
      res = await ApiClient().postData(data, '/user/validateLoginOTP');
    }

    var result = jsonDecode(res.body);
    _logger.i(result);
    // print(result);
    if (result['message'] == "loggedin") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => RegisterCustomer(widget.mobileNo)),
        (Route<dynamic> route) => false,
      );
    } else {
      await Settings.setUserID(result['user']['_id']);
      await Settings.setEmail(result['user']['email']);
      await Settings.setContactNumber(result['user']['contactNumber']);
      await Settings.setPassengerCode(result['user']['passengerCode']);
      await Settings.setUserProfilePic(result['user']['userProfilePic']);
      await Settings.setToken(result['token']);
      await Settings.setDispatcher(result['user']['isDispatchEnable']);
      await Settings.setSigned(true);

      getDispatcherData();
      displaySharedData();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const UserDashboardPage(),
        ),
      );
    }
    return null;
  }

  getDispatcherData() async {
    String userID = await Settings.getUserID();
    var data = {'userId': userID};

    var res = await ApiClient().postData(data, '/user/checkInfo');
    var response = json.decode(res.body);
    String dispatcherID = response['content'][0]['dispatcher'][0]['dispatcherId'];

    await Settings.setDispatcherID(dispatcherID);
  }

  displaySharedData() async {
    String userId = await Settings.getUserID();
    String email = await Settings.getEmail();
    String number = await Settings.getContactNumber();
    String passengerCode = await Settings.getPassengerCode();
    String userProfilePic = await Settings.getUserProfilePic();
    String token = await Settings.getToken();
    bool dispatcher = await Settings.getDispatcher();
    _logger.i(' --------------- USER SAVED: Validate OTP -------------- ');
    _logger.i('userId: $userId');
    _logger.i('email: $email');
    _logger.i('passengerCode: $passengerCode');
    _logger.i('userProfilePic: $userProfilePic');
    _logger.i('token: $token');
    _logger.i('number: $number');
    _logger.i('dispatcher: $dispatcher');
    _logger.i(' ----------------------------------- ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OtpScreen.withGradientBackground(
        topColor: Colors.white,
        bottomColor: Colors.white,
        otpLength: 4,
        validateOtp: validateOtp,
        // routeCallback: moveToNextScreen,
        themeColor: Colors.black45,
        titleColor: Colors.black45,
        title: "Phone Number Verification",
        subTitle: "Enter the code sent to \n ${widget.mobileNo}",
        icon: Image.asset(
          'assets/icons/ic_phone.png',
          fit: BoxFit.fill,
        ),
        routeCallback: (BuildContext context) {},
      ),
    );
  }
}
*/
