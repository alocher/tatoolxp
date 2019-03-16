import 'package:redux/redux.dart';
import 'package:tatoolxp/models/app_state.dart';
import 'package:tatoolxp/actions/actions.dart';


final moduleReducer = combineReducers<AppState>([
  TypedReducer<AppState,StartModule>(_startModule),
  TypedReducer<AppState,ModulesLoaded>(_modulesLoaded),
]);

AppState _startModule(AppState state, StartModule action){
  return state.copyWith();
}

AppState _modulesLoaded(AppState state, ModulesLoaded action){
  return state.copyWith(modules: action.modules);
}



