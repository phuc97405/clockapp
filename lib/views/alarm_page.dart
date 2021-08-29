import 'package:clockapp/alarm_helper.dart';
import 'package:clockapp/constants/theme_data.dart';
import 'package:clockapp/data.dart';
import 'package:clockapp/model/alarm_info.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class AlarmPage extends StatefulWidget {
  AlarmPage({Key? key}) : super(key: key);

  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  DateTime? _alarmTime;
  String? _alarmTimeString;
  AlarmHelper _alarmHelper = AlarmHelper();
  Future<List<AlarmInfo>>? _alarms;
  List<AlarmInfo>? _currentAlarms;

  @override
  void initState() {
    _alarmTime = DateTime.now();
    _alarmHelper
        .initializeDatabase()
        .then((value) => {print('----------database intialized')});
    loadAlarms();
    super.initState();
  }

  void loadAlarms() {
    _alarms = _alarmHelper.getAlarms();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 64, horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alarm',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Colors.white),
            ),
            Expanded(
              child: FutureBuilder(
                future: _alarms,
                builder: (context, dynamic snapshot) {
                  if (snapshot.hasData) {
                    _currentAlarms = snapshot.data;
                    return ListView(
                      children: snapshot.data!.map<Widget>((alarm) {
                        var alarmTime =
                            DateFormat('hh:mm aa').format(alarm.alarmDateTime!);
                        var gradientColor = GradientTemplate
                            .gradientTemplate[alarm.gradientColorIndex].colors;
                        return Container(
                          margin: EdgeInsets.only(bottom: 32),
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientColor,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(4, 4),
                                    color: gradientColor.last.withOpacity(0.4),
                                    spreadRadius: 2,
                                    blurRadius: 8)
                              ],
                              borderRadius: BorderRadius.circular(24)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.label,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      SizedBox(
                                        width: 16,
                                      ),
                                      Text(
                                        alarm.title!,
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  ),
                                  Switch(
                                    value: true,
                                    onChanged: (bool value) {},
                                    activeColor: Colors.white,
                                  )
                                ],
                              ),
                              Text(
                                'Mon-Fri',
                                style: TextStyle(color: Colors.white),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    alarmTime,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 24),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        deleteAlarm(alarm.id);
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        size: 36,
                                        color: Colors.white,
                                      ))
                                ],
                              ),
                            ],
                          ),
                        );
                      }).followedBy([
                        if (_currentAlarms!.length < 5)
                          DottedBorder(
                            strokeWidth: 3,
                            color: Colors.white30,
                            borderType: BorderType.RRect,
                            radius: Radius.circular(24),
                            dashPattern: [5, 4],
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.black38,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(24))),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 16),
                                ),
                                onPressed: () {
                                  _alarmTimeString = DateFormat('HH:mm')
                                      .format(DateTime.now());
                                  showModalBottomSheet(
                                      useRootNavigator: true,
                                      context: context,
                                      clipBehavior: Clip.antiAlias,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(24))),
                                      builder: (context) {
                                        return StatefulBuilder(
                                            builder: (context, setModalState) {
                                          return Container(
                                            padding: EdgeInsets.all(32),
                                            child: Column(
                                              children: [
                                                TextButton(
                                                    onPressed: () async {
                                                      var selectedTime =
                                                          await showTimePicker(
                                                              context: context,
                                                              initialTime:
                                                                  TimeOfDay
                                                                      .now());
                                                      if (selectedTime !=
                                                          null) {
                                                        final now =
                                                            DateTime.now();

                                                        var selectedDateTime =
                                                            DateTime(
                                                                now.year,
                                                                now.month,
                                                                now.day,
                                                                selectedTime
                                                                    .hour,
                                                                selectedTime
                                                                    .minute);
                                                        _alarmTime =
                                                            selectedDateTime;
                                                        setModalState(() => {
                                                              _alarmTimeString =
                                                                  DateFormat(
                                                                          'HH:mm')
                                                                      .format(
                                                                          selectedDateTime)
                                                            });
                                                      }
                                                    },
                                                    child: Text(
                                                      _alarmTimeString
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 32),
                                                    )),
                                                ListTile(
                                                  title: Text('Repeat'),
                                                  trailing: Icon(
                                                      Icons.arrow_forward_ios),
                                                ),
                                                ListTile(
                                                  title: Text('Sound'),
                                                  trailing: Icon(
                                                      Icons.arrow_forward_ios),
                                                ),
                                                ListTile(
                                                  title: Text('Title'),
                                                  trailing: Icon(
                                                      Icons.arrow_forward_ios),
                                                ),
                                                FloatingActionButton.extended(
                                                    onPressed: onSaveAlarm,
                                                    icon: Icon(Icons.alarm),
                                                    label: Text('Save'))
                                              ],
                                            ),
                                          );
                                        });
                                      });
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/add_alarm.png',
                                      scale: 1.5,
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'Add Alarm',
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          Center(
                              child: Text(
                            'Only 5 alarm allowed!',
                            style: TextStyle(color: Colors.white),
                          ))
                      ]).toList(),
                    );
                  }
                  return Center(
                    child: Text(
                      'Loading...',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            )
          ],
        ));
  }

  void scheduleAlarm(
      DateTime scheduleAlarmDateTime, AlarmInfo alarmInfo) async {
    // var scheduledNotificationDateTime =
    //     DateTime.now().add(Duration(seconds: 10));

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_notif',
      'alarm_notif',
      'Channel for Alarm notification',
      icon: 'logo',
      sound: RawResourceAndroidNotificationSound('ios_a_long_cold_sting'),
      largeIcon: DrawableResourceAndroidBitmap('logo'),
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        sound: 'ios_a_long_cold_sting.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true);

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(0, 'Office', alarmInfo.title,
        scheduleAlarmDateTime, platformChannelSpecifics);
  }

  void onSaveAlarm() {
    DateTime scheduleAlarmDateTime;
    if (_alarmTime!.isAfter(DateTime.now()))
      scheduleAlarmDateTime = _alarmTime!;
    else
      scheduleAlarmDateTime = _alarmTime!.add(Duration(days: 1));
    var alarmInfo = AlarmInfo(
        alarmDateTime: scheduleAlarmDateTime,
        gradientColorIndex: _currentAlarms!.length,
        title: 'alarm');

    _alarmHelper.insertAlarm(alarmInfo);
    scheduleAlarm(scheduleAlarmDateTime, alarmInfo); //setup alarm
    Navigator.pop(context);
    loadAlarms(); //get lai list alarm
  }

  void deleteAlarm(int id) {
    _alarmHelper.delete(id);
    loadAlarms();
  }
}
