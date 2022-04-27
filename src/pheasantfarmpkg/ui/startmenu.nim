import shade

import menu, ui, button, label, fontloader
export ui, button, label

type
  StartMenu* = ref object of Panel
    startButton*: Button
    quitButton*: Button

iterator buttons*(this: StartMenu): Button =
  for button in [this.startButton, this.quitButton]:
    yield button

proc newStartMenu*(): StartMenu =
  result = StartMenu()
  initPanel(Panel(result))

  let title = newButton("./assets/title.png")
  title.position.y = -0.60
  result.add(title)

  result.startButton = newButton("./assets/start.png")
  result.startButton.position.y = -0.10

  result.quitButton = newButton("./assets/quit.png")
  result.quitButton.position.y = 0.10

  result.add(result.startButton)
  result.add(result.quitButton)

  let this = result
  Input.addMousePressedEventListener(
    proc(button: int, state: ButtonState, x, y, clickCount: int) =
      if not this.visible:
        return

      let clickedCoord = vector(x, y) - this.getLocation()
      for button in this.buttons:
        if button.onClickHandler != nil and this.elementContainsPoint(button, clickedCoord):
          button.onClickHandler()
  )

