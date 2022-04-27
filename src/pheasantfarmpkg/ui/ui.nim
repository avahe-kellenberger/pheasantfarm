import shade

type
  ## -1.0 to 1.0, 0.0 being the center of a menu, screen, etc.
  PositionRange* = -1.0 .. 1.0
  Position* = tuple[x: PositionRange, y: PositionRange]
  UIElement* = ref object of RootObj
    position*: Position
    size*: Vector

template getLocationInParent*(position: Position, parentSize: Vector): Vector =
  vector(position.x * parentSize.x * 0.5, position.y * parentSize.y * 0.5)

method render*(this: UIElement, ctx: Target) {.base.} = discard
