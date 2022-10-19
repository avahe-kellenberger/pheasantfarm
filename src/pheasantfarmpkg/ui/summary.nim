import shade

import std/tables

import ../egg, fontloader, format

type Summary* = ref object of UIComponent
  eggLabels: Table[EggKind, UITextComponent]
  totalLabel: UITextComponent
  taxPriceLabel: UITextComponent
  daysTillTaxLabel: UITextComponent
  taxMoneyImage: UIImage
  shopLabel: UITextComponent

proc setupEggRow(this: Summary, eggKind: EggKind): UITextComponent =
  let font = getFont()
  result = newText(font, "00", WHITE)
  # result.position.x = 0.55
  # result.position.y = -0.5 + ord(eggKind) * 0.15

  let eggImage = newUISprite(newSprite(getEggImage(), 4, 1))
  # eggImage.position.x = result.position.x - 0.48
  # eggImage.position.y = result.position.y
  eggImage.sprite.frameCoords.x = ord(eggKind)
  eggImage.scale = vector(6.0, 6.0)
  this.addChild(eggImage)

  let priceLabel = newText(font, formatInt(EGG_PRICES[eggKind], 2), WHITE)
  # priceLabel.position.x = -0.45
  # priceLabel.position.y = result.position.y
  this.addChild(priceLabel)

  let multiply = newUIImage("./assets/multiply.png")
  # multiply.position.x = priceLabel.position.x + 0.30
  # multiply.position.y = priceLabel.position.y
  this.addChild(multiply)

  let moneyImage = newUIImage("./assets/money.png")
  moneyImage.scale = vector(2.8, 2.8)
  # moneyImage.position.x = priceLabel.position.x - 0.33
  # moneyImage.position.y = priceLabel.position.y
  this.addChild(moneyImage)

proc newSummary*(goToShop: proc()): Summary =
  result = Summary()
  initUIComponent(UIComponent(result))
  result.eggLabels = initTable[EggKind, UITextComponent]()

  let font = getFont()

  let bgImage = newUIImage("./assets/summary_board.png")
  result.width = float bgImage.image.w
  result.height = float bgImage.image.h
  result.addChild(bgImage)

  let titleDaily = newText(font, "Daily", WHITE)
  # titleDaily.position.y = -0.85
  result.addChild(titleDaily)

  let titleSummary = newText(font, "Summary", WHITE)
  # titleSummary.position.y = -0.7
  result.addChild(titleSummary)

  for kind in EggKind.low .. EggKind.high:
    let label = result.setupEggRow(kind)
    result.addChild(label)
    result.eggLabels[kind] = label

  result.totalLabel = newText(font, "Total: 0000", WHITE)
  # result.totalLabel.position.y = result.eggLabels[EggKind.GOLDEN].position.y + 0.2
  result.addChild(result.totalLabel)

  let shopButton = newUIImage("./assets/shop_board.png")
  shopButton.scale = vector(0.75, 0.75)
  # shopButton.position.y = 0.8
  result.addChild(shopButton)

  # Taxes

  let ipsBuildingIcon = newUIImage("./assets/ips.png")
  ipsBuildingIcon.scale = vector(3.0, 3.0)
  # ipsBuildingIcon.position.x = -0.3
  # ipsBuildingIcon.position.y = 0.38
  result.addChild(ipsBuildingIcon)

  let taxLabel = newText(font, "tax:", WHITE)
  # taxLabel.position.x = 0.25
  # taxLabel.position.y = ipsBuildingIcon.position.y
  result.addChild(taxLabel)

  result.taxMoneyImage = newUIImage("./assets/money.png")
  result.taxMoneyImage.scale = vector(2.8, 2.8)
  # result.taxMoneyImage.position.x = -0.67
  # result.taxMoneyImage.position.y = ipsBuildingIcon.position.y + 0.15
  result.addChild(result.taxMoneyImage)

  const taxColor = newColor(160, 20, 20)
  result.taxPriceLabel = newText(font, "0000", taxColor)
  # result.taxPriceLabel.position.x = result.taxMoneyImage.position.x + 0.82
  # result.taxPriceLabel.position.y = result.taxMoneyImage.position.y
  result.addChild(result.taxPriceLabel)

  result.daysTillTaxLabel = newText(font, "", taxColor)
  # result.daysTillTaxLabel.position.y = result.taxPriceLabel.position.y + 0.04
  result.addChild(result.daysTillTaxLabel)

  let this = result
  shopButton.onPressed:
    this.visible = false
    goToShop()

  result.shopLabel = newText(font, "Shop", WHITE)
  # result.shopLabel.position.y = shopButton.position.y
  result.addChild(result.shopLabel)

proc setEggCount*(this: Summary, eggCount: CountTable[EggKind]) =
  for kind, label in this.eggLabels.pairs():
    label.text = formatInt(eggCount[kind], 3)

proc setTotal*(this: Summary, total: int) =
  this.totalLabel.text = "Total: " & $total

proc setTaxPrice*(this: Summary, tax: int) =
  this.taxPriceLabel.text = "-" & formatInt(tax, 6)

proc updateDaysTillTax*(this: Summary, currentDay, taxDayFrequency: int) =
  let
    dayMod = currentDay mod taxDayFrequency
    daysTill = taxDayFrequency - dayMod

  if dayMod != 0:
    this.daysTillTaxLabel.visible = true
    if daysTill == 1:
      this.daysTillTaxLabel.text = $daysTill & " day left"
    else:
      this.daysTillTaxLabel.text = $daysTill & " days left"
    this.taxMoneyImage.visible = false
    this.taxPriceLabel.visible = false
  else:
    this.daysTillTaxLabel.visible = false
    this.taxMoneyImage.visible = true
    this.taxPriceLabel.visible = true

proc setOutOfFunds*(this: Summary) =
  this.shopLabel.text = "Next"

