import shade

type
  ## -1.0 to 1.0, 0.0 being the center of a menu, screen, etc.
  PositionRange* = -1.0 .. 1.0
  Position* = tuple[x: PositionRange, y: PositionRange]
  Positionable* = concept p
    p.position is Position
  UIElement* = concept e, ctx
    e of Positionable
    ctx of Target
    render(e, ctx)
    e.size is Vector

template getLocationInParent*(this: Positionable, parentSize: Vector): Vector =
  vector(this.position.x * parentSize.x * 0.5, this.position.y * parentSize.y * 0.5)
