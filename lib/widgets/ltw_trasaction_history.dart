import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionHistoryTile extends StatelessWidget {
  final String dateTime;
  final double transactionAmount;
  final String transactionType;
  final bool isATrip;
  final bool isCredited;
  final String method;
  final dynamic trip;
  final Function view;

  const TransactionHistoryTile({
    Key? key,
    required this.dateTime,
    required this.transactionAmount,
    required this.transactionType,
    required this.isATrip,
    required this.isCredited,
    required this.method,
    required this.trip,
    required this.view,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final themeData = Theme.of(context);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(screenHeight * 0.02)),
          child: Container(
            color: Colors.orangeAccent.shade200,
            width: screenWidth * 0.95,
            height: screenHeight * 0.14,
            padding: EdgeInsets.all(screenHeight * 0.015),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(transactionType.toUpperCase(), style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.red, fontSize: screenHeight * 0.02)),
                      Text(DateFormat('yyyy-MM-ddTHH:mm:ssZ').parse(dateTime, true).toLocal().toString().split('.')[0],
                          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.red, fontSize: screenHeight * 0.02)),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.003),
                  Text('Is Trip : ${isATrip.toString().toUpperCase()}', style: GoogleFonts.roboto(fontWeight: FontWeight.normal, color: Colors.black87, fontSize: screenHeight * 0.02)),
                  SizedBox(height: screenHeight * 0.003),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Trans. Amount (Rs) : $transactionAmount', style: GoogleFonts.roboto(fontWeight: FontWeight.normal, color: Colors.black87, fontSize: screenHeight * 0.02)),
                      Text('Credited : ${isCredited.toString().toUpperCase()}', style: GoogleFonts.roboto(fontWeight: FontWeight.normal, color: Colors.black87, fontSize: screenHeight * 0.02)),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.003),
                  Text('Methode : ${method.toUpperCase()}', style: GoogleFonts.roboto(fontWeight: FontWeight.normal, color: Colors.black87, fontSize: screenHeight * 0.02)),
                  SizedBox(height: screenHeight * 0.003),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.01)
      ],
    );
  }
}
