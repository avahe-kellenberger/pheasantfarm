import shade

import fontloader

type GameOverScreen* = ref object of UIComponent

proc newGameOverScreen*(): GameOverScreen =
  result = GameOverScreen()
  initUIComponent(UIComponent(result))

  let
    gameOverLabel = newText(getFont(), "Game Over", WHITE)
    brokeLabel = newText(getFont(), "You're BROKE!", newColor(160, 20, 20))
    quitButton = newUIImage("./assets/quit.png")

  result.addChild(gameOverLabel)
  result.addChild(brokeLabel)
  result.addChild(quitButton)

  # gameOverLabel.position.y = -0.5
  # brokeLabel.position.y = -0.4

  quitButton.onPressed:
    Game.stop()

