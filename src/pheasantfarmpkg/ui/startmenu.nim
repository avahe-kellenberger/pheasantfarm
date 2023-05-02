import shade

type
  StartMenu* = ref object of UIComponent
    startButton*: UIImage
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

  result.startButton = newUIImage("./assets/start.png")
  result.startButton.margin = 30.0

  result.quitButton = newUIImage("./assets/quit.png")
  result.quitButton.margin = 30.0

  result.addChild(result.startButton)
  result.addChild(result.quitButton)

