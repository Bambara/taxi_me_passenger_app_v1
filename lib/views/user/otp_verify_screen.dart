import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../Utils/settings.dart';
import '../../core/constants/constants.dart';
import '../../user_dashboard/user_dashboard_page.dart';
import '../../utils/api_client.dart';
import '../../utils/color_constant.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/flat_button_widget.dart';
import '../../widgets/text_field_widget.dart';
import '../register_account.dart';

class OPTVerifyScreen extends StatefulWidget {
  final String mobileNo;
  final String response;

  const OPTVerifyScreen({Key? key, required this.mobileNo, required this.response}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OPTVerifyScreenState();
}

class _OPTVerifyScreenState extends State<OPTVerifyScreen> {
  final _logger = Logger(printer: PrettyPrinter(), filter: null);

  final digitOneCtrl = TextEditingController();
  final digitTwoCtrl = TextEditingController();
  final digitThreeCtrl = TextEditingController();
  final digitFourCtrl = TextEditingController();

  Future<String?> _validateOTP(String otp) async {
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
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => RegisterCustomer(widget.mobileNo)), (Route<dynamic> route) => false);
    } else {
      await Settings.setUserID(result['user']['_id']);
      await Settings.setEmail(result['user']['email']);
      await Settings.setContactNumber(result['user']['contactNumber']);
      await Settings.setPassengerCode(result['user']['passengerCode']);
      await Settings.setUserProfilePic(result['user']['userProfilePic']);
      await Settings.setToken(result['token']);
      await Settings.setDispatcher(result['user']['isDispatchEnable']);
      await Settings.setSigned(true);

      _getDispatcherData();
      _displaySharedData();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const UserDashboardPage(),
        ),
      );
    }
    return null;
  }

  void _getDispatcherData() async {
    String userID = await Settings.getUserID();
    var data = {'userId': userID};

    var res = await ApiClient().postData(data, '/user/checkInfo');
    var response = json.decode(res.body);
    String dispatcherID = response['content'][0]['dispatcher'][0]['dispatcherId'];

    await Settings.setDispatcherID(dispatcherID);
  }

  void _displaySharedData() async {
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
    bool isChecked = true;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeArea = MediaQuery.of(context).padding.top;
    final themeData = Theme.of(context);

    return Scaffold(
      backgroundColor: themeData.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: ColorConstant.appOrange,
        foregroundColor: themeData.textTheme.bodyText1!.color,
        title: const Text('OTP Verification'),
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
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.08),
              Row(
                children: [
                  SizedBox(width: screenWidth * 0.05),
                  AvatarWidget(provider: const AssetImage('assets/icons/driver-icon.png'), size: screenWidth * 0.2),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Row(
                children: [
                  SizedBox(width: screenWidth * 0.07),
                  Text('Hello', style: TextStyle(fontSize: screenWidth * 0.08)),
                ],
              ),
              Row(
                children: [
                  SizedBox(width: screenWidth * 0.07),
                  Text('Buddhika', style: TextStyle(fontSize: screenWidth * 0.08)),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Text('Enter the received verification code', style: TextStyle(fontSize: screenWidth * 0.035)),
              SizedBox(height: screenHeight * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFieldWidget(
                      hintText: '', label: '', isRequired: true, txtCtrl: digitOneCtrl, fontSize: 0.08, secret: false, heightFactor: 0.1, widthFactor: 0.15, inputType: TextInputType.number),
                  SizedBox(width: screenWidth * 0.04),
                  TextFieldWidget(
                      hintText: '', label: '', isRequired: true, txtCtrl: digitTwoCtrl, fontSize: 0.08, secret: false, heightFactor: 0.1, widthFactor: 0.15, inputType: TextInputType.number),
                  SizedBox(width: screenWidth * 0.04),
                  TextFieldWidget(
                      hintText: '', label: '', isRequired: true, txtCtrl: digitThreeCtrl, fontSize: 0.08, secret: false, heightFactor: 0.1, widthFactor: 0.15, inputType: TextInputType.number),
                  SizedBox(width: screenWidth * 0.04),
                  TextFieldWidget(
                      hintText: '', label: '', isRequired: true, txtCtrl: digitFourCtrl, fontSize: 0.08, secret: false, heightFactor: 0.1, widthFactor: 0.15, inputType: TextInputType.number),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              RichText(
                  text: TextSpan(
                children: [
                  TextSpan(
                      text: "Resend Code",
                      style: TextStyle(color: themeData.buttonTheme.colorScheme!.secondary, fontSize: screenWidth * Constants.textFontSize),
                      recognizer: TapGestureRecognizer()..onTap = () {}),
                ],
              )),
              SizedBox(height: screenHeight * 0.18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FlatButtonWidget(
                    title: 'Next',
                    function: () {
                      String otp = digitOneCtrl.text + digitTwoCtrl.text + digitThreeCtrl.text + digitFourCtrl.text;
                      _validateOTP(otp);
                    },
                    heightFactor: 0.065,
                    widthFactor: 0.4,
                    bgColor: themeData.buttonTheme.colorScheme!.secondary,
                    textColor: ColorConstant.white,
                  ),
                  SizedBox(width: screenWidth * 0.06),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
