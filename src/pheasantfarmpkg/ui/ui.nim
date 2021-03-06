import shade

type
  ## -1.0 to 1.0, 0.0 being the center of a menu, screen, etc.
  PositionRange* = -1.0 .. 1.0
  Position* = tuple[x: PositionRange, y: PositionRange]
  UIElement* = ref object of RootObj
    position*: Position
    size*: Vector
    visible*: bool
    onClickHandler*: proc()

proc newPosition*(x, y: PositionRange): Position =
  return (x, y)

proc initUIElement*(element: UIElement) =
  element.visible = true

template getLocationInParent*(position: Position, parentSize: Vector): Vector =
  vector(position.x * parentSize.x * 0.5, position.y * parentSize.y * 0.5)

template onClick*(this: UIElement, body: untyped) =
  this.onClickHandler = proc() = body

UIElement.renderAsParent:
  if this.visible and callback != nil:
    callback()
