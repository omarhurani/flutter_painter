import 'package:flutter/foundation.dart';
import 'package:flutter_painter/src/controllers/action/actions.dart';

import '../painter_controller.dart';

abstract class ControllerAction<T, E>{

  ControllerAction(): performed = false;

  @protected
  bool performed;

  T perform(PainterController controller){
    if(performed)
      throw AlreadyPerformedError();
    final value = perform$(controller);
    performed = true;
    return value;
  }

  E unperform(PainterController controller){
    if(!performed)
      throw NotPerformedError();
    final value = unperform$(controller);
    performed = false;
    return value;
  }

  @protected
  T perform$(PainterController controller);

  @protected
  E unperform$(PainterController controller);

  ControllerAction? merge(ControllerAction previousAction){
    if(!performed)
      throw NotPerformedError();
    return merge$(previousAction)?..performed = true;
  }

  @protected
  ControllerAction? merge$(ControllerAction previousAction){
    return GroupedAction.from(previousAction, this);
  }


}

class ControllerActionError extends Error{

  String? message;

  ControllerActionError([this.message]);

  @override
  String toString() {
    if(message == null)
      return super.toString();
    return "ControllerActionException${': $message'}";
  }
}

class AlreadyPerformedError extends ControllerActionError{
  AlreadyPerformedError(): super("This action cannot be performed or merged because it already has been performed.");
}

class NotPerformedError extends ControllerActionError{
  NotPerformedError(): super("This action cannot be un-performed because it wasn't performed.");
}

