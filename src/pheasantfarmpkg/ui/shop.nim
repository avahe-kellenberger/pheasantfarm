import shade
import std/tables
import ../items

var
  shopFont: Font
  shopBoardSprite: Sprite = nil
  pheedSprite: Sprite = nil
  waterSprite: Sprite = nil
  nestSprite: Sprite = nil
  multiplySprite: Sprite = nil
  moneySprite: Sprite = nil

type Shop* = ref object of UIComponent
  tryPurchase: proc(item: Item, qty: int)

proc buy*(this: Shop, item: Item, qty: int)
proc createItem(this: Shop, item: Item, qty: int)

proc newShop*(tryPurchase: proc(item: Item, qty: int), onExit: proc()): Shop =
  result = Shop()
  initUIComponent(UIComponent(result))

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

  let bgImage = newUIImage("./assets/storephront.png")
  result.width = bgImage.width
  result.height = bgImage.height
  result.addChild(bgImage)

  let title = newText(shopFont, "The Thriphty Pheasant", WHITE)
  # TODO: title.position.y = -0.75
  result.addChild(title)

  # Create shop items

  const
    topBoardYPosition = -0.28
    yDistance = 0.44

  # result.createItem(PHEED, newPosition(-0.6, topBoardYPosition), 1)
  # result.createItem(PHEED, newPosition(-0.6, topBoardYPosition + yDistance), 10)
  # result.createItem(PHEED, newPosition(-0.6, topBoardYPosition + yDistance * 2), 50)

  # result.createItem(WATER, newPosition(0.0, topBoardYPosition), 1)
  # result.createItem(WATER, newPosition(0.0, topBoardYPosition + yDistance), 10)
  # result.createItem(WATER, newPosition(0.0, topBoardYPosition + yDistance * 2), 50)

  # result.createItem(NEST, newPosition(0.6, topBoardYPosition), 1)
  # result.createItem(NEST, newPosition(0.6, topBoardYPosition + yDistance), 10)
  # result.createItem(NEST, 50)

  result.createItem(PHEED, 1)
  result.createItem(PHEED, 10)
  result.createItem(PHEED, 50)

  result.createItem(WATER, 1)
  result.createItem(WATER, 10)
  result.createItem(WATER, 50)

  result.createItem(NEST, 1)
  result.createItem(NEST, 10)
  result.createItem(NEST, 50)

  let
    (_, exitImage) = Images.loadImage("./assets/x.png")
    exitSprite = newSprite(exitImage)
    exitButton = newUISprite(exitSprite)

  exitSprite.offset.x = -10
  exitSprite.offset.y = 10
  exitButton.scale = vector(0.5, 0.5)
  # exitButton.position = newPosition(1, -1)
  result.addChild(exitButton)

  let this = result
  exitButton.onPressed:
    this.visible = false
    onExit()

proc createItem(this: Shop, item: Item, qty: int) =
  let board = newUISprite(shopBoardSprite)
  # board.position = position
  this.addChild(board)
  board.onPressed:
    this.buy(item, qty)

  let totalPrice: int = ITEM_PRICES[item] * qty

  let sprite =
    case item:
      of PHEED:
        pheedSprite
      of WATER:
        waterSprite
      of NEST:
        nestSprite

  let itemButton = newUISprite(sprite)
  itemButton.scale = vector(3, 3)
  # itemButton.position = newPosition(board.position.x - 0.25, board.position.y)
  this.addChild(itemButton)

  let multiply = newUISprite(multiplySprite)
  # multiply.position.x = itemButton.position.x + 0.18
  # multiply.position.y = itemButton.position.y
  this.addChild(multiply)

  let qtyLabel = newText(shopFont, $qty, WHITE)
  # qtyLabel.position.x = multiply.position.x + 0.08
  # qtyLabel.position.y = multiply.position.y
  this.addChild(qtyLabel)

  let moneyImage = newUISprite(moneySprite)
  moneyImage.scale = vector(2.8, 2.8)
  # moneyImage.position.x = qtyLabel.position.x + 0.08
  # moneyImage.position.y = qtyLabel.position.y
  this.addChild(moneyImage)

  let priceLabel = newText(shopFont, $totalPrice, WHITE)
  # priceLabel.position.x = moneyImage.position.x + 0.06 + (0.023 * floor(log10(float totalPrice)))
  # priceLabel.position.y = moneyImage.position.y
  this.addChild(priceLabel)

proc buy*(this: Shop, item: Item, qty: int) =
  if this.tryPurchase != nil:
    this.tryPurchase(item, qty)

