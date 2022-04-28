import shade

import panel, ui, button, label
export ui, button, label

type
  StartMenu* = ref object of Panel
    startButton*: Button
    quitButton*: Button

proc newStartMenu*(): StartMenu =
  result = StartMenu()
  initPanel(Panel(result))

  let title = newButton("./assets/title.png")
  title.position.y = -0.60
  result.add(title)

  let phrenzy = newButton("./assets/phrenzy.png")
  phrenzy.position.y = -0.35
  result.add(phrenzy)

  result.startButton = newButton("./assets/start.png")
  result.startButton.position.y = -0.10

  result.quitButton = newButton("./assets/quit.png")
  result.quitButton.position.y = 0.10

  result.add(result.startButton)
  result.add(result.quitButton)

