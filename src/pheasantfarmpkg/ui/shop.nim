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

type Shop* = ref object of UIImage
  tryPurchase: proc(item: Item, qty: int)

proc buy*(this: Shop, item: Item, qty: int)
proc createItem(this: Shop, parent: UIComponent, item: Item, qty: int)

proc newShop*(tryPurchase: proc(item: Item, qty: int), onExit: proc()): Shop =
  result = Shop(tryPurchase: tryPurchase)
  result.padding = 36.0
  let bgImage = Images.loadImage("./assets/storephront.png").image
  initUIImage(UIImage(result), bgImage)
  result.alignHorizontal = Alignment.Center

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

  shopFont = Fonts.load("./assets/fonts/kennypixel.ttf", 72).font

  let title = newText(shopFont, "The Thriphty Pheasant", WHITE)
  result.addChild(title)

  # Create shop items
  let itemsContainer = newUIComponent()
  itemsContainer.stackDirection = StackDirection.Horizontal
  itemsContainer.alignHorizontal = Alignment.Center
  itemsContainer.alignVertical = Alignment.Center

  block:
    let pheedContainer = newUIComponent()
    itemsContainer.addChild(pheedContainer)

    pheedContainer.alignHorizontal = Alignment.Center
    pheedContainer.alignVertical = Alignment.Center
    result.createItem(pheedContainer, PHEED, 1)
    result.createItem(pheedContainer, PHEED, 10)
    result.createItem(pheedContainer, PHEED, 50)

    let waterContainer = newUIComponent()
    itemsContainer.addChild(waterContainer)

    waterContainer.alignHorizontal = Alignment.Center
    waterContainer.alignVertical = Alignment.Center
    result.createItem(waterContainer, WATER, 1)
    result.createItem(waterContainer, WATER, 10)
    result.createItem(waterContainer, WATER, 50)

    let nestContainer = newUIComponent()
    itemsContainer.addChild(nestContainer)

    nestContainer.alignHorizontal = Alignment.Center
    nestContainer.alignVertical = Alignment.Center
    result.createItem(nestContainer, NEST, 1)
    result.createItem(nestContainer, NEST, 10)
    result.createItem(nestContainer, NEST, 50)

    itemsContainer.height = nestContainer.height

  result.addChild(itemsContainer)

  let exitButton = newUISprite(shopBoardSprite)
  exitButton.imageFit = Cover
  exitButton.alignHorizontal = Alignment.Center
  exitButton.alignVertical = Alignment.Center

  let exitLabel = newText(shopFont, "Next Day", WHITE, FILTER_NEAREST)
  exitLabel.textAlignHorizontal = TextAlignment.Center
  exitLabel.textAlignVertical = TextAlignment.Center
  exitLabel.processInputEvents = false
  exitButton.addChild(exitLabel)

  result.addChild(exitButton)

  let this = result
  exitButton.onPressed:
    this.visible = false
    onExit()

proc createItem(this: Shop, parent: UIComponent, item: Item, qty: int) =
  let board = newUISprite(shopBoardSprite)
  board.margin = margin(0, 12.0, 0, 12.0)
  board.stackDirection = StackDirection.Overlap
  parent.addChild(board)
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
  board.addChild(itemButton)

  let multiply = newUISprite(multiplySprite)
  # multiply.position.x = itemButton.position.x + 0.18
  # multiply.position.y = itemButton.position.y
  board.addChild(multiply)

  let qtyLabel = newText(shopFont, $qty, WHITE)
  # qtyLabel.position.x = multiply.position.x + 0.08
  # qtyLabel.position.y = multiply.position.y
  board.addChild(qtyLabel)

  let moneyImage = newUISprite(moneySprite)
  moneyImage.scale = vector(2.8, 2.8)
  # moneyImage.position.x = qtyLabel.position.x + 0.08
  # moneyImage.position.y = qtyLabel.position.y
  board.addChild(moneyImage)

  let priceLabel = newText(shopFont, $totalPrice, WHITE)
  # priceLabel.position.x = moneyImage.position.x + 0.06 + (0.023 * floor(log10(float totalPrice)))
  # priceLabel.position.y = moneyImage.position.y
  board.addChild(priceLabel)

proc buy*(this: Shop, item: Item, qty: int) =
  if this.tryPurchase != nil:
    this.tryPurchase(item, qty)

