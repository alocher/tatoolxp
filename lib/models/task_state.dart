import 'package:meta/meta.dart';

@immutable
class TaskState{

  final List<String> trials;
  final int currentTrialIndex;
  final bool trialVisible;

  TaskState({this.trials, this.currentTrialIndex, this.trialVisible});


  TaskState copyWith({
    List<String> trials,
    int currentTrialIndex,
    bool trialVisible
  }){
    return new TaskState(
        trials: trials ?? this.trials,
        currentTrialIndex: currentTrialIndex ?? this.currentTrialIndex,
        trialVisible: trialVisible ?? this.trialVisible
    );
  }

  factory TaskState.initial(){
    return new TaskState(
        trials: <String>['banana', 'pineapple', 'watermelon'],
        currentTrialIndex: 1,
        trialVisible: false);

  }
}