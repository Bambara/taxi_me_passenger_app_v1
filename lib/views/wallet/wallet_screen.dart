import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:taxi_me_passenger_app_v1/generated/assets.dart';
import 'package:taxi_me_passenger_app_v1/utils/color_constant.dart';
import 'package:taxi_me_passenger_app_v1/widgets/ltw_promo_code.dart';

import '../../Utils/settings.dart';
import '../../core/constants/constants.dart';
import '../../utils/api_client.dart';
import '../../utils/dotted_line.dart';
import '../../widgets/icon_button_widget.dart';
import '../../widgets/loading_dialog.dart';
import '../../widgets/ltw_trasaction_history.dart';
import '../../widgets/text_field_widget.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  // WalletScreen({Key key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _logger = Logger(printer: PrettyPrinter(), filter: null);

  String _passengerId = '';
  List<dynamic> _promoCode = [];
  int _promoCodeLength = 0;
  List<dynamic> _referral = [''];
  int _referralLength = 0;
  List<dynamic> _transactionHistory = [''];
  double _totalWalletPoints = 0;
  int _bonusAmount = 0;

  final _cardNumberCtrl = TextEditingController();
  final _cardMonthCtrl = TextEditingController();
  final _cardYearCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _cardCSVCtrl = TextEditingController();
  String _cardType = 'VISA';

  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _getProfileData();
  }

  void _getProfileData() async {
    String userID = await Settings.getUserID();
    // final data = {'userId': userID};
    final data = {'passengerId': userID};

    // await ApiClient().postData(data, '/user/checkInfo').then((res)

    await ApiClient().postData(data, '/passengerWallet/getWallet').then((res) {
      final response = jsonDecode(res.body);
      // _logger.i(response);

      setState(() {
        //Fill Card Details
        _cardType = response['content']['card']['type'].toString();
        _cardNumberCtrl.text = response['content']['card']['number'].toString();
        _cardMonthCtrl.text = response['content']['card']['month'].toString();
        _cardYearCtrl.text = response['content']['card']['year'].toString();
        _cardNameCtrl.text = response['content']['card']['owner_name'].toString();
        _cardCSVCtrl.text = response['content']['card']['csv_code'].toString();

        _passengerId = response['content']['_id'].toString();
        if (_passengerId.isEmpty) {
          _passengerId = '';
        }

        _promoCode = response['content']['promocode'];
        if (_promoCode.isEmpty) {
          var promoCode_1 = {
            "promocode": 'gfgfgfg',
            "validStartingDate": '2023-06-05',
            "validEndingDate": '2023-06-15',
            "recordedDate": '2023-06-05',
            "value": 75,
            "isActive": true,
          };

          var promoCode_2 = {
            "promocode": 'gfgfgfg',
            "validStartingDate": '2023-06-05',
            "validEndingDate": '2023-06-15',
            "recordedDate": '2023-06-05',
            "value": 25,
            "isActive": true,
          };
          _promoCode = [promoCode_1, promoCode_2];
          _promoCodeLength = _promoCode.length;
        } else {
          _promoCodeLength = _promoCode.length;
        }

        _referral = response['content']['referral'];
        if (_referral.isEmpty) {
          _referral = [];
          _referralLength = _referral.length;
        } else {
          _referralLength = _referral.length;
        }

        _transactionHistory = response['content']['transactionHistory'];
        if (_transactionHistory.isEmpty) {
          _transactionHistory = [];
        }

        _totalWalletPoints = response['content']['totalWalletPoints'];
        _bonusAmount = response['content']['bonusAmount'];

        loaded = true;
      });
    });

    // String dispatcherID = response['content1'][0]['dispatcher'][0]['dispatcherId'];
  }

  void _addCard() async {
    try {
      var cardFirstDigit = _cardNumberCtrl.text.substring(0, 1);
      if (cardFirstDigit == '3') {
        _cardType = 'AMEX';
        _logger.w(_cardType);
      } else if (cardFirstDigit == '4') {
        _cardType = 'VISA';
        _logger.w(_cardType);
      } else if (cardFirstDigit == '5') {
        _cardType = 'MASTER';
        _logger.w(_cardType);
      } else if (cardFirstDigit == '6') {
        _cardType = 'DISCOVER';
        _logger.w(_cardType);
      }

      final data = {
        "card": {
          "type": _cardType,
          "number": _cardNumberCtrl.text,
          "month": _cardMonthCtrl.text,
          "year": _cardYearCtrl.text,
          "csv_code": _cardCSVCtrl.text,
          "owner_name": _cardNameCtrl.text,
        }
      };

      String userID = await Settings.getUserID();

      await ApiClient().patchData(data, 'passengerId=$userID', '/passengerWallet/add_card').then((res) {
        final response = jsonDecode(res.body);
        // _logger.i(response);

        setState(() {
          //Fill Card Details
          _cardType = response['content']['card']['type'].toString();
          _cardNumberCtrl.text = response['content']['card']['number'].toString();
          _cardMonthCtrl.text = response['content']['card']['month'].toString();
          _cardYearCtrl.text = response['content']['card']['year'].toString();
          _cardNameCtrl.text = response['content']['card']['owner_name'].toString();
          _cardCSVCtrl.text = response['content']['card']['csv_code'].toString();

          _passengerId = response['content']['_id'].toString();
          if (_passengerId.isEmpty) {
            _passengerId = '';
          }

          _promoCode = response['content']['promocode'];
          if (_promoCode.isEmpty) {
            var promoCode_1 = {
              "promocode": 'gfgfgfg',
              "validStartingDate": '2023-06-05',
              "validEndingDate": '2023-06-15',
              "recordedDate": '2023-06-05',
              "value": 75,
              "isActive": true,
            };

            var promoCode_2 = {
              "promocode": 'gfgfgfg',
              "validStartingDate": '2023-06-05',
              "validEndingDate": '2023-06-15',
              "recordedDate": '2023-06-05',
              "value": 25,
              "isActive": true,
            };
            _promoCode = [promoCode_1, promoCode_2];
            _promoCodeLength = _promoCode.length;
          } else {
            _promoCodeLength = _promoCode.length;
          }

          _referral = response['content']['referral'];
          if (_referral.isEmpty) {
            _referral = [];
            _referralLength = _referral.length;
          } else {
            _referralLength = _referral.length;
          }

          _transactionHistory = response['content']['transactionHistory'];
          if (_transactionHistory.isEmpty) {
            _transactionHistory = [];
          }

          _totalWalletPoints = response['content']['totalWalletPoints'];
          _bonusAmount = response['content']['bonusAmount'];
        });

        Fluttertoast.showToast(msg: 'Card adding success', backgroundColor: Colors.teal, fontSize: 14, toastLength: Toast.LENGTH_SHORT);
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Card adding fail', backgroundColor: Colors.redAccent, fontSize: 14, toastLength: Toast.LENGTH_SHORT);
      _logger.e(e);
    }
  }

  void _loadAddOrganizationBottomSheet(BuildContext context, double screenHeight, double screenWidth, ThemeData themeData) {
    final TextEditingController nameCtrl = TextEditingController();

    showMaterialModalBottomSheet(
        backgroundColor: themeData.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constants.boarderRadius)),
        context: context,
        builder: (bsContext) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SizedBox(
              height: screenHeight * 0.85,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: ColorConstant.appOrange,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.9,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: screenWidth * 0.1,
                              ),
                              const Text('Transaction History', style: TextStyle(fontSize: 16))
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButtonWidget(
                                imagePath: '',
                                function: () {
                                  Navigator.pop(context);
                                },
                                iconData: Icons.close,
                                isIcon: true,
                                iconSize: 32),
                          ],
                        )
                      ],
                    ),
                  ),
                  //SizedBox(height: screenHeight * 0.005),
                  Expanded(
                    child: ListView.builder(
                      addAutomaticKeepAlives: false,
                      cacheExtent: 10,
                      itemCount: _transactionHistory.length,
                      itemBuilder: (BuildContext context, int index) => TransactionHistoryTile(
                          dateTime: _transactionHistory[index]['dateTime'],
                          transactionAmount: (_transactionHistory[index]['transactionAmount'] * 1.0),
                          transactionType: _transactionHistory[index]['transactionType'],
                          isATrip: _transactionHistory[index]['isATrip'],
                          isCredited: _transactionHistory[index]['isCredited'],
                          method: _transactionHistory[index]['method'],
                          trip: _transactionHistory[index]['trip'],
                          view: () {}),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeArea = MediaQuery.of(context).padding.top;
    final themeData = Theme.of(context);

    // _logger.w(_cardNumberCtrl.text.substring(0, 1));

    return Scaffold(
        backgroundColor: themeData.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: ColorConstant.appOrange,
          foregroundColor: themeData.textTheme.bodyText1!.color,
          title: const Text('Passenger Wallet'),
          centerTitle: true,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(Constants.screenCornerRadius),
              bottomRight: Radius.circular(Constants.screenCornerRadius),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: loaded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.01),
                      Center(
                        child: Text(
                          "WALLET DETAILS",
                          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: screenWidth * 0.04),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: screenWidth * 0.02, top: screenHeight * 0.02),
                        child: Text("Passenger ID : ${_passengerId.toString()}", style: GoogleFonts.roboto(fontWeight: FontWeight.normal, color: Colors.black, fontSize: screenWidth * 0.03)),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: screenWidth * 0.02, top: screenHeight * 0.02),
                        child: Text("Promo Codes", style: GoogleFonts.roboto(fontWeight: FontWeight.normal, color: Colors.black, fontSize: screenWidth * 0.035)),
                      ),
                      DottedLine(16, 16, 4),
                      Container(
                        margin: EdgeInsets.only(top: screenHeight * 0.005),
                        height: screenHeight * 0.3,
                        width: screenWidth,
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                addAutomaticKeepAlives: false,
                                cacheExtent: 10,
                                itemCount: _promoCodeLength,
                                itemBuilder: (BuildContext context, int index) => PromoCodeTile(
                                  promoCode: _promoCode[index]['promocode'],
                                  validStartDate: _promoCode[index]['validStartingDate'],
                                  validEndDate: _promoCode[index]['validEndingDate'],
                                  recordedDate: _promoCode[index]['recordedDate'],
                                  value: _promoCode[index]['value'] * 1.0,
                                  isActive: _promoCode[index]['isActive'],
                                  redeem: (p0, p1) {},
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Container(
                        margin: EdgeInsets.only(left: screenWidth * 0.02, top: screenHeight * 0.02),
                        child: Text("Referrals", style: GoogleFonts.roboto(fontWeight: FontWeight.normal, color: Colors.black, fontSize: screenWidth * 0.035)),
                      ),
                      DottedLine(16, 16, 4),
                      Container(
                        margin: EdgeInsets.only(top: screenHeight * 0.005),
                        height: screenHeight * 0.3,
                        width: screenWidth,
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                addAutomaticKeepAlives: false,
                                cacheExtent: 10,
                                itemCount: _referralLength,
                                itemBuilder: (BuildContext context, int index) => PromoCodeTile(
                                  promoCode: '123456212457',
                                  validStartDate: 'validStartDate',
                                  validEndDate: '2023-06-25',
                                  recordedDate: 'recordedDate',
                                  value: 20,
                                  isActive: true,
                                  redeem: (p0, p1) {},
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Center(
                        child: Text(
                          "TRANSACTIONS DETAILS",
                          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: screenWidth * 0.04),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 16, bottom: 16, top: 12),
                        child: Text(
                          "Merchant Card",
                          style: GoogleFonts.roboto(fontWeight: FontWeight.normal, color: Colors.black, fontSize: screenWidth * 0.035),
                        ),
                      ),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(screenWidth * 0.04),
                          child: Container(
                            height: screenHeight * 0.3,
                            width: screenWidth * 0.85,
                            color: Colors.black26,
                            child: Column(children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.only(right: screenWidth * 0.02, top: screenWidth * 0.02),
                                  child: _cardType == 'VISA'
                                      ? Image.asset(
                                          Assets.paymentsVisaLogo,
                                          fit: BoxFit.scaleDown,
                                          width: screenWidth * 0.15,
                                        )
                                      : _cardType == 'MASTER'
                                          ? Image.asset(
                                              Assets.paymentsMastercardLogo,
                                              fit: BoxFit.scaleDown,
                                              width: screenWidth * 0.09,
                                            )
                                          : _cardType == 'AMEX'
                                              ? Image.asset(
                                                  Assets.paymentsAmexLogo,
                                                  fit: BoxFit.scaleDown,
                                                  width: screenWidth * 0.06,
                                                )
                                              : Image.asset(
                                                  Assets.paymentsMastercardLogo,
                                                  fit: BoxFit.scaleDown,
                                                  width: screenWidth * 0.09,
                                                ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(left: screenWidth * 0.03, top: screenWidth * 0.01),
                                  child: Image.asset(
                                    Assets.paymentsCardChip,
                                    fit: BoxFit.fill,
                                    width: screenWidth * 0.08,
                                  ),
                                ),
                              ),
                              TextFieldWidget(
                                  hintText: 'Card Number',
                                  label: '',
                                  isRequired: false,
                                  txtCtrl: _cardNumberCtrl,
                                  fontSize: 0.03,
                                  secret: false,
                                  heightFactor: 0.05,
                                  widthFactor: 0.8,
                                  inputType: TextInputType.number),
                              SizedBox(height: screenHeight * 0.01),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: screenWidth * 0.02),
                                    child: Row(
                                      children: [
                                        TextFieldWidget(
                                            hintText: 'MM',
                                            label: '',
                                            isRequired: false,
                                            txtCtrl: _cardMonthCtrl,
                                            fontSize: 0.03,
                                            secret: false,
                                            heightFactor: 0.05,
                                            widthFactor: 0.16,
                                            inputType: TextInputType.number),
                                        const Text('/'),
                                        TextFieldWidget(
                                            hintText: 'YY',
                                            label: '',
                                            isRequired: false,
                                            txtCtrl: _cardYearCtrl,
                                            fontSize: 0.03,
                                            secret: false,
                                            heightFactor: 0.05,
                                            widthFactor: 0.16,
                                            inputType: TextInputType.number),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: TextFieldWidget(
                                        hintText: 'CSV',
                                        label: '',
                                        isRequired: false,
                                        txtCtrl: _cardCSVCtrl,
                                        fontSize: 0.03,
                                        secret: false,
                                        heightFactor: 0.05,
                                        widthFactor: 0.16,
                                        inputType: TextInputType.number),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextFieldWidget(
                                          hintText: 'Name On Card',
                                          label: '',
                                          isRequired: false,
                                          txtCtrl: _cardNameCtrl,
                                          fontSize: 0.03,
                                          secret: false,
                                          heightFactor: 0.05,
                                          widthFactor: 0.6,
                                          inputType: TextInputType.number),
                                      GestureDetector(
                                        onTap: () {
                                          _addCard();
                                        },
                                        child: Container(
                                          height: screenWidth * 0.1,
                                          width: screenWidth * 0.1,
                                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.tealAccent.shade400),
                                          child: const Icon(
                                            Icons.save_rounded,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 16, top: 12),
                        child: Text(
                          "Total Wallet Points",
                          style: GoogleFonts.roboto(fontWeight: FontWeight.normal, color: Colors.black, fontSize: screenWidth * 0.035),
                        ),
                      ),
                      Center(
                        child: Text(
                          _totalWalletPoints.toString(),
                          style: GoogleFonts.anton(fontWeight: FontWeight.normal, color: Colors.black, fontSize: screenWidth * 0.06),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 16, top: 12),
                        child: Text(
                          "Bonus Amount",
                          style: GoogleFonts.roboto(fontWeight: FontWeight.normal, color: Colors.black, fontSize: screenWidth * 0.035),
                        ),
                      ),
                      Center(
                        child: Text(
                          _bonusAmount.toString(),
                          style: GoogleFonts.anton(fontWeight: FontWeight.normal, color: Colors.black, fontSize: screenWidth * 0.06),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            _loadAddOrganizationBottomSheet(context, screenHeight, screenWidth, themeData);
                          },
                          child: Container(
                            margin: EdgeInsets.all(screenHeight * 0.02),
                            height: screenWidth * 0.1,
                            width: screenWidth * 0.1,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.cyan.shade400),
                            child: const Icon(
                              Icons.history_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                : loadingDialog(context),
          ),
        ));
  }
}
