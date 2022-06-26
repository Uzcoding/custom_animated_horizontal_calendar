import 'package:animated_horizontal_calendar/utils/calender_utils.dart';
import 'package:animated_horizontal_calendar/utils/color.dart';
import 'package:flutter/material.dart';

typedef OnDateSelected(date);

class AnimatedHorizontalCalendar extends StatefulWidget {
  final DateTime date;
  final DateTime? initialDate;
  final DateTime? lastDate;
  final Color? textColor;
  final Color? colorOfWeek;
  final Color? colorOfMonth;
  final double? fontSizeOfWeek;
  final FontWeight? fontWeightWeek;
  final double? fontSizeOfMonth;
  final FontWeight? fontWeightMonth;
  final Color? backgroundColor;
  final Color? selectedColor;
  final int? duration;
  final Curve? curve;
  final BoxShadow? selectedBoxShadow;
  final BoxShadow? unSelectedBoxShadow;
  final OnDateSelected? onDateSelected;
  final Widget tableCalenderIcon;
  final Color? tableCalenderButtonColor;
  final ThemeData? tableCalenderThemeData;

  AnimatedHorizontalCalendar({
    Key? key,
    required this.date,
    required this.tableCalenderIcon,
    this.initialDate,
    this.lastDate,
    this.textColor,
    this.curve,
    this.tableCalenderThemeData,
    this.selectedBoxShadow,
    this.unSelectedBoxShadow,
    this.duration,
    this.tableCalenderButtonColor,
    this.colorOfMonth,
    this.colorOfWeek,
    this.fontSizeOfWeek,
    this.fontWeightWeek,
    this.fontSizeOfMonth,
    this.fontWeightMonth,
    this.backgroundColor,
    this.selectedColor,
    @required this.onDateSelected,
  }) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<AnimatedHorizontalCalendar> {
  DateTime? _startDate;
  var selectedCalenderDate;
  ScrollController _scrollController = new ScrollController();

  calenderAnimation() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: widget.duration ?? 1),
      curve: widget.curve ?? Curves.fastOutSlowIn,
    );
  }

  @override
  void initState() {
    super.initState();
    selectedCalenderDate = widget.date;
  }

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;

    DateTime findFirstDateOfTheWeek(DateTime dateTime) {
      if (dateTime.weekday == 7) {
        if (_scrollController.hasClients) {
          calenderAnimation();
        }
        return dateTime;
      } else {
        if (dateTime.weekday == 1 || dateTime.weekday == 2) {
          if (_scrollController.hasClients) {
            calenderAnimation();
          }
        }
        return dateTime.subtract(Duration(days: dateTime.weekday));
      }
    }

    _startDate = findFirstDateOfTheWeek(selectedCalenderDate);

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Container(
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            ListView.builder(
              itemCount: 7,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                DateTime? _date = _startDate?.add(Duration(days: index));
                int? diffDays = _date?.difference(selectedCalenderDate).inDays;
                return Container(
                  padding: EdgeInsets.only(bottom: 20, left: 0.0),
                  child: Container(
                    width: 47,
                    height: 59.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          offset: diffDays == 0
                              ? const Offset(0, 0)
                              : const Offset(0, 4),
                          blurRadius: diffDays == 0 ? 26.0 : 6.0,
                          color: diffDays == 0
                              ? const Color(0xFF5493EE).withOpacity(.26)
                              : Colors.black.withOpacity(.05),
                        ),
                      ],
                      gradient: diffDays == 0
                          ? LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: [
                                Color(0xFF6BAEFA),
                                Color(0xFF144ACE),
                              ],
                            )
                          : null,
                      color: diffDays == 0 ? null : Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    margin: EdgeInsets.only(left: 8, right: 8, top: 8),
                    // ignore: deprecated_member_use
                    child: FlatButton(
                      padding: EdgeInsets.symmetric(horizontal: 2.0),
                      onPressed: () {
                        widget.onDateSelected!(Utils.getDate(_date!));
                        setState(() {
                          selectedCalenderDate =
                              _startDate?.add(Duration(days: index));
                          _startDate = _startDate?.add(Duration(days: index));
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            Utils.getDayOfWeek(_date!),
                            style: TextStyle(
                                color: diffDays == 0
                                    ? Colors.white
                                    : Color(0xFF737482),
                                fontSize: widget.fontSizeOfWeek ?? 11.0,
                                fontWeight:
                                    widget.fontWeightWeek ?? FontWeight.w600),
                          ),
                          SizedBox(height: 2.0),
                          Text(
                            Utils.getDayOfMonth(_date),
                            style: TextStyle(
                              color:
                                  diffDays == 0 ? Colors.white : Colors.black,
                              fontSize: widget.fontSizeOfMonth ?? 15.0,
                              fontWeight:
                                  widget.fontWeightMonth ?? FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              width: 10,
            ),
            Container(
              padding: EdgeInsets.only(bottom: 20, top: 8),
              color: Colors.white,
              child: InkWell(
                onTap: () async {
                  DateTime? date = await selectDate();
                  widget.onDateSelected!(Utils.getDate(date!));
                  setState(() => selectedCalenderDate = date);
                },
                child: Container(
                  width: 47,
                  height: 59.0,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 4),
                        blurRadius: 6.0,
                        color: Colors.black.withOpacity(.05),
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: widget.tableCalenderIcon,
                ),
              ),
            ),
            SizedBox(
              width: 15,
            )
          ],
        ),
      ),
    );
  }

  Future<DateTime?> selectDate() async {
    return await showDatePicker(
      context: context,
      initialDatePickerMode: DatePickerMode.day,
      initialDate: selectedCalenderDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: widget.tableCalenderThemeData ??
              ThemeData.light().copyWith(
                primaryColor: secondaryColor,
                buttonTheme:
                    ButtonThemeData(textTheme: ButtonTextTheme.primary),
                colorScheme: ColorScheme.light(primary: secondaryColor)
                    .copyWith(secondary: secondaryColor),
              ),
          child: child ?? SizedBox(),
        );
      },
      firstDate:
          widget.initialDate ?? DateTime.now().subtract(Duration(days: 30)),
      lastDate: widget.lastDate ?? DateTime.now().add(Duration(days: 30)),
    );
  }
}
