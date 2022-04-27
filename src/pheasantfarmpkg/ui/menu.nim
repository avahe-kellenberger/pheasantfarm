import shade

import ui
export ui

type
  Menu* = ref object of Node
    visible*: bool
    size*: Vector
    position*: Position
    elements: seq[UIElement]

proc initMenu*(menu: Menu) =
  initNode(Node(menu), {LayerObjectFlags.RENDER})
  menu.visible = true

proc newMenu*(): Menu =
  result = Menu()
  initMenu(result)

iterator elements*(this: Menu): UIElement =
  for element in this.elements:
    yield element

proc add*(this: Menu, element: UIElement) =
  this.elements.add(element)

proc elementContainsPoint*(this: Menu, element: UIElement, point: Vector): bool =
  ## Only works for elements inside the menu,
  ## because element positions are relative to the menu.
  let
    elementLocInMenu = getLocationInParent(element.position, this.size)
    pointRelToElement = abs(elementLocInMenu - point)
    halfElementSize = element.size * 0.5
  return halfElementSize.x >= pointRelToElement.x and halfElementSize.y >= pointRelToElement.y

proc renderElement(this: Menu, element: UIElement, ctx: Target) =
  # Render elements using the menu size * position
  let loc = vector(this.size.x * 0.5 * element.position.x, this.size.y * 0.5 * element.position.y)
  ctx.translate(loc.x, loc.y):
    element.render(ctx)

Menu.renderAsNodeChild:
  if this.visible:
    for e in this.elements:
      this.renderElement(e, ctx)

    if callback != nil:
      callback()

