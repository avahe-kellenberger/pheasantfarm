import shade

import ui, button
export ui, button

const scale = vector(1.5, 1.5)

type
  Menu* = ref object of Node
    # TODO: Make this node a container (like start menu)
    # that can be used for startmenu, shop, etc
    visible*: bool
    size*: Vector
    position*: Position
    buttons: seq[Button]

proc initMenu*(menu: Menu) =
  initNode(Node(menu), {LayerObjectFlags.RENDER})

proc newMenu*(): Menu =
  result = Menu()
  initMenu(result)

template getButtonLocationInMenu(this: Menu, button: Button): Vector =
  button.getLocationInParent(this.size)

iterator buttons*(this: Menu): Button =
  for button in this.buttons:
    yield button

proc addButton*(this: Menu, button: Button) =
  this.buttons.add(button)

proc buttonContainsPoint*(this: Menu, button: Button, point: Vector): bool =
  ## Only works for buttons inside the menu,
  ## because button positions are relative to the menu.
  let
    buttonLocInMenu = this.getButtonLocationInMenu(button)
    pointRelToButton = abs(buttonLocInMenu - point)
    halfButtonSize = button.size * 0.5
  return halfButtonSize.x >= pointRelToButton.x and halfButtonSize.y >= pointRelToButton.y

proc renderButton(this: Menu, button: Button, ctx: Target) =
  # Render buttons using the menu size * position
  let loc = vector(this.size.x * 0.5 * button.position.x, this.size.y * 0.5 * button.position.y)
  ctx.translate(loc.x, loc.y):
    button.render(ctx)

Menu.renderAsNodeChild:
  if this.visible:
    for button in this.buttons:
      this.renderButton(button, ctx)

    if callback != nil:
      callback()

