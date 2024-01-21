import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../Widgets/custom_button_widgets.dart';
import '../models/favorite_place.dart';
import '../user_dashboard/user_dashboard_page.dart';
import '../user_dashboard/user_dashboard_styles.dart';
import '../utils/api_client.dart';
import '../utils/custom_text_style.dart';
import 'home/book_cab.dart';

class PickupBothLocations extends StatefulWidget {
  const PickupBothLocations({super.key});

  @override
  _PickupUserState createState() => _PickupUserState();
}

class _PickupUserState extends State<PickupBothLocations> with SingleTickerProviderStateMixin {
  final _logger = Logger(printer: PrettyPrinter(), filter: null);

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  var selectedItem;
  final TextEditingController _pickupLocationCtrl = TextEditingController();
  final TextEditingController _dropLocationCtrl = TextEditingController();
  List<FavoritePlace> listFavoritePlace = [];
  bool isTextWritten = true;
  late Position _currentPosition;
  late String _currentAddress;
  late LatLng pickupPlace;
  late LatLng dropPlace;
  String passengerCode = 'passengerCode';
  late Fluttertoast flutterToast;

  late Socket socket;

  late String passengerID;
  late String passengerAddress;
  late String passengerLatitude;
  late String passengerLongitude;
  late String passengerCurrentStatus;
  late String passengerSocketID;

  late AnimationController _controller;
  late Animation _animation;

  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween(begin: 300.0, end: 50.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    _getUserLocation();
    //getConnectPassengerDetails();
    // _pickupLocationCtrl.text=widget.pickupPlace.display_name.toString();
    createFavoritePlaceList();

    flutterToast = Fluttertoast();
  }

