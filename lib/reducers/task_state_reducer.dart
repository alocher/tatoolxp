import 'package:redux/redux.dart';
import 'package:tatoolxp/models/task_state.dart';
import 'package:tatoolxp/actions/actions.dart';


final taskReducer = combineReducers<TaskState>([
  TypedReducer<TaskState,CreateTrialAction>(_createTrial),
  TypedReducer<TaskState,ShowTrialAction>(_showTrial),
  TypedReducer<TaskState,ShowTrialAction>(_hideTrial)
]);

TaskState _createTrial(TaskState state, CreateTrialAction action){
  return state.copyWith(currentTrialIndex: state.currentTrialIndex + 1);
}

TaskState _showTrial(TaskState state, ShowTrialAction action){
  return state.copyWith(trialVisible: true);
}

TaskState _hideTrial(TaskState state, ShowTrialAction action){
  return state.copyWith(trialVisible: false);
}