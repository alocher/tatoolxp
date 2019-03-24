import 'dart:core';

import 'package:meta/meta.dart';

/*
schedule: {
	scheduleType: 'daily',
	scheduleNumDays: 10,
	scheduleWeekdays: [1,2,3,4,5],
	numNotifications: 2,
	intervalMinutes: 240,
	startTime: 9,
	endTime: 21
}
*/
@immutable
class Schedule {
  final String scheduleType;
  final int scheduleNumDays;
  final List<int> scheduleWeekdays;
  final int numNotifications;
  final int intervalHours;
  final int startTime;
  final int endTime;

  Schedule(
      {this.scheduleType,
      this.scheduleNumDays,
      this.scheduleWeekdays,
      this.numNotifications,
      this.intervalHours,
      this.startTime,
      this.endTime});

  Schedule.fromMap(Map<String, dynamic> data)
      : this(
          scheduleType: data['scheduleType'],
          scheduleNumDays: data['scheduleNumDays'],
          scheduleWeekdays: List<int>.from(data['scheduleWeekdays']),
          numNotifications: data['numNotifications'],
          intervalHours: data['intervalHours'],
          startTime: data['startTime'],
          endTime: data['endTime'],
        );

  Map<String, dynamic> toMap() => {
        'scheduleType': this.scheduleType,
        'scheduleNumDays': this.scheduleNumDays,
        'scheduleWeekdays': this.scheduleWeekdays,
        'numNotifications': this.numNotifications,
        'intervalHours': this.intervalHours,
        'startTime': this.startTime,
        'endTime': this.endTime,
      };

  String toString() {
    return 'scheduleType: ' +
        this.scheduleType +
        ', scheduleNumDays: ' +
        this.scheduleNumDays.toString() +
        ', scheduleWeekdays: ' +
        this.scheduleWeekdays.toString() +
        ', numNotifications: ' +
        this.numNotifications.toString() +
        ', intervalHours: ' +
        this.intervalHours.toString() +
        ', startTime: ' +
        this.startTime.toString() +
        ', endTime: ' +
        this.endTime.toString();
  }
}
