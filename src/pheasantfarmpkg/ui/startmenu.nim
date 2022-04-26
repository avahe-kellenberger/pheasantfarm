import shade

import ui, button
export ui, button

const scale = vector(1.5, 1.5)

type
  StartMenu* = ref object of Node
    visible*: bool
    size*: Vector
    position: Position

    startButton*: Button
    statsButton*: Button
    settingsButton*: Button
    quitButton*: Button

proc buttonContainsPoint(this: StartMenu, button: Button, point: Vector): bool

iterator buttons*(this: StartMenu): Button =
  for button in [this.startButton, this.statsButton, this.settingsButton, this.quitButton]:
    yield button

proc newStartMenu*(): StartMenu =
  result = StartMenu()
  initNode(Node(result), {LayerObjectFlags.RENDER})
  result.visible = true

  # NOTE: Scale the buttons, not the menu.
  # This is a work-around for camera world coord translations.
  result.startButton = newButton("./assets/start.png")
  result.startButton.position.y = -0.40
  result.startButton.scale = scale

  result.statsButton = newButton("./assets/stats.png")
  result.statsButton.position.y = -0.20
  result.statsButton.scale = scale

  result.settingsButton = newButton("./assets/settings.png")
  result.settingsButton.scale = scale

  result.quitButton = newButton("./assets/quit.png")
  result.quitButton.position.y = 0.20
  result.quitButton.scale = scale

  let this = result
  Input.addMousePressedEventListener(
    proc(button: int, state: ButtonState, x, y, clickCount: int) =
      if this.visible:
        let clickedCoord = vector(x, y) - this.getLocation()
        for button in this.buttons:
          if button.onClickHandler != nil and this.buttonContainsPoint(button, clickedCoord):
            button.onClickHandler()
  )

proc getButtonLocationInMenu(this: StartMenu, button: Button): Vector =
  return vector(this.size.x * 0.5 * button.position.x, this.size.y * 0.5 * button.position.y)

proc buttonContainsPoint(this: StartMenu, button: Button, point: Vector): bool =
  ## Only works for buttons inside the menu,
  ## because button positions are relative to the menu.
  let
    buttonLocInMenu = this.getButtonLocationInMenu(button)
    pointRelToButton = abs(buttonLocInMenu - point)
    halfButtonSize = button.size * 0.5
  return halfButtonSize.x >= pointRelToButton.x and halfButtonSize.y >= pointRelToButton.y

template onStartClicked*(this: StartMenu, body: untyped) =
  this.startClickedHandler =
    proc() =
      body

proc renderButton(this: StartMenu, button: Button, ctx: Target) =
  # Render buttons using the menu size * position
  let loc = vector(this.size.x * 0.5 * button.position.x, this.size.y * 0.5 * button.position.y)
  ctx.translate(loc.x, loc.y):
    button.render(ctx)

StartMenu.renderAsNodeChild:
  if this.visible:
    for button in this.buttons:
      this.renderButton(button, ctx)

    if callback != nil:
      callback()

