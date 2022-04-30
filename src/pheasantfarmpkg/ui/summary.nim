import shade

import strformat, tables

import panel, ui, button, label, format, ../egg
export ui, button, label

const distBetweenText = 0.40

type Summary* = ref object of Panel
  eggLabels: Table[EggKind, Label]
  totalLabel: Label
  taxPriceLabel: Label
  daysTillTaxLabel: Label
  taxMoneyImage: Button
  shopLabel: Label

proc setupEggRow(this: Summary, eggKind: EggKind): Label =
  result = newLabel("00", WHITE)
  result.position.x = 0.65
  result.position.y = -0.5 + ord(eggKind) * 0.15

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
  titleSummary.position.y = -0.7
  result.add(titleSummary)

  for kind in EggKind.low .. EggKind.high:
    let label = result.setupEggRow(kind)
    result.add(label)
    result.eggLabels[kind] = label

  result.totalLabel = newLabel("Total: 0000", WHITE)
  result.totalLabel.position.y = result.eggLabels[EggKind.GOLDEN].position.y + 0.2
  result.add(result.totalLabel)

  let shopButton = newButton("./assets/shop_board.png")
  shopButton.scale = vector(0.75, 0.75)
  shopButton.position.y = 0.8
  result.add(shopButton)

  # Taxes

  let ipsBuildingIcon = newButton("./assets/ips.png")
  ipsBuildingIcon.scale = vector(3.0, 3.0)
  ipsBuildingIcon.position.x = -0.3
  ipsBuildingIcon.position.y = 0.38
  result.add(ipsBuildingIcon)

  let taxLabel = newLabel("tax:", WHITE)
  taxLabel.position.x = 0.25
  taxLabel.position.y = ipsBuildingIcon.position.y
  result.add(taxLabel)

  result.taxMoneyImage = newButton("./assets/money.png")
  result.taxMoneyImage.scale = vector(2.8, 2.8)
  result.taxMoneyImage.position.x = -0.67
  result.taxMoneyImage.position.y = ipsBuildingIcon.position.y + 0.15
  result.add(result.taxMoneyImage)

  const taxColor = newColor(160, 20, 20)
  result.taxPriceLabel = newLabel("0000", taxColor)
  result.taxPriceLabel.position.x = result.taxMoneyImage.position.x + 0.82
  result.taxPriceLabel.position.y = result.taxMoneyImage.position.y
  result.add(result.taxPriceLabel)

  result.daysTillTaxLabel = newLabel("", taxColor)
  result.daysTillTaxLabel.position.y = result.taxPriceLabel.position.y + 0.04
  result.add(result.daysTillTaxLabel)

  let this = result
  shopButton.onClick:
    this.visible = false
    goToShop()

  result.shopLabel = newLabel("Shop", WHITE)
  result.shopLabel.position.y = shopButton.position.y
  result.add(result.shopLabel)

proc setEggCount*(this: Summary, eggCount: CountTable[EggKind]) =
  for kind, label in this.eggLabels.pairs():
    label.setText(formatInt(eggCount[kind], 2))

proc setTotal*(this: Summary, total: int) =
  this.totalLabel.setText("Total: " & $total)

proc setTaxPrice*(this: Summary, tax: int) =
  this.taxPriceLabel.setText("-" & formatInt(tax, 6))

proc updateDaysTillTax*(this: Summary, currentDay, taxDayFrequency: int) =
  let
    dayMod = currentDay mod taxDayFrequency
    daysTill = taxDayFrequency - dayMod

  if dayMod != 0:
    this.daysTillTaxLabel.visible = true
    if daysTill == 1:
      this.daysTillTaxLabel.setText($daysTill & " day left")
    else:
      this.daysTillTaxLabel.setText($daysTill & " days left")
    this.taxMoneyImage.visible = false
    this.taxPriceLabel.visible = false
  else:
    this.daysTillTaxLabel.visible = false
    this.taxMoneyImage.visible = true
    this.taxPriceLabel.visible = true

proc setOutOfFunds*(this: Summary) =
  this.shopLabel.setText("Next")

