import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../generated/assets.dart';
import '../user_dashboard/user_dashboard_page.dart';
import 'login.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    splashMove();
  }

  displaySharedData(SharedPreferences localStorage) async {
    String userId = localStorage.getString('userId')!;
    String email = localStorage.getString('email')!;
    String passengerCode = localStorage.getString('passengerCode')!;
    String userProfilePic = localStorage.getString('userProfilePic')!;
    String token = localStorage.getString('token')!;

    print(' ----------------------------- SAVED USER ----------------------------- ');
    print('userId: $userId');
    print('email: $email');
    print('passengerCode: $passengerCode');
    print('userProfilePic: $userProfilePic');
    print('token: $token');
  }

  navigatePage() async {
    //SharedPreferences.setMockInitialValues({});
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    displaySharedData(localStorage);
    var User = localStorage.getString('userId');
    print("-------------------------------- USER: $User --------------------------------");
    if (User != null) {
      Navigator.pushAndRemoveUntil(
        context,
        //MaterialPageRoute(bu
        // ilder: (context) => Home()),
        MaterialPageRoute(builder: (context) => /*PickupBothLocationsUser()*/ UserDashboardPage()),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) => Login()));
    }
  }

  splashMove() {
    return Timer(Duration(seconds: 4), navigatePage);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        //resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: true,
        body: Builder(builder: (context) {
          return Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(Assets.userDashboardArtBoard01),
              // image: AssetImage("assets/images/user_dashboard/art_board_01.png"),
            )),
            // child: Column(
            //   //   decoration: BoxDecoration(
            //   //       image: DecorationImage(
            //   //     image: AssetImage("images/taxime_logo_white.png"),
            //   //   )),
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     // Container(
            //     //   height: 300,
            //     //   decoration: BoxDecoration(
            //     //       image: DecorationImage(
            //     //     image: AssetImage("images/taxime_logo_white.png"),
            //     //   )),
            //     // ),
            //     // Text(
            //     //   "Safety and Comfort is Our Concern",
            //     //   style: TextStyle(
            //     //       fontSize: 20,
            //     //       fontFamily: "Roboto",
            //     //       fontWeight: FontWeight.w400),
            //     // )
            //   ],
            // ),
          );
        }),
      ),
    );
  }
}
