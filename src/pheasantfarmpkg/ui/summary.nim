import shade

import strformat, tables

import panel, ui, button, label, format, ../egg
export ui, button, label

const distBetweenText = 0.40

type Summary* = ref object of Panel
  eggLabels: Table[EggKind, Label]
  totalLabel: Label

proc setupEggRow(this: Summary, eggKind: EggKind): Label =
  result = newLabel("00", WHITE)
  result.position.x = 0.65
  result.position.y = -0.4 + ord(eggKind) * 0.2

  let eggImage = newButton(newSprite(getEggImage(), 4, 1))
  eggImage.position.x = result.position.x - distBetweenText
  eggImage.position.y = result.position.y
  eggImage.sprite.frameCoords.x = ord(eggKind)
  eggImage.scale = vector(6.0, 6.0)
  this.add(eggImage)

  let priceLabel = newLabel(formatInt(EGG_PRICES[eggKind], 2), WHITE)
  priceLabel.position.x = -0.45
  priceLabel.position.y = result.position.y
  this.add(priceLabel)

  let multiply = newButton("./assets/multiply.png")
  multiply.position.x = priceLabel.position.x + 0.4
  multiply.position.y = priceLabel.position.y
  this.add(multiply)

  let moneyImage = newButton("./assets/money.png")
  moneyImage.scale = vector(2.8, 2.8)
  moneyImage.position.x = priceLabel.position.x - 0.33
  moneyImage.position.y = priceLabel.position.y
  this.add(moneyImage)

proc newSummary*(goToShop: proc()): Summary =
  result = Summary()
  initPanel(Panel(result))
  result.eggLabels = initTable[EggKind, Label]()

  let bgImage = newButton("./assets/summary_board.png")
  result.size = bgImage.size
  result.add(bgImage)

  let titleDaily = newLabel("Daily", WHITE)
  titleDaily.position.y = -0.85
  result.add(titleDaily)

  let titleSummary = newLabel("Summary", WHITE)
  titleSummary.position.y = -0.65
  result.add(titleSummary)

  for kind in EggKind.low .. EggKind.high:
    let label = result.setupEggRow(kind)
    result.add(label)
    result.eggLabels[kind] = label

  result.totalLabel = newLabel("Total: 0000", WHITE)
  result.totalLabel.position.y = 0.45
  result.add(result.totalLabel)

  let shopBoard = newButton("./assets/shop_board.png")
  shopBoard.scale = vector(0.75, 0.75)
  shopBoard.position.y = 0.75
  result.add(shopBoard)

  let this = result
  shopBoard.onClick:
    this.visible = false
    goToShop()

  let shopLabel = newLabel("Shop", WHITE)
  shopLabel.position.y = shopBoard.position.y
  result.add(shopLabel)

proc setEggCount*(this: Summary, eggCount: CountTable[EggKind]) =
  for kind, label in this.eggLabels.pairs():
    label.setText(formatInt(eggCount[kind], 2))

proc setTotal*(this: Summary, total: int) =
  this.totalLabel.setText("Total: " & $total)

