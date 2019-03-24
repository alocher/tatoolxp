import 'package:meta/meta.dart';
import 'package:tatoolxp/models/schedule.dart';
import 'package:tatoolxp/models/notification.dart';

@immutable
class Module {
  final String id;
  final String moduleName;
  final String moduleId;
  final String invitationCode;
  final Schedule schedule;
  final List<Notification> notifications;

  Module(
      {this.id,
      this.moduleName,
      this.moduleId,
      this.invitationCode,
      this.schedule,
      this.notifications});

  Module.fromMap(Map<String, dynamic> data)
      : this(
          moduleName: data['moduleName'],
          moduleId: data['moduleId'],
          invitationCode: data['invitationCode'] ?? '',
          schedule:
              Schedule.fromMap(Map<String, dynamic>.from(data['schedule'])) ??
                  null,
          notifications: (data['notifications']) != null
              ? List<Notification>.from(data['notifications'].map((note) =>
                  Notification.fromMap(Map<String, dynamic>.from(note))))
              : <Notification>[],
        );

  Map<String, dynamic> toMap() => {
        'moduleName': this.moduleName,
        'moduleId': this.moduleId,
        'invitationCode': this.invitationCode,
        'schedule': this.schedule.toMap(),
        'notifications':
            this.notifications.map((note) => note.toMap()).toList(),
      };

  factory Module.initial() {
    return null;
  }

  String toString() {
    return 'ModuleName: ' +
        this.moduleName +
        ', moduleId: ' +
        this.moduleId +
        ', invitationCode: ' +
        this.invitationCode +
        ', schedule: ' +
        this.schedule.toString() +
        ', notifications: ' +
        this.notifications.toString();
  }
}
