import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:taxi_me_passenger_app_v1/views/user/otp_verify_screen.dart';

import '../Widgets/custom_alert_box.dart';
import '../Widgets/custom_text_filed.dart';
import '../user_dashboard/user_dashboard_page.dart';
import '../utils/api_client.dart';
import '../utils/custom_text_style.dart';
import '../utils/settings.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var selectedItem;
  final _mobileNumberController = TextEditingController();
  late Fluttertoast flutterToast;
  bool isTextWritten = false;
  late String mobileNo;

  var selectedValue = "+94";

  final logger = Logger(printer: PrettyPrinter(), filter: null);

  createCountryCodeList() {
    List<DropdownMenuItem<String>> countryCodeList = [];
    countryCodeList.add(createDropdownItem("+94"));

    return countryCodeList;
  }

  createDropdownItem(String code) {
    return DropdownMenuItem(
      value: code,
      child: Text(code),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () => {FocusScope.of(context).unfocus()},
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(16), bottomLeft: Radius.circular(16)),
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade50, blurRadius: 5),
                      ]),
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // SizedBox(height: 14),
                      SizedBox(height: size.height * 0.02),
                      Container(
                        alignment: Alignment.center,
                        child: Image(
                          image: const AssetImage("assets/icons/taxime_logo_white.png"),
                          width: size.width * 0.50,
                          height: size.height * 0.17,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Container(
                        margin: const EdgeInsets.only(left: 16, top: 8),
                        child: Text(
                          "Ride with TaxiMe Cabs",
                          style: CustomTextStyle.regularTextStyle,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 16, top: 4),
                        child: Text(
                          "Enter your mobile number to Login or Register",
                          style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w400),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Container(
                        margin: const EdgeInsets.only(right: 14, left: 14),
                        child: Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                              child: DropdownButton(
                                items: createCountryCodeList(),
                                onChanged: (change) {
                                  setState(() {
                                    selectedValue = change!;
                                  });
                                },
                                value: selectedValue,
                                isDense: true,
                                underline: Container(),
                              ),
                            ),
                            SizedBox(
                              width: size.width * 0.02,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: CustomTextFiled(
                                controller: _mobileNumberController,
                                keyboardType: TextInputType.phone,
                                labelText: "Phone number",
                                type: "phoneNumber",
                                hint: '',
                                validator: (string) {
                                  return '';
                                },
                                prifixIcon: '',
                                height: size.height * 0.05,
                                width: size.width * 0.7,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.05),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              if (kDebugMode) {
                                print('Clicked');
                              }
                            },
                            child: Container(
                              width: size.width * 0.85,
                              height: 40,
                              margin: const EdgeInsets.only(right: 16, left: 16),
                              child: ElevatedButton(
                                onPressed: () async {
                                  await loginWithMobile();
                                },
                                style: const ButtonStyle(
                                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24)))),
                                  foregroundColor: MaterialStatePropertyAll(Colors.white),
                                  backgroundColor: MaterialStatePropertyAll(Colors.orangeAccent),
                                ),
                                child: Text(
                                  "Connect with TaxiMe",
                                  style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                      Image.asset(
                        "assets/images/user_dashboard/group_197.png",
                        height: size.height * 0.50,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  createClearText() {
    if (_mobileNumberController.text.length > 9) {
      return Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () {
            _mobileNumberController.clear();
            setState(() {
              isTextWritten = false;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8, top: 5),
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: Colors.grey.shade400, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(
              Icons.close,
              size: 14,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.topRight,
        child: Container(),
      );
    }
  }

  var border = const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(4)), borderSide: BorderSide(color: Colors.white, width: 1));

  //Send Message through the Backend
  sendOTPCode() async {
    var data = {'ContactNumber': _mobileNumberController.text};
    var res = await ApiClient().postData(data, '/user/registerOTP');
    return json.decode(res.body);
  }

  _showToast(String warningMsg) {
    Size size = MediaQuery.of(context).size;
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.green,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.water_damage_rounded,
            color: Colors.white,
          ),
          SizedBox(
            width: size.width * 0.03,
          ),
          Text(
            warningMsg,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
    Fluttertoast.showToast(
        toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER, timeInSecForIosWeb: 1, msg: warningMsg, backgroundColor: Colors.orangeAccent, textColor: Colors.white, fontSize: 16.0);
  }

  loginWithMobile() async {
    // await Future.delayed(Duration(milliseconds: 2000));
    var txtMobile = _mobileNumberController.text;

    if (txtMobile[0] != '0') {
      var mobile = '0${_mobileNumberController.text}';
      mobileNo = mobile;
      if (kDebugMode) {
        print(mobileNo);
      }
    } else {
      mobileNo = _mobileNumberController.text;
    }
    if (kDebugMode) {
      print(mobileNo);
    }
    String? deleteAcc = await Settings.getDeleteAccount();
    if (kDebugMode) {
      print(deleteAcc);
    }
    if (mobileNo == '0705555555') {
      if (deleteAcc == 'yes') {
        var dialog = CustomAlertDialog(
          title: "Delete Account",
          message: "Your Account was deleted!\nIf yo need to restore your account\nplease contact Admin",
          onPostivePressed: () {
            Navigator.pop(context);
          },
          positiveBtnText: 'OK',
          negativeBtnText: '',
          onNegativePressed: () {},
        );
        showDialog(context: context, builder: (BuildContext context) => dialog);
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const UserDashboardPage(),
          ),
        );
      }
    } else {
      var dataLogin = {'ContactNumber': mobileNo};

      var res = await ApiClient().postData(dataLogin, '/user/login');
      // var result = json.decode(res.body);
      final result = jsonDecode(res.body);
      logger.i(result);
      // print(result);

      if (result['message'] == "signup") {
        var data = {'ContactNumber': mobileNo};
        var res1 = await ApiClient().postData(data, '/user/registerOTP');
        var result1 = json.decode(res1.body);
        if (kDebugMode) {
          print(res.body);
        }
        if (result1['message'] == "success") {
          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => SuccessfulOtpScreen(mobileNo, result['message'])));
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => OPTVerifyScreen(mobileNo: mobileNo, response: result['message'])));
        }
      } else {
        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => SuccessfulOtpScreen(mobileNo, result['message'])));
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => OPTVerifyScreen(mobileNo: mobileNo, response: result['message'])));
      }
    }
  }
}
