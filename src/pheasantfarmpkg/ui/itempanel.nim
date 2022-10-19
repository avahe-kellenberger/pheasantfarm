import shade

import ../items, fontloader
export items

var
  itemBoardSprite: Sprite = nil
  multiplySprite: Sprite = nil

type ItemPanel* = ref object of UIComponent
  pheasantCountLabel: UITextComponent
  pheedCountLabel: UITextComponent
  waterCountLabel: UITextComponent
  nestCountLabel: UITextComponent

proc createItem(this: ItemPanel, sprite: Sprite, scale: Vector = vector(3, 3)): UITextComponent
proc setPheasantCount*(this: ItemPanel, count: int)
proc setPheedCount*(this: ItemPanel, count: int)
proc setWaterCount*(this: ItemPanel, count: int)
proc setNestCount*(this: ItemPanel, count: int)

proc newItemPanel*(): ItemPanel =
  result = ItemPanel()
  initUIComponent(UIComponent(result))

  itemBoardSprite = newSprite(Images.loadImage("./assets/item_board.png").image)
  result.width = itemBoardSprite.size.x
  result.height = itemBoardSprite.size.y * 5

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

  # const xPosition = -0.85
  result.pheasantCountLabel =
    result.createItem(pheasantSprite, vector(4, 4))

  result.pheedCountLabel =
    result.createItem(pheedSprite)

  result.waterCountLabel =
    result.createItem(waterSprite)

  result.nestCountLabel =
    result.createItem(nestSprite)

  let nestInstructions = newText(instructionsFont, "SPACE to use Nest", WHITE)
  # nestInstructions.position.x = result.nestCountLabel.position.x - 0.4
  # nestInstructions.position.y = 0.85
  result.addChild(nestInstructions)

  let nestRequirementLabel = newText(instructionsFont, "(Uses best egg)", WHITE)
  # nestRequirementLabel.position.x = nestInstructions.position.x
  # nestRequirementLabel.position.y = 0.95
  result.addChild(nestRequirementLabel)

proc createItem(this: ItemPanel, sprite: Sprite, scale: Vector = vector(3, 3)): UITextComponent =
  let boardImage = newUISprite(itemBoardSprite)
  # boardImage.position = newPosition(0.0, position.y)
  this.addChild(boardImage)

  sprite.offset.x = sprite.size.x * 0.5
  let itemButton = newUISprite(sprite)
  itemButton.scale = scale
  # itemButton.position = position
  this.addChild(itemButton)

  let multiply = newUISprite(multiplySprite)
  # multiply.position.x = itemButton.position.x + 0.75
  # multiply.position.y = itemButton.position.y
  this.addChild(multiply)

  result = newText(getFont(), "0", WHITE)
  # result.position.x = multiply.position.x + 0.5
  # result.position.y = multiply.position.y
  this.addChild(result)

proc setPheasantCount*(this: ItemPanel, count: int) =
  this.pheasantCountLabel.text = $count

proc setPheedCount*(this: ItemPanel, count: int) =
  this.pheedCountLabel.text = $count

proc setWaterCount*(this: ItemPanel, count: int) =
  this.waterCountLabel.text = $count

proc setNestCount*(this: ItemPanel, count: int) =
  this.nestCountLabel.text = $count

