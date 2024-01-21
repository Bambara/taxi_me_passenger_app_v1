import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../../utils/custom_text_style.dart';

class PaymentDialog extends StatefulWidget {
  final dynamic tripEndDetails;
  final Function(String, String) doPay;
  final String cardNumber;
  final String cardMonth;
  final String cardYear;
  final String cardName;
  final String cardCSV;
  final String cardType;

  const PaymentDialog({
    super.key,
    required this.doPay,
    required this.tripEndDetails,
    required this.cardNumber,
    required this.cardMonth,
    required this.cardYear,
    required this.cardName,
    required this.cardCSV,
    required this.cardType,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  String methode = 'CASH';

  bool isTextWritten = false;

  final TextEditingController _txtCardNumberController = TextEditingController();
  final TextEditingController _txtMonthController = TextEditingController();
  final TextEditingController _txtYearController = TextEditingController();
  final TextEditingController _txtCSVController = TextEditingController();

  final _logger = Logger(printer: PrettyPrinter(), filter: null);

  @override
  void initState() {
    super.initState();
    _txtCardNumberController.text = widget.cardNumber;
    _txtMonthController.text = widget.cardMonth;
    _txtYearController.text = widget.cardYear;
    _txtCSVController.text = widget.cardCSV;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    var border = const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(4)), borderSide: BorderSide(color: Colors.grey, width: 1));

    _logger.i(widget.tripEndDetails);

    return Container(
      color: Colors.black.withOpacity(0.2),
      alignment: Alignment.topCenter,
      child: Card(
        margin: const EdgeInsets.all(0),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(16), bottomLeft: Radius.circular(16))),
        elevation: 0,
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(16), bottomLeft: Radius.circular(16)),
          ),
          height: methode == 'CASH'
              ? screenHeight * 0.39
              : methode == 'CARD'
                  ? screenHeight * 0.55
                  : screenHeight * 0.42,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      color: Colors.black,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: const EdgeInsets.only(top: 16),
                      alignment: Alignment.center,
                      child: Text(
                        "Payment",
                        style: CustomTextStyle.mediumTextStyle,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                children: [
                  Expanded(
                    flex: 32,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          methode = 'CASH';
                        });
                        // Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) => AddCard()));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Image(
                            image: AssetImage("assets/icons/payments/cash.png"),
                            height: 40,
                            width: 40,
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text("Cash", style: CustomTextStyle.regularTextStyle.copyWith(fontSize: 12))
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    flex: 32,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          methode = 'CARD';
                        });

                        if (kDebugMode) {
                          print('Dialog');
                        }
                        // Navigator.of(context).push(new MaterialPageRoute(builder: (context) => AddCard()));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Image(
                            image: AssetImage("assets/icons/payments/card.png"),
                            height: 40,
                            width: 40,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text("Card",
                              style: CustomTextStyle.regularTextStyle.copyWith(
                                fontSize: 12,
                                color: Colors.grey,
                              ))
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    flex: 32,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          methode = 'POINTS';
                        });

                        /*return showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    Size size = MediaQuery.of(context).size;
                                    return Dialog(
                                      elevation: 0.0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(size.width * 0.1)),
                                      child: PromoCodeDialog(),
                                    );
                                  },
                                );*/
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Image(
                            image: AssetImage("assets/icons/payments/points.png"),
                            height: 40,
                            width: 40,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text("Points",
                              style: CustomTextStyle.regularTextStyle.copyWith(
                                fontSize: 12,
                                color: Colors.grey,
                              ))
                        ],
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              SizedBox(
                width: screenWidth * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Trip Cost (Rs) ', style: TextStyle(fontSize: screenWidth * 0.04)),
                    SizedBox(width: screenWidth * 0.25),
                    Text(': ${double.tryParse((widget.tripEndDetails['trip']['passengerTripEndRequestModel']['totalCost']).toStringAsFixed(2))}', style: TextStyle(fontSize: screenWidth * 0.04)),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                width: screenWidth * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Promo Code Redeem (Rs) ', style: TextStyle(fontSize: screenWidth * 0.04)),
                    SizedBox(width: screenWidth * 0.034),
                    Text(': 0.00', style: TextStyle(fontSize: screenWidth * 0.04)),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                width: screenWidth * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Balance Cost (Rs) ', style: TextStyle(fontSize: screenWidth * 0.04)),
                    SizedBox(width: screenWidth * 0.1785),
                    Text(': 0.00', style: TextStyle(fontSize: screenWidth * 0.04)),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              methode == 'CARD'
                  ? Column(children: [
                      Container(
                        margin: const EdgeInsets.only(left: 12, right: 12, top: 8),
                        decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(4)), border: Border.all(width: 1, color: Colors.grey.shade400)),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                border: border,
                                enabledBorder: border,
                                focusedBorder: border,
                                contentPadding: const EdgeInsets.only(left: 8, right: 32, top: 10, bottom: 10),
                                hintText: "Card Number",
                                // hasFloatingPlaceholder: true,
                                hintStyle: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 12),
                                labelStyle: CustomTextStyle.regularTextStyle.copyWith(color: Colors.black, fontSize: 12),
                              ),
                              onChanged: (value) {
                                if (value.trim().isNotEmpty) {
                                  setState(() {
                                    isTextWritten = true;
                                  });
                                } else {
                                  isTextWritten = false;
                                }
                              },
                              controller: _txtCardNumberController,
                              keyboardType: TextInputType.phone,
                            ),
                            clearCardNumber()
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        children: [
                          Container(
                            width: screenWidth * 0.15,
                            margin: const EdgeInsets.only(left: 12, right: 12, top: 8),
                            decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(4)), border: Border.all(width: 1, color: Colors.grey.shade400)),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                    border: border,
                                    enabledBorder: border,
                                    focusedBorder: border,
                                    contentPadding: const EdgeInsets.only(left: 8, right: 32, top: 10, bottom: 10),
                                    hintText: "MM",
                                    // hasFloatingPlaceholder: true,
                                    hintStyle: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 12),
                                    labelStyle: CustomTextStyle.regularTextStyle.copyWith(color: Colors.black, fontSize: 12),
                                  ),
                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty) {
                                      setState(() {
                                        isTextWritten = true;
                                      });
                                    } else {
                                      isTextWritten = false;
                                    }
                                  },
                                  controller: _txtMonthController,
                                  keyboardType: TextInputType.phone,
                                ),
                                clearMonth()
                              ],
                            ),
                          ),
                          Text(
                            '/',
                            style: TextStyle(fontSize: screenWidth * 0.05),
                          ),
                          Container(
                            width: screenWidth * 0.15,
                            margin: const EdgeInsets.only(left: 12, right: 12, top: 8),
                            decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(4)), border: Border.all(width: 1, color: Colors.grey.shade400)),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                    border: border,
                                    enabledBorder: border,
                                    focusedBorder: border,
                                    contentPadding: const EdgeInsets.only(left: 8, right: 32, top: 10, bottom: 10),
                                    hintText: "YY",
                                    // hasFloatingPlaceholder: true,
                                    hintStyle: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 12),
                                    labelStyle: CustomTextStyle.regularTextStyle.copyWith(color: Colors.black, fontSize: 12),
                                  ),
                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty) {
                                      setState(() {
                                        isTextWritten = true;
                                      });
                                    } else {
                                      isTextWritten = false;
                                    }
                                  },
                                  controller: _txtYearController,
                                  keyboardType: TextInputType.phone,
                                ),
                                clearYear()
                              ],
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.325),
                          Container(
                            width: screenWidth * 0.2,
                            margin: const EdgeInsets.only(left: 12, right: 12, top: 8),
                            decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(4)), border: Border.all(width: 1, color: Colors.grey.shade400)),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                    border: border,
                                    enabledBorder: border,
                                    focusedBorder: border,
                                    contentPadding: const EdgeInsets.only(left: 8, right: 32, top: 10, bottom: 10),
                                    hintText: "CSV",
                                    // hasFloatingPlaceholder: true,
                                    hintStyle: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 12),
                                    labelStyle: CustomTextStyle.regularTextStyle.copyWith(color: Colors.black, fontSize: 12),
                                  ),
                                  onChanged: (value) {
                                    if (value.trim().isNotEmpty) {
                                      setState(() {
                                        isTextWritten = true;
                                      });
                                    } else {
                                      isTextWritten = false;
                                    }
                                  },
                                  controller: _txtCSVController,
                                  keyboardType: TextInputType.phone,
                                ),
                                clearCSV()
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ])
                  : methode == 'POINTS'
                      ? SizedBox(
                          width: screenWidth * 0.9,
                          child: Row(children: [
                            Text('Remain Points (Rs) ', style: TextStyle(fontSize: screenWidth * 0.04)),
                            SizedBox(width: screenWidth * 0.159),
                            Text(': 0.00', style: TextStyle(fontSize: screenWidth * 0.04)),
                          ]),
                        )
                      : Container(),
              Padding(
                padding: EdgeInsets.only(right: screenWidth * 0.05),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      /*Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => TripEnd(
                            tripEndDetails: data,
                            driverDetails: widget.driverDetailsData,
                            driverID: widget.driverDetailsData['driverId'],
                            currentLoaction: _ahmedabad1,
                            destionationLocation: _ahmedabad,
                            passengerPickupData: widget.passengerPickupData,
                            passengerDropData: widget.passengerDropData,
                          ),
                        ),
                      );*/
                      widget.doPay(methode.toLowerCase(), 'payed');
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.tealAccent.shade400),
                      child: const Icon(
                        Icons.payments_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  clearCardNumber() {
    if (isTextWritten) {
      return Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () {
            _txtCardNumberController.clear();
            setState(() {
              isTextWritten = false;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
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

  clearMonth() {
    if (isTextWritten) {
      return Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () {
            _txtMonthController.clear();
            setState(() {
              isTextWritten = false;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
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

  clearYear() {
    if (isTextWritten) {
      return Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () {
            _txtYearController.clear();
            setState(() {
              isTextWritten = false;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
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

  clearCSV() {
    if (isTextWritten) {
      return Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () {
            _txtCSVController.clear();
            setState(() {
              isTextWritten = false;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
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
}
