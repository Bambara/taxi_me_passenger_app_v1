import 'dart:convert';

import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Widgets/custom_alert_box.dart';
import '../utils/api_client.dart';
import '../utils/custom_text_style.dart';
import 'login.dart';

class RegisterCustomer extends StatefulWidget {
  final String mobileNo;

  const RegisterCustomer(this.mobileNo, {super.key});

  @override
  _RegisterCustomer createState() => _RegisterCustomer();
}

class _RegisterCustomer extends State<RegisterCustomer> {
  bool isTextWritten = false;
  late Fluttertoast flutterToast;
  final _formKey = GlobalKey<FormState>();
  final _mobileNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _userNameController = TextEditingController();
  final _birthDayController = TextEditingController();
  var dob;
  var sex;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _mobileNumberController.text = widget.mobileNo.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final format = DateFormat("MM/dd");
    String dropDownValue = 'Male';
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Card(
          elevation: 4,
          borderOnForeground: true,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(16), bottomLeft: Radius.circular(16))),
          margin: const EdgeInsets.only(left: 0, right: 0, bottom: 4),
          child: Container(
            decoration:
                BoxDecoration(borderRadius: const BorderRadius.only(bottomRight: Radius.circular(16), bottomLeft: Radius.circular(16)), shape: BoxShape.rectangle, color: Colors.white, boxShadow: [
              BoxShadow(color: Colors.grey.shade50, blurRadius: 5),
            ]),
            width: double.infinity,
            padding: const EdgeInsets.only(top: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Container(
                  //   alignment: Alignment.center,
                  //   child: Image(
                  //     image: AssetImage("images/ic_logo.png"),
                  //     width: 80,
                  //     height: 80,
                  //   ),
                  // ),
                  Container(
                    height: size.height * 0.18,
                    color: Colors.white,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Stack(fit: StackFit.loose, children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    width: size.width * 0.28,
                                    height: size.height * 0.13,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: AssetImage("assets/icons/taxime_logo_white.png"),
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                              ],
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 50.0, right: 70.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    var file = await ImagePicker().pickImage(source: ImageSource.gallery);
                                    var res = await uploadImage(file!.path, widget.mobileNo);
                                    setState(() {
                                      // state = res;
                                      print(res);
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      CircleAvatar(
                                        backgroundColor: Colors.red,
                                        radius: 20.0,
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                          ]),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      "Mobile No",
                      style: CustomTextStyle.regularTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.004,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 14, left: 14),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 100,
                          child: Container(
                            decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(4)), border: Border.all(width: 1, color: Colors.grey.shade400)),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                TextFormField(
                                  decoration: InputDecoration(
                                    border: border,
                                    enabledBorder: border,
                                    focusedBorder: border,
                                    contentPadding: const EdgeInsets.only(left: 8, right: 32, top: 6, bottom: 6),
                                    hintText: "Enter your Mobile No",
                                    // hasFloatingPlaceholder: true,
                                    hintStyle: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 12),
                                    labelStyle: CustomTextStyle.regularTextStyle.copyWith(color: Colors.black, fontSize: 12),
                                  ),
                                  controller: _mobileNumberController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (mobile) {
                                    if (mobile!.isEmpty) {
                                      return 'Please Enter Mobile No';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      "Email address",
                      style: CustomTextStyle.regularTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.004,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 14, left: 14),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 100,
                          child: Container(
                            decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(4)), border: Border.all(width: 1, color: Colors.grey.shade400)),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                TextFormField(
                                  decoration: InputDecoration(
                                    border: border,
                                    enabledBorder: border,
                                    focusedBorder: border,
                                    contentPadding: const EdgeInsets.only(left: 8, right: 32, top: 6, bottom: 6),
                                    hintText: "Enter your email address",
                                    // hasFloatingPlaceholder: true,
                                    hintStyle: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 12),
                                    labelStyle: CustomTextStyle.regularTextStyle.copyWith(color: Colors.black, fontSize: 12),
                                  ),
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      "Username",
                      style: CustomTextStyle.regularTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.004,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 14, left: 14),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 100,
                          child: Container(
                            decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(4)), border: Border.all(width: 1, color: Colors.grey.shade400)),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                TextFormField(
                                  decoration: InputDecoration(
                                    border: border,
                                    enabledBorder: border,
                                    focusedBorder: border,
                                    contentPadding: const EdgeInsets.only(left: 8, right: 32, top: 6, bottom: 6),
                                    hintText: "Enter Username",
                                    // hasFloatingPlaceholder: true,
                                    hintStyle: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 12),
                                    labelStyle: CustomTextStyle.regularTextStyle.copyWith(color: Colors.black, fontSize: 12),
                                  ),
                                  controller: _userNameController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (email) {
                                    if (email!.isEmpty) {
                                      return 'Please Enter Username';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      "Gender",
                      style: CustomTextStyle.regularTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.004,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 14, left: 14),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 100,
                          child: Container(
                            decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(4)), border: Border.all(width: 1, color: Colors.grey.shade400)),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.person,
                                    ),
                                    hintText: "Select Gender Type ",
                                    hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                                  ),
                                  value: dropDownValue,
                                  items: ["Male", "Female"]
                                      .map((label) => DropdownMenuItem(
                                            value: label,
                                            child: Text(label),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() => dropDownValue = value!);
                                  },
                                  validator: (sexValue) {
                                    // if (sexValue.isEmpty) {
                                    //   return 'Please enter email';
                                    // }
                                    // else{
                                    if (sexValue == 'Male') {
                                      sex = 'male';
                                    } else {
                                      sex = 'female';
                                    }
                                    // }

                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  // SizedBox(
                  //   height: size.height * 0.02,
                  // ),
                  SizedBox(
                    height: size.height * 0.04,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      "Birthday",
                      style: CustomTextStyle.regularTextStyle,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.004,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 14, left: 14),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 100,
                          child: Container(
                            decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(4)), border: Border.all(width: 1, color: Colors.grey.shade400)),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                DateTimeField(
                                  format: format,
                                  onShowPicker: (context, currentValue) {
                                    return showDatePicker(context: context, firstDate: DateTime(1900), initialDate: currentValue ?? DateTime.now(), lastDate: DateTime(2100));
                                  },
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.date_range,
                                    ),
                                    hintText: "Date of Birth",
                                    hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                                  ),
                                  onChanged: (date) {
                                    if (kDebugMode) {
                                      print(date);
                                    }
                                    var day = date!.day;
                                    var month = date.month;
                                    var datee = '$month/$day';
                                    if (kDebugMode) {
                                      print(datee);
                                    }
                                  },
                                  validator: (dateOfBirthValue) {
                                    var day = dateOfBirthValue!.day;
                                    var month = dateOfBirthValue.month;
                                    var datee = '$month/$day';
                                    dob = datee;

                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          print('Clicked');
                        },
                        child: Container(
                          width: size.width * 0.85,
                          margin: const EdgeInsets.only(right: 16, left: 16, top: 20),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                registerAccount();
                              }
                            },
                            style: const ButtonStyle(
                              shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24)))),
                              backgroundColor: MaterialStatePropertyAll(Colors.orangeAccent),
                              foregroundColor: MaterialStatePropertyAll(Colors.white),
                            ),
                            child: Text(
                              "Connect with TaxiMe",
                              style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      // GestureDetector(
                      //   onTap: (){
                      //     if (_formKey.currentState.validate()) {
                      //       // _register();
                      //     }
                      //     // Navigator.push(context, new MaterialPageRoute(builder: (context)=>VerifyCode()));
                      //   },
                      //   child: Container(
                      //     width: 40,
                      //     margin: EdgeInsets.only(right: 10),
                      //     height: 40,
                      //     decoration: BoxDecoration(
                      //         color: Colors.grey, shape: BoxShape.circle),
                      //     child: Icon(
                      //       Icons.arrow_forward,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<String> uploadImage(filename, url) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('picture', filename));
    var res = await request.send();
    return res.reasonPhrase!;
  }

  registerAccount() async {
    // await Future.delayed(Duration(milliseconds: 2000));
    var data = {
      'ContactNumber': _mobileNumberController.text,
      'email': _emailController.text,
      'UserName ': _userNameController.text,
      'Gender': sex,
      'Birthday': dob,
      'UserPlatform': 'android',
      'userProfilePic': ''
    };
    var res = await ApiClient().postData(data, '/user/signup');
    var result = json.decode(res.body);
    if (kDebugMode) {
      print(result);
    }
    if (result['message'] == "success") {
      SharedPreferences.setMockInitialValues({});

      // await Settings.setUserID(result['user']['_id']);
      // await Settings.setEmail(result['user']['email']);
      // await Settings.setContactNumber(result['user']['contactNumber']);
      // await Settings.setPassengerCode(result['user']['passengerCode']);
      // await Settings.setUserProfilePic(result['user']['userProfilePic']);
      // await Settings.setToken(result['user']['token']);
      // await Settings.setSigned(true);
      // _showToast("Successfully Registered");
      var dialog = CustomAlertDialog(
        title: "Account Creation",
        message: "Your Account was created Successfully!\nplease login to Account",
        onPostivePressed: () {
          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
            (Route<dynamic> route) => false,
          );
        },
        positiveBtnText: 'OK',
        negativeBtnText: '',
        onNegativePressed: () {},
      );
      showDialog(context: context, builder: (BuildContext context) => dialog);
    } else {
      return "The entered OTP is wrong";
    }
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

  var border = const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(4)), borderSide: BorderSide(color: Colors.white, width: 1));
}
