import shade

import fontloader

type GameOverScreen* = ref object of UIComponent

proc newGameOverScreen*(): GameOverScreen =
  result = GameOverScreen()
  initUIComponent(UIComponent(result))

  result.stackDirection = StackDirection.Vertical
  result.alignHorizontal = Alignment.Center
  result.alignVertical = Alignment.Center

  let
    gameOverLabel = newText(getFont(), "Game Over", WHITE)
    brokeLabel = newText(getFont(), "You're BROKE!", newColor(160, 20, 20))
    quitButton = newUIImage("./assets/quit.png")

  # TODO: Using hack to calculate height before first render pass.
  gameOverLabel.determineWidthAndHeight()
  brokelabel.determineWidthAndHeight()

  result.addChild(gameOverLabel)
  result.addChild(brokeLabel)
  result.addChild(quitButton)

  quitButton.onPressed:
    Game.stop()

