part of 'flutter_painter.dart';

/// Flutter widget to move, scale and rotate [ObjectDrawable]s.
class ObjectWidget extends StatefulWidget {

  /// The controller for the current [FlutterPainter].
  final PainterController controller;

  /// Child widget.
  final Widget child;

  /// Whether scaling is enabled or not.
  ///
  /// If `false`, objects won't be movable, scalable or rotatable.
  final bool interactionEnabled;

  /// Creates a [ObjectWidget] with the given [controller], [child] widget..
  const ObjectWidget({
    Key? key,
    required this.controller,
    required this.child,
    this.interactionEnabled = true,
  }) : super(key: key);

  @override
  ObjectWidgetState createState() => ObjectWidgetState();
}

class ObjectWidgetState extends State<ObjectWidget>{

  static Set<double> assistAngles = <double>{0, pi/4, pi/2, 3*pi/4, pi, 5*pi/4, 3*pi/2, 7*pi/4, 2*pi};

  static double get objectPadding => 25;

  /// Keeps track of the initial local focal point when scaling starts.
  ///
  /// This is used to offset the movement of the drawable correctly.
  Map<int, Offset> drawableInitialLocalFocalPoints = {};

  /// Keeps track of the initial drawable when scaling starts.
  ///
  /// This is used to calculate the new rotation angle and
  /// degree relative to the initial drawable.
  Map<int, ObjectDrawable> initialScaleDrawables = {};

  /// Keeps track of widgets that have assist lines assigned to them.
  ///
  /// This is used to provide haptic feedback when the assist line appears.
  Map<ObjectDrawableAssist, Set<int>> assistDrawables = Map.fromIterable(
      ObjectDrawableAssist.values,
      key: (e) => e,
      value: (e) => <int>{}
  );

