import shade

import strformat

import panel, ui, label, format, button
export ui

const orangeColor = newColor(179, 89, 0)

type GameOverScreen* = ref object of Panel

proc newGameOverScreen*(): GameOverScreen =
  result = GameOverScreen()
  initPanel(Panel(result))

  let
    gameOverLabel = newLabel("Game Over", WHITE)
    brokeLabel = newLabel("You're BROKE!", newColor(160, 20, 20))
    quitButton = newButton("./assets/quit.png")

  result.add(gameOverLabel)
  result.add(brokeLabel)
  result.add(quitButton)

  gameOverLabel.position.y = -0.5
  brokeLabel.position.y = -0.4
  quitButton.onClick:
    Game.stop()

