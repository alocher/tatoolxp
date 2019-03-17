import 'package:meta/meta.dart';

@immutable
class TatoolUser{
  final String userId;
  final String email;
  final String displayName;
  final String tatoolId;

  TatoolUser({this.userId, this.email, this.displayName, this.tatoolId});
}