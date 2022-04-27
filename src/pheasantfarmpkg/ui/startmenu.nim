import shade

import menu, ui, button, label
export ui, button, label

type
  StartMenu* = ref object of Panel
    startButton*: Button
    statsButton*: Button
    settingsButton*: Button
    quitButton*: Button

iterator buttons*(this: StartMenu): Button =
  for button in [this.startButton, this.statsButton, this.settingsButton, this.quitButton]:
    yield button

proc newStartMenu*(): StartMenu =
  result = StartMenu()
  initPanel(Panel(result))

  let title = newLabel("Pheasant Pharm")
  title.position.y = -0.60
  result.add(title)

  result.startButton = newButton("./assets/start.png")
  result.startButton.position.y = -0.40

  result.statsButton = newButton("./assets/stats.png")
  result.statsButton.position.y = -0.20

  result.settingsButton = newButton("./assets/settings.png")

  result.quitButton = newButton("./assets/quit.png")
  result.quitButton.position.y = 0.20

  result.add(result.startButton)
  result.add(result.statsButton)
  result.add(result.settingsButton)
  result.add(result.quitButton)

  let this = result
  Input.addMousePressedEventListener(
    proc(button: int, state: ButtonState, x, y, clickCount: int) =
      if this.visible:
        let clickedCoord = vector(x, y) - this.getLocation()
        for button in this.buttons:
          if button.onClickHandler != nil and this.elementContainsPoint(button, clickedCoord):
            button.onClickHandler()
  )

