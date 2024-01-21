import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../utils/custom_text_style.dart';
import '../../utils/dotted_line.dart';
import 'dialog/promo_code_dialog.dart';
import 'trip_end.dart';

class TripInfo extends StatefulWidget {
  const TripInfo({super.key});

  @override
  _TripInfoState createState() => _TripInfoState();
}

class _TripInfoState extends State<TripInfo> {
  final _ahmedabad = const LatLng(23.0225, 72.5714);
  Set<Marker> markers = {};

  late GoogleMapController mapController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    markers.add(Marker(
      markerId: const MarkerId("ahmedabad"),
      position: _ahmedabad,
    ));
  }

  void _onMapCreated(GoogleMapController mapController) {
    this.mapController = mapController;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              key: const Key("GoogleMap"),
              initialCameraPosition: CameraPosition(target: _ahmedabad, zoom: 14),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: markers,
              onMapCreated: _onMapCreated,
            ),
            Column(
              key: const Key("AddressSection"),
              children: <Widget>[
                const SizedBox(height: 16),
                Card(
                  key: const Key("CardSourceAddress"),
                  margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
                  child: Container(
                    key: const Key("ContainerSourceAddress"),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: 10,
                          margin: const EdgeInsets.only(left: 16),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          height: 10,
                        ),
                        Expanded(
                          flex: 100,
                          child: Container(
                            margin: const EdgeInsets.only(left: 16),
                            child: Text(
                              "DDS Techvira",
                              style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey.shade800),
                            ),
                          ),
                        ),
                        IconButton(
                            icon: const Icon(
                              Icons.favorite_border,
                              color: Colors.grey,
                              size: 18,
                            ),
                            onPressed: () {})
                      ],
                    ),
                  ),
                ),
                Card(
                  key: const Key("CardDestAddress"),
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    key: const Key("ContainerDestAddress"),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: 10,
                          margin: const EdgeInsets.only(left: 16),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          height: 10,
                        ),
                        Expanded(
                          flex: 100,
                          child: Container(
                            margin: const EdgeInsets.only(left: 16),
                            padding: const EdgeInsets.only(top: 16, bottom: 16),
                            child: Text(
                              "WTC East Tower",
                              style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey.shade800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  key: Key("SizedBox_16"),
                  height: 16,
                ),
                ElevatedButton(
                  key: const Key("btnCancelTrip"),
                  onPressed: () {},
                  style: ButtonStyle(
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
                    foregroundColor: const MaterialStatePropertyAll(Colors.white),
                    backgroundColor: MaterialStatePropertyAll(Colors.black.withOpacity(0.6)),
                    padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 28)),
                  ),
                  child: Text(
                    "Cancel Trip",
                    style: CustomTextStyle.regularTextStyle,
                  ),
                )
              ],
            ),
            Align(
              key: const Key("alignBottomView"),
              alignment: Alignment.bottomCenter,
              child: Container(
                key: const Key("ContainerBottomView"),
                height: 490,
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.4)),
                      child: const Icon(
                        Icons.traffic,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                        child: Stack(
                      children: <Widget>[
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                            color: Colors.white,
                          ),
                          margin: const EdgeInsets.only(top: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 80,
                                    height: 80,
                                    margin: const EdgeInsets.only(top: 16, left: 10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      image: const DecorationImage(image: AssetImage("assets/images/driver.jpg")),
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
                                        "Nihal Perera",
                                        style: CustomTextStyle.mediumTextStyle,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "On the way",
                                        style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.tealAccent.shade400),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        margin: const EdgeInsets.only(top: 6),
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey, width: 1)),
                                        child: RichText(
                                          text: TextSpan(children: [
                                            TextSpan(text: " CBC5687 ", style: CustomTextStyle.boldTextStyle.copyWith(color: Colors.black)),
                                            TextSpan(text: " - ", style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.grey)),
                                            TextSpan(text: " Toyota Prius(white) ", style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey)),
                                          ]),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              DottedLine(08, 8, 0),
                              Container(
                                margin: const EdgeInsets.only(left: 8, top: 8),
                                child: Text(
                                  "Fare Breakdown",
                                  style: CustomTextStyle.mediumTextStyle,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 8, top: 4),
                                child: Text(
                                  "3 Passengers",
                                  style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 12),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 8, right: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      margin: const EdgeInsets.only(
                                        top: 8,
                                      ),
                                      child: Text(
                                        "Min Fare (First 1 Km)",
                                        style: CustomTextStyle.mediumTextStyle.copyWith(fontSize: 14),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        "RS 80.00",
                                        style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 14),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 8, right: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        "After 1 Km (Per Km)",
                                        style: CustomTextStyle.mediumTextStyle.copyWith(fontSize: 14),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        "Rs 5.00",
                                        style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 14),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 8, right: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        "Waiting Time (Per 1 Hour)",
                                        style: CustomTextStyle.mediumTextStyle.copyWith(fontSize: 14),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                        top: 8,
                                      ),
                                      child: Text(
                                        "Rs  300.00",
                                        style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 14),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              DottedLine(08, 8, 0),
                              Container(
                                margin: const EdgeInsets.only(left: 8, top: 8),
                                child: Text(
                                  "Let's Rate",
                                  style: CustomTextStyle.mediumTextStyle,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 8, top: 4),
                                child: Text(
                                  "What do you think about the driver performance?",
                                  style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 12),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 4, top: 8),
                                child: RatingBar.builder(
                                  glowColor: Colors.amber,
                                  initialRating: 0,
                                  // borderColor: Colors.grey.shade400,
                                  allowHalfRating: true,
                                  itemPadding: const EdgeInsets.all(0),
                                  itemSize: 24,
                                  onRatingUpdate: (double rating) {},
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                              Container(
                                width: double.infinity,
                                color: Colors.grey.shade300,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 50,
                                      child: GestureDetector(
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.only(top: 14, bottom: 14),
                                          child: Text(
                                            "Payment",
                                            style: CustomTextStyle.regularTextStyle,
                                          ),
                                        ),
                                        onTap: () {
                                          // showDialog(
                                          //     context: context,
                                          //     builder: (context) {
                                          //       // return PaymentDialog();
                                          //     });
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: Colors.grey,
                                    ),
                                    Expanded(
                                      flex: 50,
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return PromoCodeDialog(
                                                  addCode: (p0, p1) {},
                                                  promoCodeLength: 0,
                                                  promoCode: [],
                                                );
                                              });
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.only(top: 14, bottom: 14),
                                          child: Text(
                                            "Promo Code",
                                            style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => TripEnd(
                                              driverID: '',
                                              passengerDropData: const [],
                                            )));
                                  },
                                  style: ButtonStyle(
                                    shape: const MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0)))),
                                    foregroundColor: const MaterialStatePropertyAll(Colors.white),
                                    backgroundColor: MaterialStatePropertyAll(Colors.tealAccent.shade700),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    padding: const MaterialStatePropertyAll(EdgeInsets.all(16)),
                                  ),
                                  child: Text(
                                    "Call Driver",
                                    style: CustomTextStyle.mediumTextStyle.copyWith(color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                  boxShadow: [BoxShadow(color: Colors.grey.shade100, offset: const Offset(1, 1), blurRadius: 8, spreadRadius: 1)], color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                  boxShadow: [BoxShadow(color: Colors.grey.shade100, offset: const Offset(1, 1), blurRadius: 8, spreadRadius: 1)],
                                  color: Colors.grey.shade800,
                                  shape: BoxShape.circle),
                              child: const Icon(
                                Icons.info_outline,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                          ],
                        ),
                      ],
                    ))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
