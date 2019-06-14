import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

@immutable
class Notification {
  final int notificationId;
  final DateTime notificationTime;
  final String notificationMessage;

  Notification(
      {this.notificationId, this.notificationTime, this.notificationMessage});

  Notification.fromMap(Map<String, dynamic> data)
      : this(
          notificationId: data['notificationId'],
          notificationTime: parseTime(data['notificationTime']),
          notificationMessage: data['notificationMessage'],
        );

  Map<String, dynamic> toMap() => {
        'notificationId': this.notificationId,
        'notificationTime': this.notificationTime,
        'notificationMessage': this.notificationMessage,
      };

  static DateTime parseTime(dynamic date) {
    return (date is DateTime) ? date : (date as Timestamp).toDate();
    //return Platform.isIOS ? (date as Timestamp).toDate() : (date as DateTime);
  }

  String toString() {
    return 'notificationId: ' +
        this.notificationId.toString() +
        ', notificationTime: ' +
        this.notificationTime.toString();
    /*', notificationMessage: ' +
        this.notificationMessage.toString();*/
  }
}
