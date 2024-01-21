import 'package:flutter/material.dart';

import '../utils/custom_text_style.dart';

class FloatingAddressCard extends StatelessWidget {
  String passengerPickupData;
  String passengerDropData;

  FloatingAddressCard({required this.passengerPickupData, required this.passengerDropData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: 10,
                margin: EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                height: 10,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 16),
                  child: Text(
                    passengerPickupData,
                    style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey.shade800),
                  ),
                ),
                flex: 100,
              ),
              IconButton(
                  icon: Icon(
                    Icons.favorite_border,
                    color: Colors.grey,
                    size: 18,
                  ),
                  onPressed: () {})
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: 10,
                margin: EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                height: 10,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  margin: EdgeInsets.only(left: 16),
                  child: Text(
                    passengerDropData,
                    style: CustomTextStyle.regularTextStyle.copyWith(color: Colors.grey.shade800),
                  ),
                ),
                flex: 100,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
