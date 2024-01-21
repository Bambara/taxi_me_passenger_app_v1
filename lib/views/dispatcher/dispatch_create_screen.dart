import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:page_transition/page_transition.dart';

import '../../Widgets/custom_button_widgets.dart';
import '../../Widgets/custom_datetime_picker.dart';
import '../../Widgets/custom_text_filed.dart';
import '../../Widgets/loading_dialog.dart';
import '../../core/constants/constants.dart';
import '../../user_dashboard/user_dashboard_styles.dart';
import '../../utils/color_constant.dart';
import '../../utils/settings.dart';
import '../styles.dart';
import 'vehicle_category_screen.dart';

class DispatchCreateScreen extends StatefulWidget {
  const DispatchCreateScreen({super.key});

  @override
  _DispatchCreateScreenState createState() => _DispatchCreateScreenState();
}

class _DispatchCreateScreenState extends State<DispatchCreateScreen> {
  final _logger = Logger(printer: PrettyPrinter(), filter: null);

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

  final _pickupLocationCtrl = TextEditingController();
  final _dropLocationCtrl = TextEditingController();
  final custName = TextEditingController();
  final numberOfPassengers = TextEditingController();
  final custPhone = TextEditingController();
  final custNotes = TextEditingController();
  final pickDate = TextEditingController();
  final pickTime = TextEditingController();

  bool isTextWritten = true;
  bool loaded = false;

  late LatLng pickupPlace;
  late LatLng dropPlace;

  late DateTime pickDateValue, pickTimeValue;

  String dispacthID = "";

  getData() async {
    // _logger.i('Caled ME');
    dispacthID = await Settings.getDispatcherID();
    _logger.i('dispacthID :$dispacthID');
    // var position = await GeolocatorPlatform.instance.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // _logger.i('position : ' + position.toString());
    // List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    // Placemark place1 = placemarks[0];
    // Placemark place2 = placemarks[1];
    setState(() {
      // pickupPlace = LatLng(position.latitude, position.longitude);
      // _pickupLocationCtrl.text = "${place1.street}, ${place2.thoroughfare}, ${place1.locality}";
      loaded = true;
      _logger.i('Loaded : $loaded');
    });
  }

