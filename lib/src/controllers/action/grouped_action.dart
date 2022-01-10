import 'package:flutter/foundation.dart';
import 'package:flutter_painter/src/controllers/painter_controller.dart';

import 'action.dart';

class GroupedAction extends ControllerAction<void, void>{

  late final List<ControllerAction> actions;

  GroupedAction(this.actions);

  GroupedAction.from(ControllerAction action1, ControllerAction action2){
    if(action1 is! GroupedAction && action2 is! GroupedAction){
      actions = [action1, action2];
      return;
    }

    final List<ControllerAction> previousActions, currentActions;
    final ControllerAction? previousAction, currentAction;
    if(action1 is GroupedAction){
      if(action1.actions.isEmpty){
        previousActions = [];
        previousAction = null;
      }
      else{
        previousActions = action1.actions.sublist(0, action1.actions.length-1);
        previousAction = action1.actions.last;
      }
    }
    else{
      previousActions = [];
      previousAction = action1;
    }

    if(action2 is GroupedAction){
      if(action2.actions.isEmpty){
        currentActions = [];
        currentAction = null;
      }
      else{
        currentActions = action2.actions.sublist(1);
        currentAction = action2.actions.first;
      }
    }
    else{
      currentActions = [];
      currentAction = action2;
    }

    final ControllerAction? merged;
    if(previousAction != null && currentAction != null)
      merged = currentAction.merge(previousAction);
    else if(previousAction != null)
      merged = previousAction;
    else if(currentAction != null)
      merged = currentAction;
    else
      merged = null;

    actions = [
      ...previousActions,
      if(merged != null)
        if(merged is GroupedAction)
          ...merged.actions
        else
          merged,
      ...currentActions
    ];
  }

  @protected
  @override
  void perform$(PainterController controller) {
    for(final action in actions)
      action.perform(controller);
  }

  @protected
  @override
  void unperform$(PainterController controller) {
    for(final action in actions.reversed)
      action.unperform(controller);
  }

  @protected
  @override
  ControllerAction? merge$(ControllerAction previousAction){
    if(actions.isEmpty)
      return previousAction;
    final toMerge;
    final beforeMerge;
    if(previousAction is GroupedAction){
      final previousActions = previousAction.actions;
      if(previousActions.isEmpty)
        return this;
      beforeMerge = [...previousActions].removeLast();
      toMerge = previousActions.last;
    }
    else {
      beforeMerge = [];
      toMerge = previousAction;
    }
    final merged = actions.first.merge(toMerge);
    return GroupedAction([
      ...beforeMerge,
      if(merged is GroupedAction)
        ...merged.actions
      else if(merged != null)
        merged,
      ...actions.sublist(1)
    ]);


    // return super.merge$(previousAction);
  }

  @override
  String toString() {
    return "${super.toString()}: [${actions.map((e) => e.toString()).fold('', (previousValue, element) => '$previousValue, $element')}]";
  }
}