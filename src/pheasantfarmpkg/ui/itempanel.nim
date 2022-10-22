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
  initUIComponent(UIComponent result)

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

  result.pheasantCountLabel = result.createItem(pheasantSprite, vector(4, 4))
  result.pheedCountLabel = result.createItem(pheedSprite)
  result.waterCountLabel = result.createItem(waterSprite)
  result.nestCountLabel = result.createItem(nestSprite)

  let nestInstructions = newText(instructionsFont, "SPACE to use Nest", WHITE)
  result.addChild(nestInstructions)
  result.alignHorizontal = Alignment.Center

  let nestRequirementLabel = newText(instructionsFont, "(Uses best egg)", WHITE)
  result.addChild(nestRequirementLabel)

proc createItem(this: ItemPanel, sprite: Sprite, scale: Vector = vector(3, 3)): UITextComponent =
  result = newText(getFont(), "0", WHITE)

  let boardImage = newUISprite(itemBoardSprite)
  this.addChild(boardImage)

  sprite.offset.x = sprite.size.x * 0.5
  let itemButton = newUISprite(sprite)
  itemButton.scale = scale
  boardImage.addChild(itemButton)

  let multiply = newUISprite(multiplySprite)
  boardImage.addChild(multiply)

  boardImage.stackDirection = StackDirection.Horizontal
  boardImage.alignHorizontal = Alignment.SpaceEvenly
  boardImage.alignVertical = Alignment.SpaceEvenly

  boardImage.addChild(result)

proc setPheasantCount*(this: ItemPanel, count: int) =
  this.pheasantCountLabel.text = $count

proc setPheedCount*(this: ItemPanel, count: int) =
  this.pheedCountLabel.text = $count

proc setWaterCount*(this: ItemPanel, count: int) =
  this.waterCountLabel.text = $count

proc setNestCount*(this: ItemPanel, count: int) =
  this.nestCountLabel.text = $count

