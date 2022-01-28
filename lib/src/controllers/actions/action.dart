import 'package:flutter/foundation.dart';

import '../painter_controller.dart';
import 'grouped_action.dart';

/// An action that can be performed in [PainterController] which can be
/// performed and un-performed.
///
/// [T] is the return type of the [perform] method.
/// [E] is the return type of the [unperform] method.
abstract class ControllerAction<T, E> {
  /// Default constructor for [ControllerAction].
  ControllerAction() : _performed = false;

  /// Whether the action was performed or not.
  ///
  /// This value is checked before performing or un-performing an action,
  /// and is automatically updated when doing so (calling [perform] and [unperform].
  bool _performed;

  /// Performs the action by calling [perform$] after checking if the action has
  /// already been performed. If so, throws an [AlreadyPerformedError].
  ///
  /// Returns any extra results from performing the action.
  T perform(PainterController controller) {
    if (_performed) throw AlreadyPerformedError();
    final value = perform$(controller);
    _performed = true;
    return value;
  }

  /// Un-performs the action by calling [unperform$] after checking if the action has
  /// not been performed. If so, throws an [NotPerformedError].
  ///
  /// Returns any extra results from performing the action.
  E unperform(PainterController controller) {
    if (!_performed) throw NotPerformedError();
    final value = unperform$(controller);
    _performed = false;
    return value;
  }

  /// Performs the action.
  ///
  /// Inheriting classes must implement its behavior to perform the action as needed.
  ///
  /// Returns any extra results from performing the action.
  @protected
  T perform$(PainterController controller);

  /// Unperforms the action.
  ///
  /// Inheriting classes must implement its behavior to un-perform the action as needed.
  /// After un-performing the action, [controller.value] should be the same as it was
  /// before the action was performed.
  ///
  /// Returns any extra results from performing the action.
  @protected
  E unperform$(PainterController controller);

  /// Merges [this] action and the [previousAction] into one action by calling [merge$].
  /// Returns the result of the merge.
  ///
  /// Both [this] and [previousAction] must be performed before merging.
  /// If not, throws a [NotPerformedError].
  ControllerAction? merge(ControllerAction previousAction) {
    if (!_performed || !previousAction._performed) throw NotPerformedError();
    return merge$(previousAction)?.._performed = true;
  }

  /// Merges [this] action and the [previousAction] into one action.
  /// Returns the result of the merge.
  ///
  /// Inheriting classes can override its behavior to merge the two actions appropriately.
  /// If the result is `null`, that means that both actions cancel each other after being merged.
  ///
  /// By default, it creates a [GroupedAction] from the two actions.
  @protected
  ControllerAction? merge$(ControllerAction previousAction) {
    return GroupedAction.from(previousAction, this);
  }
}

/// An error that might occur while performing or un-performing [ControllerAction]s.
abstract class ControllerActionError extends Error {
  /// The message of the error.
  String? message;

  /// Creates a [ControllerActionError] with an optional [message].
  ControllerActionError([this.message]);

  @override
  String toString() {
    if (message == null) return super.toString();
    return "ControllerActionException${': $message'}";
  }
}

/// An error that occurs when [ControllerAction.perform] is called on an action that
/// has already been performed ([ControllerAction._performed] is `true`).
class AlreadyPerformedError extends ControllerActionError {
  /// Creates a [AlreadyPerformedError].
  AlreadyPerformedError()
      : super(
            "This action cannot be performed or merged because it already has been performed.");
}

/// An error that occurs when [ControllerAction.unperform] is called on an action that
/// has not been performed ([ControllerAction._performed] is `false`).
class NotPerformedError extends ControllerActionError {
  /// Creates a [NotPerformedError].
  NotPerformedError()
      : super(
            "This action cannot be un-performed because it wasn't performed.");
}
