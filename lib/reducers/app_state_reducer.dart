import 'package:tatoolxp/models/models.dart';
import 'package:tatoolxp/reducers/task_state_reducer.dart';
import 'package:tatoolxp/reducers/module_state_reducer.dart';
import 'package:tatoolxp/actions/actions.dart';

// We create the State reducer by combining many smaller reducers into one!
AppState appReducer(AppState state, action) {
  return AppState(
    loading: _loading(state, action),
    taskState: taskReducer(state.taskState, action),
    modules: moduleReducer(state, action).modules
  );
}

bool _loading(AppState state, dynamic action){
  if (action is StartModule) {
    return action.loading;
  } else if (action == Actions.ShowWaitIndicator) {
    return true;
  } else if (action == Actions.HideWaitIndicator) {
    return false;
  } else if (action is ModulesLoaded) {
    return false;
  } else {
    return state.loading;
  }
}