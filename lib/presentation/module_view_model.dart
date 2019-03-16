import 'package:redux/redux.dart';
import 'package:tatoolxp/models/app_state.dart';
import 'package:tatoolxp/models/module.dart';
import 'package:tatoolxp/actions/actions.dart';

class ModuleViewModel{

  final List<Module> modules;
  bool loading;
  final Function startModule;
  final Function deleteModule;

  ModuleViewModel({this.modules, this.loading, this.startModule, this.deleteModule});
  
  static ModuleViewModel fromStore(Store<AppState> store){
    return ModuleViewModel(
      modules: store.state.modules,
      loading: store.state.loading,
      startModule: (index){
        store.dispatch(StartModule(index, true));
      },
      deleteModule: (userId, index){
        store.dispatch(DeleteModule(userId, index));
      }
    );
  }
}