part of 'flutter_painter.dart';

/// Flutter widget to detect user input and request drawing [FreeStyleDrawable]s.
class _TextWidget extends StatefulWidget {
  /// Child widget.
  final Widget child;

  /// Creates a [_TextWidget] with the given [controller] and [child] widget.
  const _TextWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _TextWidgetState createState() => _TextWidgetState();
}

class _TextWidgetState extends State<_TextWidget> {
  /// The currently selected text drawable that is being edited.
  TextDrawable? selectedDrawable;

  /// Subscription to the events coming from the controller.
  ///
  /// This is used to listen to new text events to create new text drawables.
  StreamSubscription<PainterEvent>? controllerEventSubscription;

  @override
  void initState() {
    super.initState();

    // Listen to the stream of events from the paint controller
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      controllerEventSubscription =
          PainterController.of(context).events.listen((event) {
        // When an [AddTextPainterEvent] event is received, create a new text drawable
        if (event is AddTextPainterEvent) createDrawable();
      });
    });
  }

  @override
  void dispose() {
    // Cancel subscription to events from painter controller
    controllerEventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ObjectDrawableReselectedNotification>(
      onNotification: onObjectDrawableNotification,
      child: widget.child,
    );
  }

  /// Getter for [TextSettings] from `widget.controller.value` to make code more readable.
  TextSettings get settings =>
      PainterController.of(context).value.settings.text;

  /// Handles any [ObjectDrawableReselectedNotification] that might be dispatched in the widget tree.
  ///
  /// This handles notifications of type [ObjectDrawableReselectedNotification] to edit
  /// an existing [TextDrawable].
  bool onObjectDrawableNotification(
      ObjectDrawableReselectedNotification notification) {
    final drawable = notification.drawable;

    if (drawable is TextDrawable) {
      openTextEditor(drawable);
      // Mark notification as handled
      return true;
    }
    // Mark notification as not handled
    return false;
  }

  /// Creates a new [TextDrawable], adds it to the controller and opens the editing widget.
  void createDrawable() {
    if (selectedDrawable != null) return;

    // Calculate the center of the painter
    final renderBox = PainterController.of(context)
        .painterKey
        .currentContext
        ?.findRenderObject() as RenderBox?;
    final center = renderBox == null
        ? Offset.zero
        : Offset(
            renderBox.size.width / 2,
            renderBox.size.height / 2,
          );

    // Create a new hidden empty entry in the center of the painter
    final drawable = TextDrawable(
      text: '',
      position: center,
      style: settings.textStyle,
      hidden: true,
    );
    PainterController.of(context).addDrawables([drawable]);

    if (mounted) {
      setState(() {
        selectedDrawable = drawable;
      });
    }

    openTextEditor(drawable, true).then((value) {
      if (mounted) {
        setState(() {
          selectedDrawable = null;
        });
      }
    });
  }

  /// Opens an editor to edit the text of [drawable].
  Future<void> openTextEditor(TextDrawable drawable,
      [bool isNew = false]) async {
    await Navigator.push(
        context,
        PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) =>
                EditTextWidget(
                  controller: PainterController.of(context),
                  drawable: drawable,
                  isNew: isNew,
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(
                      opacity: animation,
                      child: child,
                    )));
  }
}

/// A dialog-like widget to edit text drawables in.
class EditTextWidget extends StatefulWidget {
  /// The controller for the current [FlutterPainter].
  final PainterController controller;

  /// The text drawable currently being edited.
  final TextDrawable drawable;

  /// If the text drawable being edited is new or not.
  /// If it is new, the update action is not marked as a new action, so it is merged with
  /// the previous action.
  final bool isNew;

  const EditTextWidget({
    Key? key,
    required this.controller,
    required this.drawable,
    this.isNew = false,
  }) : super(key: key);

  @override
  EditTextWidgetState createState() => EditTextWidgetState();
}