  compileData() async {
    Map tripDetails = {
      "dispatcherId": dispacthID,
      "custName": custName.text,
      "custNumber": custPhone.text,
      "numberOfPassengers": numberOfPassengers.text,
      "custNotes": custNotes.text,
      "pickDate": pickDate.text,
      "pickTime": pickTime.text
    };

    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: VehicleCategory(
          passengerCode: "passengerCode",
          isTextWritten: true,
          pickupPlaceAddress: _pickupLocationCtrl.text,
          pickupPlace: pickupPlace,
          dropOffPlaceAddress: _dropLocationCtrl.text,
          dropOffPlace: dropPlace,
          tripDetails: tripDetails,
        ),
      ),
    );
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeArea = MediaQuery.of(context).padding.top;
    final themeData = Theme.of(context);

    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    /*return MaterialApp(
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFFF9000),
        ),
      ),
      home: Scaffold(
        key: _scaffoldState,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 1.0,
          centerTitle: true,
          title: Text(
            "Dispatch Create",
            style: UserDashBoardStyles().textHeading1(),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: UserDashBoardStyles.fontColor,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: loaded
              ? Container(
                  width: width,
                  height: height,
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 70,
                          width: width,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
                          child: Text(
                            "Dispatcher ID :  $dispacthID",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                        ),
                        breaker(width, "Customer Info"),
                        CustomTextFiled(
                          controller: custName,
                          labelText: "Customer Name",
                          width: width - 40,
                          hint: '',
                          validator: (string) {
                            return '';
                          },
                          type: '',
                          prifixIcon: '',
                          height: 50.0,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomTextFiled(
                          controller: numberOfPassengers,
                          labelText: "Number of Passengers",
                          width: width - 40,
                          type: "number",
                          hint: '',
                          validator: (string) {
                            return '';
                          },
                          prifixIcon: '',
                          height: 50.0,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomTextFiled(
                          controller: custPhone,
                          labelText: "Customer Phone Number",
                          width: width - 40,
                          type: "phoneNumber",
                          hint: '',
                          validator: (string) {
                            return '';
                          },
                          prifixIcon: '',
                          height: 50.0,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomTextFiled(
                          controller: custNotes,
                          labelText: "Notes",
                          width: width - 40,
                          height: 70,
                          minLine: 3,
                          maxLine: 4,
                          hint: '',
                          validator: (string) {
                            return '';
                          },
                          type: '',
                          prifixIcon: '',
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        breaker(width, "Date and Time"),
                        CustomDateTimePicker(
                          dateHint: "Pickup Date",
                          dateController: pickDate,
                          newDate: (value) {
                            pickDateValue = value;
                          },
                          timeHint: "Pickup Time",
                          timeController: pickTime,
                          newTime: (value) {
                            pickTimeValue = value;
                          },
                          dateValidator: (string) {
                            return '';
                          },
                          dateLabelText: '',
                          timeValidator: (string) {
                            return '';
                          },
                          timeLabelText: '',
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        breaker(width, "Pick and Drop Location"),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 50.0,
                              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: GooglePlaceAutoCompleteTextField(
                                  textEditingController: _pickupLocationCtrl,
                                  googleAPIKey: "AIzaSyCtg102uMuplrssv_sk_FD-IcKI5hxnnSw",
                                  inputDecoration: InputDecoration(
                                    labelText: 'Enter Pickup Location',
                                    labelStyle: greyNormalTextStyle,
                                    contentPadding: const EdgeInsets.only(left: 10.0),
                                    suffixIcon: IconButton(
                                      icon: const Icon(
                                        Icons.cancel_rounded,
                                        color: Colors.black45,
                                      ),
                                      onPressed: () => createClearTextPickup(),
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
                                    errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                                    disabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5.0)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
                                    focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                                    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5.0)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
                                  ),
                                  countries: ["LK"],
                                  isLatLngRequired: true,
                                  getPlaceDetailWithLatLng: (Prediction prediction) {
                                    _logger.i("placeDetails${prediction.lng}");

                                    setState(() {
                                      pickupPlace = LatLng(double.parse(prediction.lat!), double.parse(prediction.lng!));
                                    });
                                  },
                                  itmClick: (Prediction prediction) {
                                    _logger.i(prediction.lat);
                                    _pickupLocationCtrl.text = prediction.description!;
                                    _pickupLocationCtrl.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description!.length));
                                  }),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 50.0,
                              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: GooglePlaceAutoCompleteTextField(
                                textEditingController: _dropLocationCtrl,
                                googleAPIKey: "AIzaSyCtg102uMuplrssv_sk_FD-IcKI5hxnnSw",
                                inputDecoration: InputDecoration(
                                  labelText: 'Enter Drop Location',
                                  labelStyle: greyNormalTextStyle,
                                  contentPadding: const EdgeInsets.only(left: 10.0),
                                  suffixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.cancel_rounded,
                                      color: Colors.black45,
                                    ),
                                    onPressed: () => createClearTextDrop(),
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
                                  errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                                  disabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5.0)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
                                  focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                                  focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5.0)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
                                ),
                                countries: ["LK"],
                                isLatLngRequired: true,
                                getPlaceDetailWithLatLng: (Prediction prediction) {
                                  _logger.i("placeDetails${prediction.lng}");
                                  setState(() {
                                    dropPlace = LatLng(double.parse(prediction.lat!), double.parse(prediction.lng!));
                                  });
                                },
                                itmClick: (Prediction prediction) {
                                  _dropLocationCtrl.text = prediction.description!;
                                  _dropLocationCtrl.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description!.length));
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        CustomButtonWidget(
                          color: UserDashBoardStyles.fontColor,
                          text: 'Select Ride',
                          textColor: UserDashBoardStyles.fontWhiteColor,
                          onClicked: () {
                            compileData();
                          },
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                )
              : loadingDialog(context),
        ),
      ),
    );*/
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        backgroundColor: ColorConstant.appOrange,
        foregroundColor: themeData.textTheme.bodyText1!.color,
        title: const Text('Dispatch Create'),
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: loaded
            ? Container(
                padding: EdgeInsets.all(screenHeight * 0.008),
                child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: screenHeight * 0.06,
                          width: screenWidth,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(screenHeight * 0.015)),
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
                          child: Text(
                            "Dispatcher ID :  $dispacthID",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                        ),
                        breaker(screenWidth, "Customer Info"),
                        CustomTextFiled(
                          controller: custName,
                          labelText: "Customer Name",
                          width: screenWidth - 40,
                          hint: '',
                          validator: (string) {
                            return '';
                          },
                          minLine: 1,
                          maxLine: 1,
                          type: '',
                          prifixIcon: '',
                          height: 50.0,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomTextFiled(
                          controller: numberOfPassengers,
                          labelText: "Number of Passengers",
                          width: screenWidth - 40,
                          type: "number",
                          hint: '',
                          minLine: 1,
                          maxLine: 1,
                          validator: (string) {
                            return '';
                          },
                          prifixIcon: '',
                          height: 50.0,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomTextFiled(
                          controller: custPhone,
                          labelText: "Customer Phone Number",
                          width: screenWidth - 40,
                          type: "phoneNumber",
                          hint: '',
                          minLine: 1,
                          maxLine: 1,
                          validator: (string) {
                            return '';
                          },
                          prifixIcon: '',
                          height: 50.0,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomTextFiled(
                          controller: custNotes,
                          labelText: "Notes",
                          width: screenWidth - 40,
                          height: 70,
                          minLine: 3,
                          maxLine: 4,
                          hint: '',
                          validator: (string) {
                            return '';
                          },
                          type: '',
                          prifixIcon: '',
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        breaker(screenWidth, "Date and Time"),
                        CustomDateTimePicker(
                          dateHint: "Pickup Date",
                          dateController: pickDate,
                          newDate: (value) {
                            pickDateValue = value;
                          },
                          timeHint: "Pickup Time",
                          timeController: pickTime,
                          newTime: (value) {
                            pickTimeValue = value;
                          },
                          dateValidator: (string) {
                            return '';
                          },
                          dateLabelText: '',
                          timeValidator: (string) {
                            return '';
                          },
                          timeLabelText: '',
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        breaker(screenWidth, "Pick and Drop Location"),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 50.0,
                              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: GooglePlaceAutoCompleteTextField(
                                  textEditingController: _pickupLocationCtrl,
                                  googleAPIKey: "AIzaSyCtg102uMuplrssv_sk_FD-IcKI5hxnnSw",
                                  inputDecoration: InputDecoration(
                                    labelText: 'Enter Pickup Location',
                                    labelStyle: greyNormalTextStyle,
                                    contentPadding: const EdgeInsets.only(left: 10.0),
                                    suffixIcon: IconButton(
                                      icon: const Icon(
                                        Icons.cancel_rounded,
                                        color: Colors.black45,
                                      ),
                                      onPressed: () => createClearTextPickup(),
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
                                    errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                                    disabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5.0)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
                                    focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                                    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5.0)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
                                  ),
                                  countries: ["LK"],
                                  isLatLngRequired: true,
                                  getPlaceDetailWithLatLng: (Prediction prediction) {
                                    _logger.i("placeDetails${prediction.lng}");

                                    setState(() {
                                      pickupPlace = LatLng(double.parse(prediction.lat!), double.parse(prediction.lng!));
                                    });
                                  },
                                  itmClick: (Prediction prediction) {
                                    _logger.i(prediction.lat);
                                    _pickupLocationCtrl.text = prediction.description!;
                                    _pickupLocationCtrl.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description!.length));
                                  }),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 50.0,
                              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: GooglePlaceAutoCompleteTextField(
                                textEditingController: _dropLocationCtrl,
                                googleAPIKey: "AIzaSyCtg102uMuplrssv_sk_FD-IcKI5hxnnSw",
                                inputDecoration: InputDecoration(
                                  labelText: 'Enter Drop Location',
                                  labelStyle: greyNormalTextStyle,
                                  contentPadding: const EdgeInsets.only(left: 10.0),
                                  suffixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.cancel_rounded,
                                      color: Colors.black45,
                                    ),
                                    onPressed: () => createClearTextDrop(),
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
                                  errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                                  disabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5.0)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
                                  focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                                  focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5.0)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
                                ),
                                countries: ["LK"],
                                isLatLngRequired: true,
                                getPlaceDetailWithLatLng: (Prediction prediction) {
                                  _logger.i("placeDetails${prediction.lng}");
                                  setState(() {
                                    dropPlace = LatLng(double.parse(prediction.lat!), double.parse(prediction.lng!));
                                  });
                                },
                                itmClick: (Prediction prediction) {
                                  _dropLocationCtrl.text = prediction.description!;
                                  _dropLocationCtrl.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description!.length));
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        CustomButtonWidget(
                          color: UserDashBoardStyles.fontColor,
                          text: 'Select Ride',
                          textColor: UserDashBoardStyles.fontWhiteColor,
                          onClicked: () {
                            compileData();
                          },
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              )
            : loadingDialog(context),
      ),
    );
  }

  breaker(double width, String title) {
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      alignment: Alignment.center,
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 8),
            color: const Color(0xFFFF9000),
            width: width,
            height: 3,
          ),
          Center(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  createClearTextPickup() {
    _pickupLocationCtrl.clear();
    setState(() {
      isTextWritten = false;
    });
  }

  createClearTextDrop() {
    _dropLocationCtrl.clear();
    setState(() {
      isTextWritten = false;
    });
  }
}
