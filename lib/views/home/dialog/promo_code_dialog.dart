import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/custom_text_style.dart';
import '../../../utils/dotted_line.dart';
import '../../../widgets/ltw_promo_code.dart';

class PromoCodeDialog extends StatefulWidget {
  final Function(String, double) addCode;
  final int promoCodeLength;
  final List<dynamic> promoCode;

  const PromoCodeDialog({super.key, required this.addCode, required this.promoCodeLength, required this.promoCode});

  @override
  _PromoCodeDialogState createState() => _PromoCodeDialogState();
}

class _PromoCodeDialogState extends State<PromoCodeDialog> {
  final TextEditingController _promoCodeTextController = TextEditingController();

  bool isTextWritten = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenHeight * 0.5,
      alignment: Alignment.topCenter,
      child: Card(
        margin: EdgeInsets.all(screenWidth * 0.01),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        elevation: 0,
        child: SizedBox(
          /*decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomRight: Radius.circular(16), bottomLeft: Radius.circular(16)), boxShadow: [
            BoxShadow(color: Colors.grey.shade50, blurRadius: 1, offset: Offset(0, 1)),
          ]),*/
          height: screenHeight * 0.5,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 14, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: screenWidth * 0.02, top: screenHeight * 0.02),
                      child: Text("Promo Codes", style: GoogleFonts.roboto(fontWeight: FontWeight.normal, color: Colors.black, fontSize: screenWidth * 0.035)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              /*Container(
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
                        hintText: "Promo Code",
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
                      controller: _promoCodeTextController,
                      keyboardType: TextInputType.phone,
                    ),
                    createClearText()
                  ],
                ),
              )*/
              DottedLine(16, 16, 4),
              Container(
                margin: EdgeInsets.only(top: screenHeight * 0.005),
                height: screenHeight * 0.3,
                width: screenWidth,
                child: Column(
                  children: [
                    Expanded(
                      child: widget.promoCode.isNotEmpty
                          ? ListView.builder(
                              addAutomaticKeepAlives: false,
                              cacheExtent: 10,
                              itemCount: widget.promoCodeLength,
                              itemBuilder: (BuildContext context, int index) {
                                if (widget.promoCode[index]['isActive'] == true) {
                                  PromoCodeTile(
                                    promoCode: widget.promoCode[index]['promocode'],
                                    validStartDate: widget.promoCode[index]['validStartingDate'],
                                    validEndDate: widget.promoCode[index]['validEndingDate'],
                                    recordedDate: widget.promoCode[index]['recordedDate'],
                                    value: widget.promoCode[index]['value'] * 1.0,
                                    isActive: widget.promoCode[index]['isActive'],
                                    redeem: (promoCode, value) {
                                      widget.addCode(promoCode, value);
                                    },
                                  );
                                }
                                return null;
                              })
                          : Container(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Expanded(
                flex: 100,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16, left: 14, right: 12),
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Selected Code : ",
                        softWrap: true,
                        style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          // widget.addCode(_promoCodeTextController.text);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.tealAccent.shade400),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  createClearText() {
    if (isTextWritten) {
      return Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () {
            _promoCodeTextController.clear();
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

  var border = const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(4)), borderSide: BorderSide(color: Colors.white, width: 1));
}