class EditTextWidgetState extends State<EditTextWidget>
    with WidgetsBindingObserver {
  /// Text editing controller for the [TextField].
  TextEditingController textEditingController = TextEditingController();

  /// The focus node of the [TextField].
  ///
  /// The node provided from the [TextSettings] will be used if provided
  /// Otherwise, it will be initialized to an inner [FocusNode].
  late FocusNode textFieldNode;

  /// The current bottom view insets (the keyboard size on mobile).
  ///
  /// This is used to detect when the keyboard starts closing.
  double bottomViewInsets = 0;

  /// Getter for [TextSettings] from `widget.controller.value` to make code more readable.
  TextSettings get settings => widget.controller.value.settings.text;

  bool disposed = false;

  @override
  void initState() {
    super.initState();

    // Initialize the focus node
    textFieldNode = settings.focusNode ?? FocusNode();
    textFieldNode.addListener(focusListener);

    // Requests focus for the focus node after the first frame is rendered
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      textFieldNode.requestFocus();
    });

    // Initialize the text in the [TextField] to the drawable text
    textEditingController.text = widget.drawable.text;

    // Add this object as an observer for widget bindings
    //
    // This is used to check the bottom view insets (the keyboard size on mobile)
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    // Remove this object from being an observer
    WidgetsBinding.instance?.removeObserver(this);

    // Stop listening to the focus node
    textFieldNode.removeListener(focusListener);

    // If the focus node was an inner node (not from [TextSettings]), dispose of it
    if (settings.focusNode == null) textFieldNode.dispose();

    // Dispose of the text editing controller
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen height, keyboard height, widget height and position
    //
    // This is used to add padding to the text editing widget so that the keyboard
    // doesn't block it
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final renderBox = widget.controller.painterKey.currentContext
        ?.findRenderObject() as RenderBox?;
    final y = renderBox?.localToGlobal(Offset.zero).dy ?? 0;
    final height = renderBox?.size.height ?? screenHeight;

    return GestureDetector(
      // If the border is tapped, un-focus the text field
      onTap: () => textFieldNode.unfocus(),
      child: Container(
        color: Colors.black38,
        child: Padding(
          padding: EdgeInsets.only(
              bottom: (keyboardHeight - (screenHeight - height - y))
                  .clamp(0, screenHeight)),
          child: Center(
            child: TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              cursorColor: Colors.white,
              buildCounter: buildEmptyCounter,
              maxLength: 1000,
              minLines: 1,
              maxLines: 10,
              controller: textEditingController,
              focusNode: textFieldNode,
              style: settings.textStyle,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              onEditingComplete: onEditingComplete,
            ),
          ),
        ),
      ),
    );
  }

  /// Listener to metrics.
  ///
  /// Used to check bottom insets and lose focus of the focus node if the
  /// mobile keyboard starts closing.
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final value = WidgetsBinding.instance?.window.viewInsets.bottom;

    // If the previous value of bottom view insets is larger than the current value,
    // the keyboard is closing, so lose focus from the focus node
    if ((value ?? bottomViewInsets) < bottomViewInsets &&
        textFieldNode.hasFocus) {
      textFieldNode.unfocus();
    }

    // Update the bottom view insets for next check
    bottomViewInsets = value ?? 0;
  }

  /// Listener to focus events for [textFieldNode]
  void focusListener() {
    if (!mounted) return;
    if (!textFieldNode.hasFocus) {
      onEditingComplete();
    }
  }

  /// Saves the changes to the [widget.drawable] text and closes the editor.
  ///
  /// If the text is empty, it will remove the drawable from the controller.
  void onEditingComplete() {
    if (textEditingController.text.trim().isEmpty) {
      widget.controller.removeDrawable(widget.drawable);
      if (!widget.isNew) {
        DrawableDeletedNotification(widget.drawable).dispatch(context);
      }
    } else {
      final drawable = widget.drawable.copyWith(
        text: textEditingController.text.trim(),
        style: settings.textStyle,
        hidden: false,
      );
      updateDrawable(widget.drawable, drawable);
      if (widget.isNew) DrawableCreatedNotification(drawable).dispatch(context);
    }
    if (mounted && !disposed) {
      setState(() {
        disposed = true;
      });

      Navigator.pop(context);
    }
  }

  /// Updates the drawable in the painter controller.
  void updateDrawable(TextDrawable oldDrawable, TextDrawable newDrawable) {
    widget.controller
        .replaceDrawable(oldDrawable, newDrawable, newAction: !widget.isNew);
  }

  /// Builds a null widget for the [TextField] counter.
  ///
  /// By default, [TextField] shows a character counter if the maxLength attribute
  /// is used. This is to override the counter and display nothing.
  Widget? buildEmptyCounter(BuildContext context,
          {required int currentLength,
          int? maxLength,
          required bool isFocused}) =>
      null;
}