  /// Getter for the list of [ObjectDrawable]s in the controller
  /// to make code more readable.
  List<ObjectDrawable> get drawables => widget.controller.value
      .drawables.whereType<ObjectDrawable>().toList();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: widget.child
              ),

              ...drawables.asMap().entries.map((entry) {
                final drawable = entry.value;
                final size = drawable.getSize(maxWidth: constraints.maxWidth * drawable.scale);
                final widget = Padding(
                  padding: EdgeInsets.all(objectPadding),
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                  ),
                );
                return Positioned(
                  // Offset the position by half the size of the drawable so that
                  // the object is in the center point
                  top: drawable.position.dy - objectPadding - size.height/2,
                  left: drawable.position.dx - objectPadding - size.width/2,
                  child: Transform.rotate(
                    angle: drawable.rotationAngle,
                    transformHitTests: true,
                    child: Container(
                      child: freeStyleSettings.enabled ? widget : MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => tapDrawable(drawable),
                          onScaleStart: (details) => onDrawableScaleStart(entry, details),
                          onScaleUpdate: (details) => onDrawableScaleUpdate(entry, details),
                          onScaleEnd: (_) => onDrawableScaleEnd(entry),
                          child: widget,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        }
    );
  }

  /// Getter for the [ObjectSettings] from the controller to make code more readable.
  ObjectSettings get settings =>
      widget.controller.value.settings.object;

  /// Getter for the [FreeStyleSettings] from the controller to make code more readable.
  ///
  /// This is used to disable object movement, scaling and rotation
  /// when free-style drawing is enabled.
  FreeStyleSettings get freeStyleSettings =>
      widget.controller.value.settings.freeStyle;

  /// Callback when an object is tapped.
  ///
  /// Dispatches an [ObjectDrawableNotification] that the object was tapped.
  void tapDrawable(ObjectDrawable drawable){
    ObjectDrawableNotification(
      drawable,
      ObjectDrawableNotificationType.tapped
    ).dispatch(context);
  }

  /// Callback when the object drawable starts being moved, scaled and/or rotated.
  ///
  /// Saves the initial point of interaction and drawable to be used on update events.
  void onDrawableScaleStart(MapEntry<int, ObjectDrawable> entry, ScaleStartDetails details){

    if(!widget.interactionEnabled)
      return;

    final index = entry.key;
    final drawable = entry.value;

    if(index < 0)
      return;

    initialScaleDrawables[index] = drawable;

    // When the gesture detector is rotated, the hit test details are not transformed with it
    // This causes events from rotated objects to behave incorrectly
    // So, a [Matrix4] is used to transform the needed event details to be consistent with
    // the current rotation of the object
    final rotateOffset = Matrix4.rotationZ(drawable.rotationAngle)
      ..translate(details.localFocalPoint.dx,details.localFocalPoint.dy)
      ..rotateZ(-drawable.rotationAngle);
    drawableInitialLocalFocalPoints[index] = Offset(rotateOffset[12], rotateOffset[13]);
  }

  /// Callback when the object drawable finishes movement, scaling and rotation.
  ///
  /// Cleans up the object information.
  void onDrawableScaleEnd(MapEntry<int, ObjectDrawable> entry){
    if(!widget.interactionEnabled)
      return;

    final index = entry.key;

    // Using the index instead of [entry.value] is to prevent an issue
    // when an update and end events happen before the UI is updated,
    // the [entry.value] is the old drawable before it was updated
    // This causes updating the entry in this method to sometimes fail
    // To get around it, the object is fetched directly from the drawables
    // in the controller
    final drawable = drawables[index];

    // Clean up
    drawableInitialLocalFocalPoints.remove(index);
    initialScaleDrawables.remove(index);
    for (final assistSet in assistDrawables.values)
      assistSet.remove(index);

    // Remove any assist lines the object has
    final newDrawable = drawable.copyWith(
      assists: {}
    );

    updateDrawable(drawable, newDrawable);
  }

  /// Callback when the object drawable is moved, scaled and/or rotated.
  ///
  /// Calculates the next position, scale and rotation of the object depending on the event details.
  void onDrawableScaleUpdate(MapEntry<int, ObjectDrawable> entry, ScaleUpdateDetails details){
    if(!widget.interactionEnabled)
      return;

    final index = entry.key;
    final drawable = entry.value;
    if(index < 0)
      return;

    final initialDrawable = initialScaleDrawables[index];
    // When the gesture detector is rotated, the hit test details are not transformed with it
    // This causes events from rotated objects to behave incorrectly
    // So, a [Matrix4] is used to transform the needed event details to be consistent with
    // the current rotation of the object
    final initialLocalFocalPoint = drawableInitialLocalFocalPoints[index] ?? Offset.zero;

    if(initialDrawable == null)
      return;

    final initialPosition = initialDrawable.position - initialLocalFocalPoint;
    final initialRotation = initialDrawable.rotationAngle;

    // When the gesture detector is rotated, the hit test details are not transformed with it
    // This causes events from rotated objects to behave incorrectly
    // So, a [Matrix4] is used to transform the needed event details to be consistent with
    // the current rotation of the object
    final rotateOffset = Matrix4.identity()
      ..rotateZ(initialRotation)
      ..translate(details.localFocalPoint.dx, details.localFocalPoint.dy)
      ..rotateZ(-initialRotation);
    final position = initialPosition + Offset(rotateOffset[12], rotateOffset[13]);

    // Calculate scale of object reference to the initial object scale
    final scale = initialDrawable.scale * details.scale;

    // Calculate the rotation of the object reference to the initial object rotation
    // and normalize it so that its between 0 and 2*pi
    var rotation = (initialRotation + details.rotation).remainder(pi*2);
    if(rotation < 0)
      rotation += pi*2;

    // The center point of the widget
    final center = this.center;

    // The angle from [assistAngles] the object's current rotation is close
    final double? closestAssistAngle;

    // If layout assist is enabled, calculate the positional and rotational assists
    if(settings.layoutAssist.enabled){
      calculatePositionalAssists(settings.layoutAssist, index, position, center,);
      closestAssistAngle = calculateRotationalAssist(settings.layoutAssist, index, rotation,);
    }
    else{
      closestAssistAngle = null;
    }

    // The set of assists for the object
    // If layout assist is disabled, it is empty
    final assists = settings.layoutAssist.enabled ?
    assistDrawables.entries
        .where((element) => element.value.contains(index))
        .map((e) => e.key)
        .toSet() :
    <ObjectDrawableAssist>{};

    // Do not display the rotational assist if the user is using less that 2 pointers
    // So, rotational assist lines won't show if the user is only moving the object
    if(details.pointerCount < 2)
      assists.remove(ObjectDrawableAssist.rotation);

    // Snap the object to the horizontal/vertical center if its is near it
    // and layout assist is enabled
    final assistedPosition = Offset(
      assists.contains(ObjectDrawableAssist.vertical) ? center.dx : position.dx,
      assists.contains(ObjectDrawableAssist.horizontal) ? center.dy : position.dy,
    );

    // Snap the object rotation to the nearest angle from [assistAngles] if its near it
    // and layout assist is enabled
    final assistedRotation =
      assists.contains(ObjectDrawableAssist.rotation) && closestAssistAngle != null ?
      closestAssistAngle.remainder(pi*2) :
      rotation;

    final newDrawable = drawable.copyWith(
      position: assistedPosition,
      scale: scale,
      rotation: assistedRotation,
      assists: assists,
    );

    updateDrawable(drawable, newDrawable);
  }

  /// Calculates whether the object entered or exited the horizontal and vertical assist areas.
  void calculatePositionalAssists(ObjectLayoutAssistSettings settings, int index, Offset position, Offset center){
    // Horizontal
    //
    // If the object is within the enter distance from the center dy and isn't marked
    // as a drawable with a horizontal assist, mark it
    if((position.dy - center.dy).abs() < settings.positionalEnterDistance &&
        !(assistDrawables[ObjectDrawableAssist.horizontal]?.contains(index) ?? false)){
      assistDrawables[ObjectDrawableAssist.horizontal]?.add(index);
      settings.hapticFeedback.impact();
    }
    // Otherwise, if the object is outside the exit distance from the center dy and is marked as
    // as a drawable with a horizontal assist, un-mark it
    else if ((position.dy - center.dy).abs() > settings.positionalExitDistance &&
        (assistDrawables[ObjectDrawableAssist.horizontal]?.contains(index) ?? false)){
      assistDrawables[ObjectDrawableAssist.horizontal]?.remove(index);
    }

    // Vertical
    //
    // If the object is within the enter distance from the center dx and isn't marked
    // as a drawable with a vertical assist, mark it
    if((position.dx - center.dx).abs() < settings.positionalEnterDistance &&
      !(assistDrawables[ObjectDrawableAssist.vertical]?.contains(index) ?? false)){
      assistDrawables[ObjectDrawableAssist.vertical]?.add(index);
      settings.hapticFeedback.impact();
    }
    // Otherwise, if the object is outside the exit distance from the center dx and is marked as
    // as a drawable with a vertical assist, un-mark it
    else if ((position.dx - center.dx).abs() > settings.positionalExitDistance &&
        (assistDrawables[ObjectDrawableAssist.vertical]?.contains(index) ?? false)){
        assistDrawables[ObjectDrawableAssist.vertical]?.remove(index);
    }
  }
  /// Calculates whether the object entered or exited the rotational assist range.
  ///
  /// Returns the angle the object is closest to if it is inside the assist range.
  double? calculateRotationalAssist(ObjectLayoutAssistSettings settings, int index, double rotation){
    // Calculates all angles from [assistAngles] in the exit range of rotational assist
    final closeAngles = assistAngles
        .where((angle) => (rotation - angle).abs() < settings.rotationalExitAngle)
        .toList();

    // If the object is close to at least one assist angle
    if(closeAngles.isNotEmpty){
      // If the object is also in the enter range of rotational assist and isn't marked
      // as a drawable with a rotational assist, mark it
      if(closeAngles.any((angle) => (rotation - angle).abs() < settings.rotationalEnterAngle) &&
          !(assistDrawables[ObjectDrawableAssist.rotation]?.contains(index) ?? false)){
        assistDrawables[ObjectDrawableAssist.rotation]?.add(index);
        settings.hapticFeedback.impact();
      }
      // Return the angle the object is close to
      return closeAngles[0];
    }


    // Otherwise, if the object is not in the exit range of any assist angles,
    // but is marked as a drawable with rotational assist, un-mark it
    if(closeAngles.isEmpty &&
        (assistDrawables[ObjectDrawableAssist.rotation]?.contains(index) ?? false)){
      assistDrawables[ObjectDrawableAssist.rotation]?.remove(index);
    }

    return null;

  }

  /// Returns the center point of the painter widget.
  ///
  /// Uses the [GlobalKey] for the painter from [controller].
  Offset get center {
    final renderBox = widget.controller.painterKey
        .currentContext?.findRenderObject() as RenderBox?;
    final center = renderBox == null ? Offset.zero :
    Offset(
      renderBox.size.width/2,
      renderBox.size.height/2,
    );
    return center;
  }

  /// Replaces a drawable with a new one.
  void updateDrawable(ObjectDrawable oldDrawable, ObjectDrawable newDrawable){
    setState(() {
      widget.controller.replaceDrawable(oldDrawable, newDrawable);
    });
  }


}

/// Represents a [Notification] that [ObjectWidget] dispatches when an event occurs
/// that requires a parent to handle it.
///
/// Parent widgets can listen using a [NotificationListener] and handle the notification.
class ObjectDrawableNotification extends Notification{
  /// The drawable involved in the notification.
  final ObjectDrawable drawable;

  /// The type of event that caused this notification to trigger.
  final ObjectDrawableNotificationType type;

  /// Creates an [ObjectDrawableNotification] with the given [drawable] and [type].
  const ObjectDrawableNotification(this.drawable, this.type);
}

/// The types of events that are dispatched with an [ObjectDrawableNotification].
enum ObjectDrawableNotificationType {
  /// Represents the event of tapping an [ObjectDrawable] inside the [ObjectWidget].
  tapped,
}