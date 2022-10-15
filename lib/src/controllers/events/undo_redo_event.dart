import '../actions/actions.dart';

class UndoRedoEvent {
  const UndoRedoEvent.undo(this.action) : isUndo = true;
  const UndoRedoEvent.redo(this.action) : isUndo = false;

  final bool isUndo;
  final ControllerAction action;

  @override
  String toString() => 'UndoRedoEvent(isUndo: $isUndo, action: $action)';
}
