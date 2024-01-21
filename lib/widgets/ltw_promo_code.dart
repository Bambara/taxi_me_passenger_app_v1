import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PromoCodeTile extends StatelessWidget {
  final String promoCode;
  final String validStartDate;
  final String validEndDate;
  final String recordedDate;
  final double value;
  final bool isActive;
  final Function(String, double) redeem;

  const PromoCodeTile({
    Key? key,
    required this.promoCode,
    required this.validStartDate,
    required this.validEndDate,
    required this.recordedDate,
    required this.value,
    required this.isActive,
    required this.redeem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final themeData = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(screenHeight * 0.02)),
              child: Container(
                color: Colors.orangeAccent,
                width: screenWidth * 0.58,
                height: screenHeight * 0.15,
                padding: EdgeInsets.all(screenHeight * 0.01),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DISCOUNT', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.red, fontSize: screenWidth * 0.05)),
                    Text('COUPON', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white, fontSize: screenWidth * 0.05)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('$value% OFF', style: GoogleFonts.bungee(fontWeight: FontWeight.bold, color: Colors.red, fontSize: screenWidth * 0.07)),
                          Text('YOUR NEXT RIDE', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white, fontSize: screenWidth * 0.025)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DottedLine(
              direction: Axis.vertical,
              lineLength: screenHeight * 0.12,
              lineThickness: 2.0,
              dashLength: 3.0,
              dashColor: Colors.orangeAccent,
              dashRadius: 0,
              dashGapLength: 3.0,
              dashGapColor: Colors.white,
              dashGapRadius: 0,
            ),
            GestureDetector(
              onTap: () {
                redeem.call(promoCode, value);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(screenHeight * 0.02)),
                child: Container(
                  color: Colors.orangeAccent,
                  width: screenWidth * 0.32,
                  height: screenHeight * 0.15,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('USE CODE', style: GoogleFonts.roboto(fontWeight: FontWeight.normal, color: Colors.white, fontSize: screenWidth * 0.03)),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(screenHeight * 0.01)),
                        ),
                        margin: EdgeInsets.all(screenWidth * 0.01),
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        child: Text(promoCode, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white, fontSize: screenWidth * 0.035)),
                      ),
                      Text('VALID TILL', style: GoogleFonts.roboto(fontWeight: FontWeight.normal, color: Colors.red, fontSize: screenWidth * 0.03)),
                      Text(validEndDate, style: GoogleFonts.roboto(fontWeight: FontWeight.normal, color: Colors.red, fontSize: screenWidth * 0.03)),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        SizedBox(height: screenHeight * 0.01)
      ],
    );
  }
}
