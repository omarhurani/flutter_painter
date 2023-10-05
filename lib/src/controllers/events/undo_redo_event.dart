import '../actions/actions.dart';

/// Class used in stream, for listening to the undo/redo events, and contains
/// the event identifier [isUndo] and the [action] performed.
class UndoRedoEvent {
  /// The undo event with it's action.
  const UndoRedoEvent.undo(this.action) : isUndo = true;

  /// The redo event with it's action.
  const UndoRedoEvent.redo(this.action) : isUndo = false;

  /// The identifier of the action performed.
  final bool isUndo;

  /// The performed action itself.
  final ControllerAction action;

  @override
  String toString() => 'UndoRedoEvent(isUndo: $isUndo, action: $action)';
}
