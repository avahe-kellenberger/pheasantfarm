import shade

import strformat, tables

import panel, ui, button, label, format, ../items
export ui, button, label, items

var shopFont: Font

var
  shopBoardSprite: Sprite = nil
  pheedSprite: Sprite = nil
  waterSprite: Sprite = nil
  nestSprite: Sprite = nil
  multiplySprite: Sprite = nil
  moneySprite: Sprite = nil

type Shop* = ref object of Panel
  tryPurchase: proc(item: Item, qty: int)

proc buy*(this: Shop, item: Item, qty: int)
proc createItem(this: Shop, item: Item, position: Position, scale: Vector, qty: int)

proc newShop*(tryPurchase: proc(item: Item, qty: int), onExit: proc()): Shop =
  result = Shop()
  initPanel(Panel(result))

  result.tryPurchase = tryPurchase

  # Load sprites to reuse
  shopBoardSprite = newSprite(Images.loadImage("./assets/shop_board.png", FILTER_NEAREST).image)

  pheedSprite = newSprite(Images.loadImage("./assets/pheed_icon.png", FILTER_NEAREST).image)
  pheedSprite.offset.x = pheedSprite.size.x * 0.5

  waterSprite = newSprite(Images.loadImage("./assets/water_icon.png", FILTER_NEAREST).image)
  waterSprite.offset.x = waterSprite.size.x * 0.5

  nestSprite = newSprite(Images.loadImage("./assets/nest_icon.png", FILTER_NEAREST).image)
  nestSprite.offset.x = nestSprite.size.x * 0.5

  multiplySprite = newSprite(Images.loadImage("./assets/multiply.png", FILTER_NEAREST).image)
  moneySprite = newSprite(Images.loadImage("./assets/money.png", FILTER_NEAREST).image)

  shopFont = Fonts.load("./assets/fonts/kennypixel.ttf", 48).font

  let bgImage = newButton("./assets/storephront.png")
  result.size = bgImage.size
  result.add(bgImage)

  let title = newLabel("The Thriphty Pheasant", WHITE)
  title.position.y = -0.75
  result.add(title)

  # Create shop items

  result.createItem(PHEED, newPosition(-0.6, -0.22), vector(4, 4), 1)
  result.createItem(PHEED, newPosition(-0.6, 0.22), vector(4, 4), 10)
  result.createItem(PHEED, newPosition(-0.6, 0.72), vector(4, 4), 50)

  result.createItem(WATER, newPosition(0.0, -0.22), vector(4, 4), 1)
  result.createItem(WATER, newPosition(0.0, 0.22), vector(4, 4), 10)
  result.createItem(WATER, newPosition(0.0, 0.72), vector(4, 4), 50)

  result.createItem(NEST, newPosition(0.6, -0.22), vector(4.5, 4.5), 1)
  result.createItem(NEST, newPosition(0.6, 0.22), vector(4.5, 4.5), 10)
  result.createItem(NEST, newPosition(0.6, 0.72), vector(4.5, 4.5), 50)

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

proc createItem(this: Shop, item: Item, position: Position, scale: Vector, qty: int) =
  let board = newButton(shopBoardSprite)
  board.position = position
  this.add(board)
  board.onClick:
    this.buy(item, qty)

  let totalPrice: int = ITEM_PRICES[item] * qty

  var
    sprite: Sprite
    offset: float

  case item:
    of PHEED:
      sprite = pheedSprite
      offset = 0.18
    of WATER:
      sprite = waterSprite
      offset = 0.22
    of NEST:
      sprite = nestSprite
      offset = 0.2

  let itemButton = newButton(sprite)
  itemButton.scale = scale
  itemButton.position = newPosition(board.position.x - 0.25, board.position.y)
  this.add(itemButton)

  let multiply = newButton(multiplySprite)
  multiply.position.x = itemButton.position.x + offset
  multiply.position.y = itemButton.position.y
  this.add(multiply)

  let qtyLabel = newLabel($qty, WHITE)
  qtyLabel.font = shopFont
  qtyLabel.position.x = multiply.position.x + 0.08
  qtyLabel.position.y = multiply.position.y
  this.add(qtyLabel)

  let moneyImage = newButton(moneySprite)
  moneyImage.scale = vector(2.8, 2.8)
  moneyImage.position.x = qtyLabel.position.x + 0.08
  moneyImage.position.y = qtyLabel.position.y
  this.add(moneyImage)

  let priceLabel = newLabel($totalPrice, WHITE)
  priceLabel.font = shopFont
  priceLabel.position.x = moneyImage.position.x + 0.06 + (0.023 * floor(log10(float totalPrice)))
  priceLabel.position.y = moneyImage.position.y
  this.add(priceLabel)

proc buy*(this: Shop, item: Item, qty: int) =
  if this.tryPurchase != nil:
    this.tryPurchase(item, qty)

