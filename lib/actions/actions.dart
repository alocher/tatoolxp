enum Actions { ShowWaitIndicator, HideWaitIndicator }

class CreateTrialAction {}

class ShowTrialAction {}

class LoadModules {
  final String userId;
  LoadModules(this.userId);
}

class ModulesLoaded {
  final List<dynamic> modules;
  ModulesLoaded(this.modules);
}

class DeleteModule {
  final String userId;
  final int index;
  DeleteModule(this.userId, this.index);
}

class AddModule {
  final String userId;
  final String invitationCode;
  AddModule(this.userId, this.invitationCode);
}

class StartModule {
  final int index;
  final bool loading;
  StartModule(this.index, this.loading);
}
