import 'dart:io';

// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart'; // import 'package:flutter_cab/TestLocationSearch/sl_locations_page.dart';
import 'package:taxi_me_passenger_app_v1/views/splash.dart';

import 'views/login.dart';

class MyHttpOverrides extends HttpOverrides {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  /*AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'DriverOnTheWay',
          channelName: "Driver Is On His Way To You",
          channelDescription: "Please Wait for the driver to arrive",
          defaultColor: const Color(0XFF9050DD),
          playSound: true,
        ),
        NotificationChannel(
          channelKey: 'DriverArrived',
          channelName: "Driver Is Arrived To You",
          channelDescription: "Driver Is Arrived To You",
          defaultColor: const Color(0XFF9050DD),
          playSound: true,
        ),
        NotificationChannel(
          channelKey: 'TripOnGoing',
          channelName: "Trip is On Going. Safe Ride and Enjoy Your Ride",
          channelDescription: "Trip is On Going. Safe Ride and Enjoy Your Ride",
          defaultColor: const Color(0XFF9050DD),
          playSound: true,
        ),
        NotificationChannel(
          channelKey: 'TripComplete',
          channelName: "Trip Complete",
          channelDescription: "Your Trip Completed. Come Again",
          defaultColor: const Color(0XFF9050DD),
          playSound: true,
        ),
        NotificationChannel(
          channelKey: 'TripCancelled',
          channelName: "Trip Is Cancelled",
          channelDescription: "Trip Is Cancelled",
          defaultColor: const Color(0XFF9050DD),
          playSound: true,
        )
      ],
      debug: true);*/

  // socket.on('event', (data) => print(data));
  // socket.onDisconnect((_) => print('disconnect'));
  // socket.on('fromServer', (_) => print(_));
  HttpOverrides.global = MyHttpOverrides();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WillPopScope(
      onWillPop: () {
        return Future(() => true);
      },
      child: Splash(),
      /*onWillPop: () {
        print("back Pressed_--------------------------------------------------------------------------------------------");
        return true;
      },*/
    ),
    routes: <String, WidgetBuilder>{
      "/login": (context) => Login(),
    },
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),
      // home: VerifyCode(),
    );
  }
}
