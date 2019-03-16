import 'package:meta/meta.dart';
import 'package:tatoolxp/models/module.dart';

@immutable
class ModuleList {
  final List<Module> modules;

  ModuleList({this.modules});

  ModuleList.fromJson(List<Module> json)
      : modules = new List<Module>.from(json);

  factory ModuleList.initial(){
    return new ModuleList();

  }

  
}