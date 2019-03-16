import 'package:meta/meta.dart';
import 'package:tatoolxp/models/module.dart';
import 'package:tatoolxp/models/task_state.dart';

@immutable
class AppState{

  final TaskState taskState;
  final List<Module> modules;
  final bool loading;

  AppState({
    @required this.modules,
    @required this.taskState,
    @required this.loading
  });

  factory AppState.initial(){
    return AppState(
      modules: <Module>[],
      taskState: TaskState.initial(),
      loading: false
    );
  }

  AppState copyWith({
    List<Module> modules,
    TaskState taskState,
    bool loading
  }){
    return AppState(
      modules: modules ?? this.modules,
      taskState: taskState ?? this.taskState,
      loading: loading ?? this.loading
    );
  }
}