import 'dart:convert';

// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../utils/api_client.dart';
import '../utils/settings.dart';
import '../views/dispatcher/dispatch_dashboard_screen.dart';
import '../views/home/trip_screen.dart';
import '../views/pickup_both_locations.dart';
import '../views/styles.dart';
import '../widgets/Navigation/navDrawer.dart';
import 'user_dashboard_styles.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  _UserDashboardPageState createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final _logger = Logger(printer: PrettyPrinter(), filter: null);

  late LatLng pickupPlace;
  late String passengerID;
  late String passengerAddress;
  late String passengerLatitude;
  late String passengerLongitude;
  late String passengerCurrentStatus;
  late String passengerSocketID;
  bool passengerConnected = true;
  bool checkOnTrip = false;
  var tripAcceptDetails;

  late io.Socket socket;

  displaySharedData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userId = localStorage.getString('userId')!;
    String email = localStorage.getString('email')!;
    String passengerCode = localStorage.getString('passengerCode')!;
    String userProfilePic = localStorage.getString('userProfilePic')!;
    String token = localStorage.getString('token')!;
    if (kDebugMode) {
      print(' ----------------------------- USER SAVED: User Dashboard Page ----------------------------- ');
      print('userId: $userId');
      print('email: $email');
      print('passengerCode: $passengerCode');
      print('userProfilePic: $userProfilePic');
      print('token: $token');
    }
  }

  void _getUserLocation() async {
    // _logger.i("Clicked");
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return Future.error('Location permissions are denied (actual value: $permission).');
      }
    }

    await Geolocator.getCurrentPosition(forceAndroidLocationManager: true, desiredAccuracy: LocationAccuracy.high).then((position) {
      // List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      // Placemark place1 = placemarks[0];
      // Placemark place2 = placemarks[1];
      _logger.i("Clicked");
      setState(() {
        pickupPlace = LatLng(position.latitude, position.longitude);
        _logger.i("Position : $pickupPlace");
      });

      getAddressFromLatLong(position);
    }).catchError((error) {
      _logger.e(error);
    }).onError((error, stackTrace) {
      _logger.e(error);
    });
  }

  Future<void> getAddressFromLatLong(Position position) async {
    await placemarkFromCoordinates(position.latitude, position.longitude).then((placeMarks) {
      /*_logger.i(placeMarks.length);
      _logger.i(placeMarks[0]);
      _logger.i(placeMarks[1]);
      _logger.i(placeMarks[2]);
      _logger.i(placeMarks[3]);
      _logger.i(placeMarks[4]);*/

      final place = placeMarks[0];
      passengerAddress = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      _logger.i("Pickup Place Address : $passengerAddress");
      getConnectPassengerDetails();
    });
  }

  void getConnectPassengerDetails() async {
    // String url = "http://192.168.8.100:8101";
    // _logger.i('Conneting');
    socket = io.io(ApiClient().barUrl + ApiClient().passengerSocket, <String, dynamic>{
      'transports': ["websocket"],
      'autoConnect': true,
    });
    socket.connect();
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userId = localStorage.getString('userId')!;
    passengerID = userId;
    passengerLatitude = pickupPlace.latitude.toString();
    passengerLongitude = pickupPlace.longitude.toString();
    passengerCurrentStatus = "default";
    passengerSocketID = socket.id.toString();

    socket.onConnect((data) => () {
          if (kDebugMode) {
            print("Socket Connected${socket.id!}");
          }
        });
    socket.onConnect((_) {
      var emitData = {
        'passengerId': passengerID.toString(),
        'address': passengerAddress.toString(),
        'latitude': passengerLatitude.toString(),
        'longitude': passengerLongitude.toString(),
        'currentStatus': passengerCurrentStatus.toString(),
        'socketId': socket.id
      };

      if (mounted) {
        socket.emit('passengerConnected', emitData);
        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => PickupBothLocationsUser()));
      }
    });

    setState(() {
/*      socket.onConnect((data) => () {
            print("Socket Connected" + socket.id);
          });
      socket.onConnect((_) {
        var emitData = {
          'passengerId': passengerID.toString(),
          'address': passengerAddress.toString(),
          'latitude': passengerLatitude.toString(),
          'longitude': passengerLongitude.toString(),
          'currentStatus': passengerCurrentStatus.toString(),
          'socketId': socket.id
        };

        if (this.mounted) {
          socket.emit('passengerConnected', emitData);
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => PickupBothLocationsUser()));
        }
      })*/
    });

    checkOngoing();
  }

  _drawerMenu() {
    if (passengerConnected) {
      // _getUserLocation();
      passengerConnected = false;
    }
    return NavDrawer();
  }

  _quickStartButton(String imageName, String typeName) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          height: size.height * 0.09,
          width: size.width * 0.22,
          decoration: BoxDecoration(
            border: Border.all(
              color: UserDashBoardStyles.quickStartBackground,
              style: BorderStyle.solid,
              width: 1.0,
            ),
            color: UserDashBoardStyles.quickStartBackground,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(imageName),
          ),
        ),
        SizedBox(
          height: size.height * 0.006,
        ),
        Text(
          typeName,
          style: UserDashBoardStyles().textCaption(),
        ),
      ],
    );
  }

  String _greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Hello Good Morning!';
    } else if (hour < 17) {
      return 'Hello Good Afternoon!';
    } else {
      return 'Hello Good Evening!';
    }
  }

  @override
  void initState() {
    super.initState();
    displaySharedData();
    _getUserLocation();
  }

  checkOngoing() async {
    checkOnTrip = await Settings.getOnTrip() ?? false;
    String token = await Settings.getToken();
    String id = await Settings.getTripId(); //6217574dd7f16ce182d78a81
    if (id != "") {
      _logger.i("Trip Id :$id");
      // _logger.i("Trip Id :" + id.toString());
      var data = {"tripId": id};

      _setHeaders() => {
            'Content-type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'Connection': 'keep-alive',
          };

      await http
          .post(Uri.parse('${ApiClient().barUrl}${ApiClient().baseSocket}/trip/gettripdetailsbyid'), //new url
              body: jsonEncode(data),
              headers: _setHeaders())
          .then((response) {
        var result = jsonDecode(response.body);

        _logger.i(result);

        var driverDetailsData = {
          "tripId": result['tripData']['_id'],
          "driverId": result['tripData']['noifiedDrivers'][0]['_id'],
          "driverName": result['tripData']['noifiedDrivers'][0]['driverInfo']['driverName'],
          "driverContactNo": result['tripData']['noifiedDrivers'][0]['driverInfo']['driverContactNumber'],
          "driverPic": "http://192.168.8.2:8095/images/drivers/85935644018183060", //fix
          "vehicleId": result['tripData']['noifiedDrivers'][0]['vehicleId'],
          "vehicleRegistrationNo": result['tripData']['noifiedDrivers'][0]['vehicleInfo']['vehicleRegistrationNo'],
          "vehicleBrand": "null", //fix
          "vehicleModel": "null", //fix
          "vehicleColor": "null", //fix
          "longitude": result['tripData']['noifiedDrivers'][0]['currentLocation']['longitude'].toString(),
          "latitude": result['tripData']['noifiedDrivers'][0]['currentLocation']['latitude'].toString()
        };

        var passengerPickupData = {
          "address": result['tripData']['pickupLocation']['address'],
          "longitude": result['tripData']['pickupLocation']['longitude'],
          "latitude": result['tripData']['pickupLocation']['latitude']
        };

        var passengerDropData = [
          {
            "address": result['tripData']['dropLocations'][0]['address'],
            "longitude": result['tripData']['dropLocations'][0]['longitude'],
            "latitude": result['tripData']['dropLocations'][0]['latitude']
          }
        ];

        // checkOnTrip = true;
        if (checkOnTrip) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TripScreen(
                driverDetailsData: driverDetailsData,
                passengerDropData: passengerDropData,
                passengerPickupData: passengerPickupData,
              ),
            ),
          );
        }
      });
    }
  }

  void _enableDispatcher() async {
    try {
      final data = {
        'dispatcherId': await Settings.getUserID(),
        "dispatcherType": "User",
        'dispatchPackageType': 'commission',
        'dispatcherCommission': 8,
        'dispatchAdminCommission': 2,
        "fromDate": "2023-02-28T00:00:00.000+00:00",
        "toDate": "2023-12-26T00:00:00.000+00:00",
      };

      final res = await ApiClient().postData(data, '/dispatcher/create_user_dispatcher');
      final response = jsonDecode(res.body);
      _logger.i(response);
    } catch (e) {
      _logger.e(e);
    }
  }

  dispatcherCheck() async {
    bool checker = await Settings.getDispatcher();

    if (checker) {
      // socket.close();
      return Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => DispatcherDash()),
      );
    } else {
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          Size size = MediaQuery.of(context).size;
          return Dialog(
            elevation: 0.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: size.height * 0.19,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26, width: 2),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.01),
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      'Do you want enable dispatcher access ?',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontSize: 18.0,
                        height: 1.3,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  /*Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'Call : 011-1111111',
                      style: TextStyle(
                        color: Color(0xFFFF9000),
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        height: 1.3,
                      ),
                    ),
                  ),*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: size.width * 0.3,
                        height: size.height * 0.08,
                        child: GestureDetector(
                          onTap: () {
                            _enableDispatcher();
                            Navigator.pop(context);
                          },
                          child: Container(
                              margin: const EdgeInsets.only(top: 30),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFFF9000).withOpacity(0.5), width: 2),
                                borderRadius: const BorderRadius.all(Radius.circular(20)),
                                color: Colors.white,
                              ),
                              child: Text("Yes", style: greyNormalTextStyle)),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.3,
                        height: size.height * 0.08,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              margin: const EdgeInsets.only(top: 30),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFFF9000).withOpacity(0.5), width: 2),
                                borderRadius: const BorderRadius.all(Radius.circular(20)),
                                color: Colors.white,
                              ),
                              child: Text("No", style: greyNormalTextStyle)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: UserDashBoardStyles.PrimaryColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: UserDashBoardStyles.PrimaryColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: UserDashBoardStyles.fontColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_rounded),
            onPressed: () {
              _logger.i('Clicked');
            },
          ),
          /*IconButton(
            icon: Icon(Icons.settings_rounded),
            onPressed: () {},
          )*/
        ],
      ),
      drawer: _drawerMenu(),
      body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage("assets/images/user_dashboard/bg.png"),
            )),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: GestureDetector(
                      onTap: () {
                        checkOngoing();
                      },
                      child: Text(
                        _greeting(),
                        style: UserDashBoardStyles().textHeading1(),
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/images/user_dashboard/quick_start_bg_image.png',
                    fit: BoxFit.contain,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "Quick Start",
                      style: UserDashBoardStyles().textSubHeading1(),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // if (socket != null) {
                          //   socket.close();
                          // }
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PickupBothLocations()));
                          // getConnectPassengerDetails();
                        },
                        child: _quickStartButton(
                          'assets/icons/user_dashboard/ride_icon.png',
                          'Ride',
                        ),
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //     Navigator.of(context).push(
                      //         MaterialPageRoute(builder: (context) => FoodsPage()));
                      //   },
                      //   child: _quickStartButton(
                      //     'images/user_dashboard/tab_foods.png',
                      //     'Foods',
                      //   ),
                      // ),
                      // GestureDetector(
                      //   onTap: () {
                      //     Navigator.of(context).push(MaterialPageRoute(
                      //         builder: (context) => PackagesPage()));
                      //   },
                      //   child: _quickStartButton(
                      //     'images/user_dashboard/tab_package.png',
                      //     'Package',
                      //   ),
                      // ),
                      GestureDetector(
                        onTap: () {
                          dispatcherCheck();
                        },
                        child: _quickStartButton(
                          'assets/icons/user_dashboard/dispatcher_icon.png',
                          'Book for a Friend',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Lottie.network('https://assets1.lottiefiles.com/packages/lf20_bhebjzpu.json', width: MediaQuery.of(context).size.width),
                ],
              ),
            ),
          )),
    );
  }
}
