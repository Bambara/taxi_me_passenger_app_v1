import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';

import '../../Widgets/custom_text_filed.dart';
import '../../generated/assets.dart';
import '../../user_dashboard/user_dashboard_page.dart';
import '../../utils/api_client.dart';
import '../../utils/custom_text_style.dart';
import '../../utils/dotted_line.dart';

class TripEnd extends StatefulWidget {
  var tripEndDetails;
  var currentLoaction;
  var destionationLocation;
  var driverDetails;
  var passengerPickupData;
  String driverID;
  List passengerDropData = [];

  TripEnd(
      {super.key, this.tripEndDetails, this.driverDetails, this.currentLoaction, required this.driverID, this.destionationLocation, this.passengerPickupData, required this.passengerDropData});

  @override
  _TripEndState createState() => _TripEndState();
}

class _TripEndState extends State<TripEnd> {
  Set<Marker> markers = {};

  late GoogleMapController mapController;
  late BitmapDescriptor bitmapDescriptor;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final TextEditingController _feedbackController = TextEditingController();

  double rating = 0.0;

  final _logger = Logger(printer: PrettyPrinter(), filter: null);

  // _TripEndState();

  @override
  void initState() {
    super.initState();
  }

  submitRating() async {
    if (kDebugMode) {
      print("got here");
    }
    var data = {'id': widget.driverID, 'rate': rating, 'feedback': _feedbackController.text};

    final response = await ApiClient().postData(data, '/user/add_driver_ratings');

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print(response.body);
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const UserDashboardPage()));
    } else {
      if (kDebugMode) {
        print(response.body);
      }
      if (kDebugMode) {
        print("+++++++++++++++++++");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _logger.i(widget.tripEndDetails);

    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey,
        body: WillPopScope(
          onWillPop: () {
            Navigator.pop(context);
            return Future(() => true);
          },
          child: GestureDetector(
            onTap: () => {FocusScope.of(context).unfocus()},
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              padding: const EdgeInsets.only(top: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    tripEnd(),
                    driveSection(),
                    DottedLine(12, 12, 4),
                    const SizedBox(
                      height: 8,
                    ),
                    addressSection(),
                    DottedLine(12, 12, 4),
                    tripFare(),
                    DottedLine(12, 12, 4),
                    rate(),
                    getSizedBox(),
                    getSizedBox(),
                    actionButton()
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  tripEnd() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
          child: RichText(
            text: TextSpan(children: [
              TextSpan(text: "Trip ID : ", style: CustomTextStyle.boldTextStyle.copyWith(color: Colors.black)),
              TextSpan(text: widget.tripEndDetails['trip']['_id'].toString(), style: CustomTextStyle.boldTextStyle.copyWith(color: Colors.grey)),
            ]),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 12, right: 8),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserDashboardPage()));
            },
            child: const Icon(
              Icons.close,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  driveSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.only(top: 16, left: 10),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            image: const DecorationImage(image: AssetImage(Assets.imagesDriver)),
            // image: DecorationImage(image: NetworkImage(widget.driverDetails['driverPic'])),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(
          width: 16,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            Text(
              widget.driverDetails['driverName'].toString(),
              style: CustomTextStyle.mediumTextStyle,
            ),
            const SizedBox(height: 6),
            Text(
              "Trip end",
              style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.grey.shade400),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey, width: 1)),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(text: widget.driverDetails['vehicleRegistrationNo'].toString(), style: CustomTextStyle.boldTextStyle.copyWith(color: Colors.black)),
                  TextSpan(text: " - ", style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.grey)),
                  TextSpan(
                      text: "${widget.driverDetails['vehicleBrand']}  ${widget.driverDetails['vehicleModel']}(${widget.driverDetails['vehicleColor']})",
                      style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey)),
                ]),
              ),
            )
          ],
        )
      ],
    );
  }

  addressSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 4,
        ),
        addressRow(Colors.tealAccent.shade700, widget.passengerPickupData['address'], " "),
        const SizedBox(
          height: 12,
        ),
        addressRow(Colors.redAccent.shade700, widget.passengerDropData[0]['address'], " ")
      ],
    );
  }

  addressRow(Color color, String address, String dateTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 10,
          width: 10,
          margin: const EdgeInsets.only(left: 16, top: 3),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(
          width: 12,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: Text(
                address,
                style: CustomTextStyle.boldTextStyle,
              ),
            ),
            Text(
              dateTime,
              style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 12),
            )
          ],
        )
      ],
    );
  }

  fareDetails() {
    return Column(
      key: const Key("ColumnFareDetails"),
      children: <Widget>[
        Container(
          key: const Key("ContainerFareDetails"),
          margin: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            key: const Key("RowFareDetails"),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                key: const Key("ContainerCashFare"),
                margin: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  "Cash",
                  key: const Key("tvCash"),
                  style: CustomTextStyle.mediumTextStyle.copyWith(fontSize: 12),
                ),
              ),
              Container(
                key: const Key("ContainerCashAmountFare"),
                margin: const EdgeInsets.only(right: 8, top: 4),
                child: Text(
                  "LKR ${widget.tripEndDetails['trip']['totalPrice']}",
                  key: const Key("tvCashAmount"),
                  style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 12),
                ),
              )
            ],
          ),
        ),
        Container(
          key: const Key("ContainerDiscount"),
          margin: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            key: const Key("RowDiscount"),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                key: const Key("ContainerDiscountFare"),
                margin: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  "Discount",
                  key: const Key("tvDiscount"),
                  style: CustomTextStyle.mediumTextStyle.copyWith(fontSize: 12),
                ),
              ),
              Container(
                key: const Key("ContainerDiscountAmount"),
                margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                child: Text(
                  "LKR 0.00",
                  key: const Key("tvDiscountAmount"),
                  style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 12),
                ),
              )
            ],
          ),
        ),
        Container(
          key: const Key("ContainerPaidAmount"),
          margin: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            key: const Key("RowPaidAmount"),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                key: const Key("ContainerPaidAmountFare"),
                margin: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  "Paid Amount",
                  key: const Key("tvPaidAmountFare"),
                  style: CustomTextStyle.mediumTextStyle.copyWith(fontSize: 12),
                ),
              ),
              Container(
                key: const Key("ContainerPaidAmountFareAmount"),
                margin: const EdgeInsets.only(right: 8, top: 4),
                child: Text(
                  "LKR ${widget.tripEndDetails['trip']['totalPrice']}",
                  key: const Key("tvPaidAmount"),
                  style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 12),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  SizedBox getSizedBox() {
    return const SizedBox(
      height: 4,
    );
  }

  tripFare() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          key: const Key("tvTripFare"),
          margin: const EdgeInsets.only(left: 16, top: 8),
          child: Text(
            "Trip Fare",
            style: CustomTextStyle.boldTextStyle,
          ),
        ),
        Container(
          key: const Key("tvPaidBy"),
          margin: const EdgeInsets.only(left: 16, top: 4),
          child: Text(
            "Paid By",
            style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 12),
          ),
        ),
        getSizedBox(),
        getSizedBox(),
        fareDetails()
      ],
    );
  }

  rate() {
    return SizedBox(
      key: const Key("ContainerRate"),
      width: double.infinity,
      child: Column(
        key: const Key("ColumnRate"),
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            key: const Key("ContainerRateLabel"),
            margin: const EdgeInsets.only(left: 16, top: 8),
            child: Text(
              "Let's Rate",
              key: const Key("tvRate"),
              style: CustomTextStyle.mediumTextStyle,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
            child: CustomTextFiled(
              controller: _feedbackController,
              keyboardType: TextInputType.text,
              labelText: "Feedback",
              width: MediaQuery.of(context).size.width - 30,
              hint: '',
              validator: (string) {
                return '';
              },
              type: '',
              prifixIcon: '',
              height: 0,
            ),
          ),
          Container(
            key: const Key("ContainerRateMessage"),
            margin: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              "What do you think about the driver performance?",
              key: const Key("tvRateMessage"),
              style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 12),
            ),
          ),
          Container(
            key: const Key("ContainerRating"),
            margin: const EdgeInsets.only(left: 12, top: 8),
            child: RatingBar.builder(
              glowColor: Colors.amber,
              initialRating: 0,
              // borderColor: Colors.grey.shade400,
              allowHalfRating: true,
              itemPadding: const EdgeInsets.all(0),
              itemSize: 24,
              onRatingUpdate: (double value) {
                setState(() {
                  rating = value;
                });
              },
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  actionButton() {
    return Container(
      margin: const EdgeInsets.only(left: 4, right: 16, top: 20),
      width: 250,
      child: ElevatedButton(
        onPressed: () {
          submitRating();
        },
        style: ButtonStyle(
          shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(100)), side: BorderSide(color: Colors.grey.shade400, width: 1))),
          // foregroundColor: MaterialStatePropertyAll(Colors.white),
          backgroundColor: const MaterialStatePropertyAll(Colors.white),
        ),
        child: Text(
          "Submit",
          style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.black),
        ),
      ),
    );
  }
}
