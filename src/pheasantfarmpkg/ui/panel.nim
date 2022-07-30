import shade

import ui
export ui

type
  Panel* = ref object of Node
    visible*: bool
    size*: Vector
    position*: Position
    elements: seq[UIElement]

proc elementContainsPoint*(this: Panel, element: UIElement, point: Vector): bool

iterator elements*(this: Panel): UIElement =
  for element in this.elements:
    yield element

proc initPanel*(panel: Panel) =
  initNode(Node(panel), {LayerObjectFlags.RENDER})
  panel.visible = true

  Input.addMousePressedListener(
    proc(button: int, state: ButtonState, x, y, clickCount: int) =
      if not panel.visible:
        return

      let clickedCoord = vector(x, y) - panel.getLocation()
      for element in panel.elements:
        if element.visible and
           element.onClickHandler != nil and
           panel.elementContainsPoint(element, clickedCoord):
            element.onClickHandler()
  )

proc newPanel*(): Panel =
  result = Panel()
  initPanel(result)

proc add*(this: Panel, element: UIElement) =
  this.elements.add(element)

proc elementContainsPoint*(this: Panel, element: UIElement, point: Vector): bool =
  ## Only works for elements inside the panel,
  ## because element positions are relative to the panel.
  let
    elementLocInPanel = getLocationInParent(element.position, this.size)
    pointRelToElement = abs(elementLocInPanel - point)
    halfElementSize = element.size * 0.5
  return halfElementSize.x >= pointRelToElement.x and halfElementSize.y >= pointRelToElement.y

proc renderElement(this: Panel, element: UIElement, ctx: Target) =
  # Render elements using the panel size * position
  let loc = vector(this.size.x * 0.5 * element.position.x, this.size.y * 0.5 * element.position.y)
  element.render(ctx, this.x + round(loc.x), this.y + round(loc.y))

Panel.renderAsNodeChild:
  if this.visible:
    for e in this.elements:
      this.renderElement(e, ctx)

