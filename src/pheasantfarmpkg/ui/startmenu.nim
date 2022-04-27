import shade

import menu, ui, button
export ui, button

const scale = vector(1.5, 1.5)

type
  StartMenu* = ref object of Menu
    startButton*: Button
    statsButton*: Button
    settingsButton*: Button
    quitButton*: Button

proc newStartMenu*(): StartMenu =
  result = StartMenu()
  initMenu(Menu(result))
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

  result.addButton(result.startButton)
  result.addButton(result.statsButton)
  result.addButton(result.settingsButton)
  result.addButton(result.quitButton)

  let this = result
  Input.addMousePressedEventListener(
    proc(button: int, state: ButtonState, x, y, clickCount: int) =
      if this.visible:
        let clickedCoord = vector(x, y) - this.getLocation()
        for button in this.buttons:
          if button.onClickHandler != nil and this.buttonContainsPoint(button, clickedCoord):
            button.onClickHandler()
  )

