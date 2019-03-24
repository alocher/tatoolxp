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
          notificationTime: data['notificationTime'],
          notificationMessage: data['notificationMessage'],
        );

  Map<String, dynamic> toMap() => {
        'notificationId': this.notificationId,
        'notificationTime': this.notificationTime,
        'notificationMessage': this.notificationMessage,
      };

  String toString() {
    return 'notificationId: ' +
        this.notificationId.toString() +
        ', notificationTime: ' +
        this.notificationTime.toString();
        /*', notificationMessage: ' +
        this.notificationMessage.toString();*/
  }
}
