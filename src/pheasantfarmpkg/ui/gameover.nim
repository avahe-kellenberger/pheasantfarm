import shade
import fontloader
import std/strutils
import ../hiscores

type GameOverScreen* = ref object of UIComponent
  enterNamePrompt: UITextComponent
  playerNameInput: UITextComponent
  playerName: string
  quitButton*: UIImage

proc newGameOverScreen*(): GameOverScreen =
  result = GameOverScreen()
  initUIComponent(UIComponent(result))

  result.stackDirection = StackDirection.Vertical
  result.alignHorizontal = Alignment.Center
  result.alignVertical = Alignment.Center

  let
    gameOverLabel = newText(getFont(), "Game Over", WHITE)
    brokeLabel = newText(getFont(), "You're BROKE!", newColor(160, 20, 20))
  
  result.quitButton = newUIImage("./assets/quit.png")

  result.enterNamePrompt = newText(getFont(), "Enter your name for Hi-Scores:", WHITE)
  result.enterNamePrompt.margin = margin(0, 24, 0, 0)
  # TODO: Giving text 1 space by default fixes a bug where it takes as much space as possible.
  result.playerNameInput = newText(getFont(), " ", GREEN)
  result.playerNameInput.margin = 24.0

  # TODO: Using hack to calculate height before first render pass.
  gameOverLabel.determineWidthAndHeight()
  brokelabel.determineWidthAndHeight()
  result.enterNamePrompt.determineWidthAndHeight()
  result.playerNameInput.determineWidthAndHeight()

  result.addChild(gameOverLabel)
  result.addChild(brokeLabel)
  result.addChild(result.enterNamePrompt)
  result.addChild(result.playerNameInput)
  result.addChild(result.quitButton)

proc endGame*(this: GameOverScreen, day: int) =
  ## Enables this component's input functionality.
  this.quitButton.onPressed:
    saveHiscore(this.playerName, day)
    Game.stop()

  Input.onKeyEvent:
    if state.justPressed:
      if key in K_a..K_z or key in K_0..K_9 or key == K_SPACE:
        let letter = chr(ord(key)).toUpperAscii()
        this.playerName &= letter
        this.playerNameInput.text = this.playerName

    if state.pressed and key == K_BACKSPACE:
      let nameLength = this.playerName.len()
      if nameLength > 0:
        this.playerName.setLen(nameLength - 1)
        this.playerNameInput.text = this.playerName

  if isNewHighScore(day):
    this.enterNamePrompt.enableAndSetVisible()
    this.playerNameInput.enableAndSetVisible()
  else:
    this.enterNamePrompt.disableAndHide()
    this.playerNameInput.disableAndHide()

  this.enableAndSetVisible()

