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

proc setupEggRow(this: Summary, eggKind: EggKind, imageWidth: float): UIComponent =
  result = newUIComponent()
  result.width = imageWidth
  result.height = 48.0

  result.alignHorizontal = Alignment.SpaceEvenly
  result.alignVertical = Alignment.Center

  result.stackDirection = StackDirection.Horizontal

  let moneyImage = newUIImage("./assets/money.png", FILTER_NEAREST)
  moneyImage.scale = vector(2.8, 2.8)
  result.addChild(moneyImage)

  let font = getFont()
  let priceLabel = newText(font, formatInt(EGG_PRICES[eggKind], 2), WHITE, FILTER_NEAREST)
  priceLabel.textAlignHorizontal = TextAlignment.Center
  priceLabel.textAlignVertical = TextAlignment.Center
  result.addChild(priceLabel)

  let multiply = newUIImage("./assets/multiply.png", FILTER_NEAREST)
  result.addChild(multiply)

  let eggImage = newUISprite(newSprite(getEggImage(), 4, 1))
  eggImage.sprite.frameCoords.x = ord(eggKind)
  eggImage.scale = vector(6.0, 6.0)
  result.addChild(eggImage)

  let label = newText(font, "00", WHITE, FILTER_NEAREST)
  label.textAlignHorizontal = TextAlignment.Center
  label.textAlignVertical = TextAlignment.Center
  result.addChild(label)

  this.eggLabels[eggKind] = label

proc newSummary*(goToShop: proc()): Summary =
  result = Summary()
  initUIComponent(UIComponent(result))

  let bgImage = newUIImage("./assets/summary_board.png", FILTER_NEAREST)
  result.addChild(bgImage)

  result.width = bgImage.getImageWidth()
  result.height = bgImage.getImageHeight()
  result.alignHorizontal = Alignment.Center
  result.alignVertical = Alignment.Center

  bgImage.stackDirection = StackDirection.Vertical
  bgImage.alignHorizontal = Alignment.Center
  bgImage.alignVertical = Alignment.Center

  let font = getFont()

  let titleDaily = newText(font, "Daily", WHITE, FILTER_NEAREST)
  titleDaily.textAlignHorizontal = TextAlignment.Center
  titleDaily.textAlignVertical = TextAlignment.Center
  bgImage.addChild(titleDaily)

  let titleSummary = newText(font, "Summary", WHITE, FILTER_NEAREST)
  titleSummary.textAlignHorizontal = TextAlignment.Center
  titleSummary.textAlignVertical = TextAlignment.Center
  titleSummary.margin = margin(0, 0, 0, 24)
  bgImage.addChild(titleSummary)

  result.eggLabels = initTable[EggKind, UITextComponent]()
  for kind in EggKind.low .. EggKind.high:
    let label = result.setupEggRow(kind, bgImage.getImageWidth())
    bgImage.addChild(label)

  result.totalLabel = newText(font, "Total: 0000", WHITE, FILTER_NEAREST)
  result.totalLabel.textAlignHorizontal = TextAlignment.Center
  result.totalLabel.textAlignVertical = TextAlignment.Center
  result.totalLabel.margin = margin(0, 0, 0, 12)
  bgImage.addChild(result.totalLabel)

  let shopButton = newUIImage("./assets/shop_board.png", FILTER_NEAREST)
  shopButton.imageFit = Cover
  shopButton.scale = vector(0.75, 0.75)
  shopButton.alignHorizontal = Alignment.Center
  shopButton.alignVertical = Alignment.Center

  block taxes:
    let container = newUIComponent()
    container.width = bgImage.getImageWidth()
    container.height = 120.0
    container.stackDirection = StackDirection.Vertical
    container.alignHorizontal = Alignment.Center
    container.alignVertical = Alignment.Center

    let ipsBuildingIcon = newUIImage("./assets/ips.png", FILTER_NEAREST)
    ipsBuildingIcon.scale = vector(3.0, 3.0)

    let taxLabel = newText(font, "tax:", WHITE, FILTER_NEAREST)
    taxLabel.textAlignHorizontal = TextAlignment.Center
    taxLabel.textAlignVertical = TextAlignment.Center
    taxLabel.margin = margin(10, 0, 0, 0)

    let taxLabelContainer = newUIComponent()
    taxLabelContainer.width = bgImage.getImageWidth()
    # TODO: Using hack for height because of UIImage scaling bug.
    taxLabelContainer.height = ipsBuildingIcon.getImageHeight() * ipsBuildingIcon.scale.y + 10.0
    taxLabelContainer.stackDirection = StackDirection.Horizontal
    taxLabelContainer.alignHorizontal = Alignment.Center
    taxLabelContainer.alignVertical = Alignment.Center

    taxLabelContainer.addChild(ipsBuildingIcon)
    taxLabelContainer.addChild(taxLabel)
    # taxLabelContainer.margin = margin(0, 0, 0, 12)

    container.margin = margin(0, 0, 0, 12)
    container.addChild(taxLabelContainer)

    # TODO: The following 3 components are conditional upon the tax day.

    result.taxMoneyImage = newUIImage("./assets/money.png", FILTER_NEAREST)
    result.taxMoneyImage.scale = vector(2.8, 2.8)
    result.taxMoneyImage.margin = margin(0, 12, 0, 0)
    # container.addChild(result.taxMoneyImage)

    const taxColor = newColor(160, 20, 20)
    result.taxPriceLabel = newText(font, "0000", taxColor, FILTER_NEAREST)
    result.taxPriceLabel.textAlignHorizontal = TextAlignment.Center
    result.taxPriceLabel.textAlignVertical = TextAlignment.Center
    # bgImage.addChild(result.taxPriceLabel)

    result.daysTillTaxLabel = newText(font, "", taxColor, FILTER_NEAREST)
    result.daysTillTaxLabel.textAlignHorizontal = TextAlignment.Center
    result.daysTillTaxLabel.textAlignVertical = TextAlignment.Center
    container.addChild(result.daysTillTaxLabel)

    bgImage.addChild(container)

  let this = result
  shopButton.onPressed:
    this.visible = false
    goToShop()

  bgImage.addChild(shopButton)
  result.shopLabel = newText(font, "Shop", WHITE, FILTER_NEAREST)
  result.shopLabel.textAlignHorizontal = TextAlignment.Center
  result.shopLabel.textAlignVertical = TextAlignment.Center
  result.shopLabel.processInputEvents = false
  shopButton.addChild(result.shopLabel)

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

