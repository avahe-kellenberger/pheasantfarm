import shade

import button

const scale = vector(0.25, 0.25)

type
  StartMenu* = ref object of Node
    startButton: Button

proc onStartClicked(this: StartMenu)

proc newStartMenu*(): StartMenu =
  result = StartMenu()
  initNode(Node(result), {LayerObjectFlags.RENDER})

  result.startButton = newButton("./assets/start.png")

  # NOTE: Scale the buttons, not the menu.
  # This is a work-around for camera world coord translations.
  result.startButton.scale = scale

  let this = result
  Input.addMousePressedEventListener(
    proc(button: int, state: ButtonState, x, y, clicks: int) =
      let worldCoord =
        if Game.scene.camera != nil:
          Game.scene.camera.screenToWorldCoord(x, y, 1.0 - Game.scene.camera.z)
        else:
          vector(x, y)

      if this.startButton.contains(worldCoord):
        this.onStartClicked()
  )

proc onStartClicked(this: StartMenu) =
  # TODO: Transition to the game
  discard

StartMenu.renderAsNodeChild:
  this.startButton.render(ctx)

  if callback != nil:
    callback()

