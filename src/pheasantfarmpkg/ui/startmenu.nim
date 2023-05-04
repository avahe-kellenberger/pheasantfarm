import shade
import fontloader

type
  StartMenu* = ref object of UIComponent
    startButton*: UIImage
    hiscoresButton*: UIImage
    quitButton*: UIImage

proc newStartMenu*(): StartMenu =
  result = StartMenu()
  initUIComponent(UIComponent result)

  result.stackDirection = StackDirection.Vertical
  result.alignHorizontal = Alignment.Center
  result.alignVertical = Alignment.Start

  let spacer = newUIComponent()
  spacer.height = ratio(0.15)
  result.addChild(spacer)

  let title = newUIImage("./assets/title.png")
  title.margin = 30.0
  result.addChild(title)

  let phrenzy = newUIImage("./assets/phrenzy.png")
  phrenzy.margin = 30.0
  result.addChild(phrenzy)

  let
    itemBgImage = Images.loadImage("./assets/shop_board.png").image
    font = Fonts.load("./assets/fonts/mozart.ttf", 86).font

  result.startButton = newUIImage(itemBgImage)
  result.startButton.alignVertical = Alignment.Center
  result.startButton.alignHorizontal = Alignment.Center
  result.startButton.margin = 30.0

  let startText = newText(font, "Start", WHITE)
  startText.processInputEvents = false
  result.startButton.addChild(startText)

  result.hiscoresButton = newUIImage(itemBgImage)
  result.hiscoresButton.scale = vector(1.2, 1.0)
  result.hiscoresButton.alignVertical = Alignment.Center
  result.hiscoresButton.alignHorizontal = Alignment.Center
  result.hiscoresButton.margin = 30.0

  let hiscoresText = newText(font, "Hiscores", WHITE)
  hiscoresText.processInputEvents = false
  result.hiscoresButton.addChild(hiscoresText)

  result.quitButton = newUIImage(itemBgImage)
  result.quitButton.alignVertical = Alignment.Center
  result.quitButton.alignHorizontal = Alignment.Center
  result.quitButton.margin = 30.0

  let quitText = newText(font, "Quit", WHITE)
  quitText.processInputEvents = false
  result.quitButton.addChild(quitText)

  result.addChild(result.startButton)
  result.addChild(result.hiscoresButton)
  result.addChild(result.quitButton)