  void _getConnectPassengerDetails() async {
/*    Socket socket = io(
        'http://192.168.8.100:8101',
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .build());
    socket.connect();*/

    // String url = "http://192.168.8.100:8101";
    socket = io(ApiClient().barUrl + ApiClient().passengerSocket, OptionBuilder().disableAutoConnect().setTransports(['websocket']).build());
    // socket = io(ApiClient().barUrl + ApiClient().passengerSocket);
    // socket.onConnect((_) {
    //   _logger.i(socket.id);
    //   socket.emit('msg', 'test');
    // });
    // socket.connect();
    socket.onConnect((_) {
      if (kDebugMode) {
        print('Connection established');
      }
    });
    _logger.i(socket.connected);

    // socket.on('connect', (_) {});

    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userId = localStorage.getString('userId')!;
    passengerID = userId;
    passengerAddress = _pickupLocationCtrl.text;
    passengerLatitude = pickupPlace.latitude.toString();
    passengerLongitude = pickupPlace.longitude.toString();
    passengerCurrentStatus = "default";
    passengerSocketID = socket.id.toString();
    //var  passengerConnectModel newPassenger;
    //  var  newPassenger = new passengerConnectModel(passengerID,passengerAddress,passengerLatitude,passengerLongitude,passengerCurrentStatus,passengerSocketID);

    final emitData = {
      'passengerId': passengerID.toString(),
      'address': passengerAddress.toString(),
      'latitude': passengerLatitude.toString(),
      'longitude': passengerLongitude.toString(),
      'currentStatus': passengerCurrentStatus.toString(),
      'socketId': passengerSocketID
    };

    // socket.onConnect((_) {
    //   _logger.i('connect');
    //   if (this.mounted) {
    //     socket.emit('submitLocation', emitData);
    //   }
    // });

    if (socket.connected) {
      // socket.emit('getOnlineDriversBylocation', data);
      socket.emit('submitLocation', emitData);
    }
    //
    socket.on('submitLocationResult', (data) {
      _logger.i('submitLocationResult');
      if (mounted) {
        final validMap = json.decode(json.encode(data)) as Map<String, dynamic>;
        _logger.i(validMap);

        printRideDetails();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => BookCab(passengerCode = "passengerCode", isTextWritten, _pickupLocationCtrl.text, pickupPlace, _dropLocationCtrl.text, dropPlace)),
            (Route<dynamic> route) => false);
      }
    });

    // _logger.i('Emit Data : ' + emitData.toString());
  }

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

  Future<String> getPassengerDetails() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userId = localStorage.getString('userId')!;
    String email = localStorage.getString('email')!;
    String passengerCode = localStorage.getString('passengerCode')!;
    String userProfilePic = localStorage.getString('userProfilePic')!;
    String token = localStorage.getString('token')!;
    return localStorage.getString('passengerCode')!;
  }

  createFavoritePlaceList() {
    listFavoritePlace.add(createFavorite("GIT - Office", "No.29 Dalugama, Kelaniya"));
    listFavoritePlace.add(createFavorite("Katunayake Airport", "No.65 Walukarama Rd, Colombo"));
    return listFavoritePlace;
  }

  createFavorite(String title, String subtitle) {
    return FavoritePlace(title, subtitle);
  }

  void _getUserLocation() async {
    // Placemark place1;
    // Placemark place2;

    // bool serviceEnabled;
    // LocationPermission permission;

    await Geolocator.isLocationServiceEnabled().then((serviceEnabled) async {
      if (!serviceEnabled) {
        _logger.w('Location services are disabled.');
      } else {
        _logger.i("serviceEnabled");
        await Geolocator.checkPermission().then((permission) async {
          if (permission == LocationPermission.deniedForever) {
            _logger.w('Location permissions are permantly denied, we cannot request permissions.');
          } else {
            _logger.i("permission");
            if (permission == LocationPermission.denied) {
              await Geolocator.requestPermission().then((permission) async {
                if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
                  _logger.w('Location permissions are denied (actual value: $permission).');
                } else {
                  _logger.i("permission 2");
                }
              });
            } else {
              await Geolocator.getCurrentPosition(forceAndroidLocationManager: true, desiredAccuracy: LocationAccuracy.high).then((position) async {
                // _logger.i("Current Position  : " + position.latitude.toString());
                await placemarkFromCoordinates(position.latitude, position.longitude).then((placeMarks) async {
                  _logger.i("Current PLace Mark  : ${placeMarks[0]}");

                  // final coordinates = new Coordinates(position.latitude, position.longitude);

                  await Geocoder2.getDataFromCoordinates(
                    latitude: position.latitude,
                    longitude: position.longitude,
                    googleMapApiKey: "AIzaSyCtg102uMuplrssv_sk_FD-IcKI5hxnnSw",
                  ).then((addresses) {
                    _logger.i("Pickup Address  : $addresses");

                    // if (Platform.isAndroid) {
                    //    place1 = placeMarks[0];
                    //    place2 = placeMarks[1];
                    // } else if (Platform.isIOS) {
                    //   place1 = placeMarks[0];
                    //   place2 = placeMarks[1];
                    // }

                    setState(() {
                      pickupPlace = LatLng(position.latitude, position.longitude);
                      _pickupLocationCtrl.text = "${addresses.streetNumber}, ${addresses.address},";
                      // currentPostion = LatLng(position.latitude, position.longitude);
                      //print(placeMarks.toString());
                      _logger.i("Pickup Place: ${_pickupLocationCtrl.text}");
                      _logger.i("Pickup Place Latitude: ${pickupPlace.latitude}");
                      _logger.i("Pickup Place Longitude: ${pickupPlace.longitude}");
                    });
                  }).onError((error, stackTrace) {
                    _logger.e(error.toString());
                  });
                }).onError((error, stackTrace) {
                  _logger.e(error.toString());
                });
              }).onError((error, stackTrace) {
                _logger.e(error.toString());
              });
            }
          }
        });
      }
    });
  }

  _headView() {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: UserDashBoardStyles.fontColor,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => UserDashboardPage()), (Route<dynamic> route) => false);
                    },
                  ),
                  Center(
                    child: Text(
                      "Select Your Route",
                      style: UserDashBoardStyles().textHeading1(),
                    ),
                  ),
                ],
              ),
              Image.asset(
                'assets/icons/user_dashboard/taxime_logo.png',
                height: size.height * 0.09,
                width: size.width * 0.2,
              ),
            ],
          ),
          Image.asset(
            'assets/images/user_dashboard/group_197.png',
            width: size.width * 0.95,
            height: size.height * 0.2,
          ),
        ],
      ),
    );
  }

  _searchBoxesView() {
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 5.0),
          child: Text(
            "Pickup Location",
            style: UserDashBoardStyles().textSubHeading2(),
          ),
        ),
        Container(
          height: size.height * 0.06,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: GooglePlaceAutoCompleteTextField(
              textEditingController: _pickupLocationCtrl,
              googleAPIKey: "AIzaSyCtg102uMuplrssv_sk_FD-IcKI5hxnnSw",
              inputDecoration: InputDecoration(
                hintText: 'Enter Pickup Location',
                contentPadding: const EdgeInsets.only(left: 10.0),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: UserDashBoardStyles.fontColor,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.cancel_rounded,
                    color: UserDashBoardStyles.fontColor,
                  ),
                  onPressed: () => createClearTextPickup(),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: UserDashBoardStyles.fontColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: UserDashBoardStyles.fontColor,
                  ),
                ),
              ),
              countries: const ["LK"],
              debounceTime: 800,
              // optional by default null is set
              isLatLngRequired: true,
              // if you required coordinates from place detail
              getPlaceDetailWithLatLng: (Prediction prediction) {
                // this method will return latlng with place detail
                print("placeDetails${prediction.lng}");

                setState(() {
                  pickupPlace = LatLng(double.parse(prediction.lat!), double.parse(prediction.lng!));
                });
              },
              // this callback is called when isLatLngRequired is true
              itmClick: (Prediction prediction) {
                print(prediction.lat);
                // pickupPlace=LatLng(double.parse(prediction.lat), double.parse(prediction.lng));
                _pickupLocationCtrl.text = prediction.description!;
                _pickupLocationCtrl.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description!.length));
              }),
        ),
        SizedBox(height: size.height * 0.01),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 5.0),
          child: Text(
            "Drop Off Location",
            style: UserDashBoardStyles().textSubHeading2(),
          ),
        ),
        Container(
          height: size.height * 0.06,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: GooglePlaceAutoCompleteTextField(
              textEditingController: _dropLocationCtrl,
              googleAPIKey: "AIzaSyCtg102uMuplrssv_sk_FD-IcKI5hxnnSw",
              inputDecoration: InputDecoration(
                hintText: 'Enter Drop Off Location',
                contentPadding: const EdgeInsets.only(left: 10.0),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: UserDashBoardStyles.fontColor,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.cancel_rounded,
                    color: UserDashBoardStyles.fontColor,
                  ),
                  onPressed: () => createClearTextDrop(),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: UserDashBoardStyles.fontColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: UserDashBoardStyles.fontColor,
                  ),
                ),
              ),
              debounceTime: 800,
              countries: const ["LK"],
              // optional by default null is set
              isLatLngRequired: true,

              // if you required coordinates from place detail
              getPlaceDetailWithLatLng: (Prediction prediction) {
                // this method will return latlng with place detail
                // print("placeDetails" + prediction.lng.toString() + ',' + prediction.lat.toString());

                setState(() {
                  try {
                    dropPlace = LatLng(double.parse(prediction.lat!), double.parse(prediction.lng!));
                    _logger.i("Drop Place : $dropPlace");
                  } catch (e) {
                    _logger.e(e);
                  }
                });
              },
              // this callback is called when isLatLngRequired is true
              itmClick: (Prediction prediction) {
                setState(() {
                  try {
                    dropPlace = LatLng(double.parse(prediction.lat!), double.parse(prediction.lng!));
                  } catch (e) {
                    _logger.e(e);
                  }
                });
                _dropLocationCtrl.text = prediction.description!;
                _dropLocationCtrl.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description!.length));
              }),
        ),
      ],
    );
  }

  printRideDetails() async {
    final rideDetails = {
      "Passenger Code": passengerCode = await getPassengerDetails(),
      "Is Text Written": isTextWritten,
      "Pickup Place Address": _pickupLocationCtrl.text,
      "Pickup Place Latitude": pickupPlace.latitude,
      "Pickup Place Longitude": pickupPlace.longitude,
      "Drop Place Address": _dropLocationCtrl.text,
      "Drop Place Latitude": dropPlace.latitude,
      "Drop Place Longitude": dropPlace.longitude
    };

    _logger.i("Ride Details : $rideDetails");

    // print("width = ${MediaQuery.of(context).size.width}\n height = ${MediaQuery.of(context).size.height}");
  }

  validateRideDetails() {
    if (_dropLocationCtrl.text.isEmpty && _pickupLocationCtrl.text.isEmpty) {
      if (kDebugMode) {
        print("Please select Pickup & Drop Location");
      }
      _showWarningToast("Please select Pickup & Drop Location");
    } else if (_pickupLocationCtrl.text.isEmpty) {
      if (kDebugMode) {
        print("Please select Pickup Location");
      }
      _showWarningToast("Please select Pickup Location");
    } else if (_dropLocationCtrl.text.isEmpty) {
      if (kDebugMode) {
        print("Please select Drop Location");
      }
      _showWarningToast("Please select Drop Location");
    } else {
      _getConnectPassengerDetails();
    }
  }

  _showWarningToast(String warningMsg) {
    Size size = MediaQuery.of(context).size;
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_rounded,
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

  _continueToRideView() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: CustomButtonWidget(
        color: UserDashBoardStyles.fontColor,
        text: 'Select Ride',
        textColor: UserDashBoardStyles.fontWhiteColor,
        onClicked: () {
          try {
            if (dropPlace.latitude != null) {
              validateRideDetails();
            }
          } catch (e) {
            _logger.e(e);
          }

          //getConnectPassengerDetails();
        },
      ),
    );
  }

  _favouriteLocationsView() {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/icons/user_dashboard/favourite_places.png',
                  height: size.height * 0.03,
                  width: size.width * 0.07,
                ),
                SizedBox(
                  width: size.width * 0.03,
                ),
                Text(
                  "Favorite Places",
                  style: CustomTextStyle.mediumTextStyle.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          ListView.builder(
            itemBuilder: (context, position) {
              return createFavoriteListItem(listFavoritePlace[position], context);
            },
            itemCount: listFavoritePlace.length,
            shrinkWrap: true,
            primary: false,
          ),
        ],
      ),
    );
  }

  _recentLocationsView() {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              children: [
                Image.asset(
                  'assets/icons/user_dashboard/recent_places.png',
                  height: size.height * 0.03,
                  width: size.width * 0.07,
                ),
                SizedBox(
                  width: size.width * 0.03,
                ),
                Text(
                  "Recently Visited Places",
                  style: CustomTextStyle.mediumTextStyle.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          ListView.builder(
            itemBuilder: (context, position) {
              return createRecentlyPlaceListItem(listFavoritePlace[position]);
            },
            itemCount: listFavoritePlace.length,
            shrinkWrap: true,
            primary: false,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldState,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        reverse: true,
        child: Stack(
          children: [
            InkWell(
              // to dismiss the keyboard when the user tabs out of the TextField
              splashColor: Colors.transparent,
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Column(
                children: [
                  _headView(),
                  _searchBoxesView(),
                  _continueToRideView(),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  _favouriteLocationsView(),
                  _recentLocationsView(),
                  Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom * 0.4),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
    // return  Scaffold(
    //     key: _scaffoldState,
    //   resizeToAvoidBottomInset : false,
    //     backgroundColor: Colors.white,
    //     body: SingleChildScrollView(
    //         // reverse: true,
    //       child:
    //
    //     ),
    // );
  }

  createClearTextPickup() {
/*    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: () {
          _pickupLocationCtrl.clear();
          setState(() {
            isTextWritten = false;
          });
        },
        child: Container(
          margin: EdgeInsets.only(right: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
              color: Colors.grey.shade400, shape: BoxShape.circle),
          child: Icon(
            Icons.close,
            size: 14,
            color: Colors.white,
          ),
          alignment: Alignment.center,
        ),
      ),
    );*/

    _pickupLocationCtrl.clear();
    setState(() {
      isTextWritten = false;
    });
  }

  createClearTextDrop() {
    /*return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: () {
          _dropLocationCtrl.clear();
          setState(() {
            isTextWritten = false;
          });
        },
        child: Container(
          margin: EdgeInsets.only(right: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
              color: Colors.grey.shade400, shape: BoxShape.circle),
          child: Icon(
            Icons.close,
            size: 14,
            color: Colors.white,
          ),
          alignment: Alignment.center,
        ),
      ),
    );*/

    _dropLocationCtrl.clear();
    setState(() {
      isTextWritten = false;
    });
  }

  createFavoriteListItem(FavoritePlace listFavoritePlace, BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: size.width * 0.02,
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.location_on_rounded,
              size: 20,
              color: UserDashBoardStyles.iconLiteColor,
            ),
          ),
          SizedBox(
            width: size.width * 0.02,
          ),
          Expanded(
            flex: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: size.height * 0.005,
                ),
                Text(
                  listFavoritePlace.title,
                  style: UserDashBoardStyles().textBody2(),
                ),
                SizedBox(
                  height: size.height * 0.005,
                ),
                Text(
                  listFavoritePlace.subtitle,
                  style: UserDashBoardStyles().textCustomCaption(UserDashBoardStyles.iconLiteColor),
                )
              ],
            ),
          ),
          GestureDetector(
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              child: Icon(
                Icons.remove_circle_outline,
                color: UserDashBoardStyles.redColor,
              ),
            ),
            onTap: () {
              showDeleteBottomSheet(context);
            },
          ),
        ],
      ),
    );
  }

  createRecentlyPlaceListItem(FavoritePlace listFavoritePlace) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: size.width * 0.02,
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.location_on_rounded,
              size: 20,
              color: UserDashBoardStyles.iconLiteColor,
            ),
          ),
          SizedBox(
            width: size.width * 0.02,
          ),
          Text(
            listFavoritePlace.subtitle,
            style: UserDashBoardStyles().textBody2(),
          )
        ],
      ),
    );
  }

  void showDeleteBottomSheet(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext mCtx) {
          return Container(
            height: size.height * 0.15,
            decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: size.height * 0.02,
                ),
                Text(
                  "Delete Favorite",
                  style: CustomTextStyle.mediumTextStyle,
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Text(
                  "Are you sure you want to delete?",
                  style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    SizedBox(
                      width: size.width * 0.02,
                    ),
                    Expanded(
                      flex: 50,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: const ButtonStyle(
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100)), side: BorderSide(color: Colors.grey, width: 1))),
                          backgroundColor: MaterialStatePropertyAll(Colors.white),
                        ),
                        child: Text(
                          "Yes",
                          style: CustomTextStyle.mediumTextStyle,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.02,
                    ),
                    Expanded(
                      flex: 50,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: const ButtonStyle(
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100)), side: BorderSide(color: Colors.grey, width: 1))),
                          backgroundColor: MaterialStatePropertyAll(Colors.white),
                        ),
                        child: Text(
                          "No",
                          style: CustomTextStyle.mediumTextStyle,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.02,
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }
}
