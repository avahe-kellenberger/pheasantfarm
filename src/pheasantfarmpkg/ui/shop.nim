import shade

import strformat

import panel, ui, button, label, format
export ui, button, label

type Shop* = ref object of Panel

proc newShop*(onExit: proc()): Shop =
  result = Shop()
  initPanel(Panel(result))

  let bgImage = newButton("./assets/storephront.png")
  result.size = bgImage.size
  result.add(bgImage)

  let title = newLabel("The Thriphty Pheasant", WHITE)
  title.position.y = -0.5
  result.add(title)

  let pheedBoard = newButton("./assets/shop_board.png")
  pheedBoard.position = newPosition(-0.6, 0.45)
  result.add(pheedBoard)

  let pheedIcon = newButton("./assets/pheed_icon.png")
  pheedIcon.scale = vector(4.0, 4.0)
  pheedIcon.position = newPosition(-0.75, 0.45)
  result.add(pheedIcon)

  let waterBoard = newButton("./assets/shop_board.png")
  waterBoard.position = newPosition(0, 0.45)
  result.add(waterBoard)

  let waterIcon = newButton("./assets/water_icon.png")
  waterIcon.scale = vector(4.0, 4.0)
  waterIcon.position = newPosition(-0.15, 0.45)
  result.add(waterIcon)

  let nestBoard = newButton("./assets/shop_board.png")
  nestBoard.position = newPosition(0.6, 0.45)
  result.add(nestBoard)

  let nestIcon = newButton("./assets/nest_icon.png")
  nestIcon.scale = vector(4.5, 4.5)
  nestIcon.position = newPosition(0.45, 0.45)
  result.add(nestIcon)

  let
    (_, exitImage) = Images.loadImage("./assets/x.png")
    exitSprite = newSprite(exitImage)
    exitButton = newButton(exitSprite)

  exitSprite.offset.x = -10
  exitSprite.offset.y = 10
  exitButton.scale = vector(0.5, 0.5)
  exitButton.position = newPosition(1, -1)
  result.add(exitButton)

  let this = result
  exitButton.onClick:
    this.visible = false
    onExit()

