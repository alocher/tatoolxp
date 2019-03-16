import 'package:meta/meta.dart';

@immutable
class Module {
  final String id;
  final String moduleName;
  final String moduleId;
  final String invitationCode;

  Module({this.id, this.moduleName, this.moduleId, this.invitationCode});

  Module.fromMap(Map<String, dynamic> data)
      : this(
          moduleName: data['moduleName'],
          moduleId: data['moduleId'],
          invitationCode: data['invitationCode'] ?? '',
        );

  Map<String, dynamic> toMap() => {
        'moduleName': this.moduleName,
        'moduleId': this.moduleId,
        'invitationCode': this.invitationCode
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
        this.invitationCode;
  }
}
