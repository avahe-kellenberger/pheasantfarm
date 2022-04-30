import shade

import strformat

import panel, ui, button, label, format, ../items
export ui, button, label, items

var
  instructionsFont: Font
  itemBoardSprite: Sprite = nil
  multiplySprite: Sprite = nil

type ItemPanel* = ref object of Panel
  pheasantCountLabel: Label
  pheedCountLabel: Label
  waterCountLabel: Label
  nestCountLabel: Label

proc createItem(this: ItemPanel, sprite: Sprite, position: Position, scale: Vector = vector(3, 3)): Label
proc setPheasantCount*(this: ItemPanel, count: int)
proc setPheedCount*(this: ItemPanel, count: int)
proc setWaterCount*(this: ItemPanel, count: int)
proc setNestCount*(this: ItemPanel, count: int)

proc newItemPanel*(): ItemPanel =
  result = ItemPanel()
  initPanel(Panel(result))

  itemBoardSprite = newSprite(Images.loadImage("./assets/item_board.png").image)
  result.size = vector(itemBoardSprite.size.x, itemBoardSprite.size.y * 5)

  multiplySprite = newSprite(Images.loadImage("./assets/multiply.png", FILTER_NEAREST).image)

  let
    instructionsFont = Fonts.load("./assets/fonts/kennypixel.ttf", 32).font
    pheasantSprite = newSprite(
      Images.loadImage("./assets/common_pheasant.png", FILTER_NEAREST).image,
      4,
      1
    )
    pheedSprite = newSprite(Images.loadImage("./assets/pheed_icon.png", FILTER_NEAREST).image)
    waterSprite = newSprite(Images.loadImage("./assets/water_icon.png", FILTER_NEAREST).image)
    nestSprite = newSprite(Images.loadImage("./assets/nest_icon.png", FILTER_NEAREST).image)

  const xPosition = -0.85
  result.pheasantCountLabel = 
    result.createItem(pheasantSprite, newPosition(xPosition, -0.6), vector(4, 4))

  result.pheedCountLabel =
    result.createItem(pheedSprite, newPosition(xPosition, -0.2))

  result.waterCountLabel =
    result.createItem(waterSprite, newPosition(xPosition, 0.2))

  result.nestCountLabel =
    result.createItem(nestSprite, newPosition(xPosition, 0.6))

  let nestInstructions = newLabel("SPACE to use Nest", WHITE)
  nestInstructions.font = instructionsFont
  nestInstructions.position.x = result.nestCountLabel.position.x - 0.4
  nestInstructions.position.y = 0.85
  result.add(nestInstructions)

  let nestRequirementLabel = newLabel("Requires white egg", WHITE)
  nestRequirementLabel.font = instructionsFont
  nestRequirementLabel.position.x = nestInstructions.position.x
  nestRequirementLabel.position.y = 0.95
  result.add(nestRequirementLabel)

proc createItem(this: ItemPanel, sprite: Sprite, position: Position, scale: Vector = vector(3, 3)): Label =
  let boardImage = newButton(itemBoardSprite)
  boardImage.position = newPosition(0.0, position.y)
  this.add(boardImage)

  sprite.offset.x = sprite.size.x * 0.5
  let itemButton = newButton(sprite)
  itemButton.scale = scale
  itemButton.position = position
  this.add(itemButton)

  let multiply = newButton(multiplySprite)
  multiply.position.x = itemButton.position.x + 0.75
  multiply.position.y = itemButton.position.y
  this.add(multiply)

  result = newLabel("0", WHITE)
  result.position.x = multiply.position.x + 0.5
  result.position.y = multiply.position.y
  this.add(result)

proc setPheasantCount*(this: ItemPanel, count: int) =
  this.pheasantCountLabel.setText($count)

proc setPheedCount*(this: ItemPanel, count: int) =
  this.pheedCountLabel.setText($count)

proc setWaterCount*(this: ItemPanel, count: int) =
  this.waterCountLabel.setText($count)

proc setNestCount*(this: ItemPanel, count: int) =
  this.nestCountLabel.setText($count)

