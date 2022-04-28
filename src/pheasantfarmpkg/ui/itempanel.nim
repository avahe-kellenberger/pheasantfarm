import shade

import strformat

import panel, ui, button, label, format, ../items
export ui, button, label, items

var
  itemBoardSprite: Sprite = nil
  multiplySprite: Sprite = nil

type ItemPanel* = ref object of Panel
  pheasantCountLabel: Label

proc createItem(this: ItemPanel, sprite: Sprite, position: Position, scale: Vector, qty: int): Label
proc setPheasantCount*(this: ItemPanel, count: int)

proc newItemPanel*(): ItemPanel =
  result = ItemPanel()
  initPanel(Panel(result))

  itemBoardSprite = newSprite(Images.loadImage("./assets/item_board.png").image)
  result.size = vector(itemBoardSprite.size.x, itemBoardSprite.size.y * 5)

  multiplySprite = newSprite(Images.loadImage("./assets/multiply.png", FILTER_NEAREST).image)

  let
    pheasantSprite = newSprite(
      Images.loadImage("./assets/common_pheasant.png", FILTER_NEAREST).image,
      4,
      1
    )
    pheedSprite = newSprite(Images.loadImage("./assets/pheed_icon.png", FILTER_NEAREST).image)
    waterSprite = newSprite(Images.loadImage("./assets/water_icon.png", FILTER_NEAREST).image)
    nestSprite = newSprite(Images.loadImage("./assets/nest_icon.png", FILTER_NEAREST).image)

  result.pheasantCountLabel = 
    result.createItem(pheasantSprite, newPosition(-0.9, -0.6), vector(4.0, 4.0), 0)

  discard result.createItem(pheedSprite, newPosition(-0.9, -0.2), vector(3.0, 3.0), 0)
  discard result.createItem(waterSprite, newPosition(-0.9, 0.2), vector(3.0, 3.0), 0)
  discard result.createItem(nestSprite, newPosition(-0.9, 0.6), vector(4.0, 4.0), 0)

proc createItem(this: ItemPanel, sprite: Sprite, position: Position, scale: Vector, qty: int): Label =
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

  result = newLabel($qty, WHITE)
  result.position.x = multiply.position.x + 0.5
  result.position.y = multiply.position.y
  this.add(result)

proc setPheasantCount*(this: ItemPanel, count: int) =
  this.pheasantCountLabel.setText($count)

