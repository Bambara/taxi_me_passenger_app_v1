// import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../views/styles.dart';

class CustomDateTimePicker extends StatelessWidget {
  String Function(dynamic) dateValidator;
  TextEditingController dateController;
  ValueSetter<DateTime> newDate;
  String dateLabelText;
  String dateHint;
  String Function(dynamic) timeValidator;
  TextEditingController timeController;
  ValueSetter<DateTime> newTime;
  String timeLabelText;
  String timeHint;
  bool obscureText;

  CustomDateTimePicker({
    required this.dateValidator,
    required this.dateController,
    required this.newDate,
    required this.dateLabelText,
    required this.dateHint,
    required this.timeValidator,
    required this.timeController,
    required this.newTime,
    required this.timeLabelText,
    required this.timeHint,
    this.obscureText = false,
  });

  static InputBorder enabledBorder =
      OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5.0)), borderSide: BorderSide(color: Colors.black, width: 0.5)); //for some reason can't give through variable

  static InputBorder errorBorder = OutlineInputBorder(borderSide: BorderSide(color: Colors.red));

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Column(children: [
      Container(
        width: width - 40,
        height: 50,
        child: DateTimeField(
          format: DateFormat('yyyy-MM-dd'),
          controller: dateController,
          onChanged: (date) {
            newDate(date!);
          },
          onShowPicker: (context, currentValue) {
            return showDatePicker(
              context: context,
              firstDate: DateTime.now(),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    primaryColor: Color(0xFFFF9000),
                    accentColor: Color(0xFFFF9000),
                    colorScheme: ColorScheme.light(primary: const Color(0xFFFF9000)),
                    buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
                  ),
                  child: child!,
                );
              },
            );
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
            filled: true,
            fillColor: Colors.white,
            hintText: dateHint,
            hintStyle: greyNormalTextStyle,
            labelText: dateLabelText,
            labelStyle: greyNormalTextStyle,
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
            errorBorder: errorBorder,
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5.0)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
            focusedErrorBorder: errorBorder,
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5.0)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
          ),
        ),
      ),
      Container(
        width: width - 40,
        height: 50,
        margin: EdgeInsets.only(top: 20),
        child: DateTimeField(
          format: DateFormat('HH:mm'),
          controller: timeController,
          onChanged: (time) {
            newTime(time!);
          },
          onShowPicker: (context, currentValue) async {
            final TimeOfDay? time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    primaryColor: Color(0xFFFF9000),
                    accentColor: Color(0xFFFF9000),
                    colorScheme: ColorScheme.light(primary: const Color(0xFFFF9000)),
                    buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
                  ),
                  child: child!,
                );
              },
            );
            return time == null ? null : DateTimeField.convert(time);
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
            filled: true,
            fillColor: Colors.white,
            hintText: timeHint,
            hintStyle: greyNormalTextStyle,
            labelText: timeLabelText,
            labelStyle: greyNormalTextStyle,
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
            errorBorder: errorBorder,
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5.0)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
            focusedErrorBorder: errorBorder,
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5.0)), borderSide: BorderSide(color: Colors.black26, width: 1.0)),
          ),
        ),
      )
    ]);
  }
}
