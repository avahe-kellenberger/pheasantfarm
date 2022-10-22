import shade

import format, fontloader, ../egg

type HUD* = ref object of UIComponent
  dayLabel: UITextComponent
  timeRemainingLabel: UITextComponent
  moneyLabel: UITextComponent
  eggTextWhite: UITextComponent
  eggTextPurple: UITextComponent
  eggTextBlue: UITextComponent
  eggTextGolden: UITextComponent

proc setEggCount*(this: HUD, kind: EggKind, count: int)

proc wrap(components: varargs[UIComponent]): UIComponent =
  result = newUIComponent()
  result.stackDirection = Horizontal
  result.alignHorizontal = Alignment.Start
  result.alignVertical = Alignment.Center

  for component in components:
    result.addChild(component)

proc newHUD*(): HUD =
  result = HUD()
  initUIComponent(UIComponent result)

  let (_, hudImage) = Images.loadImage("./assets/hud.png")
  hudImage.setImageFilter(FILTER_NEAREST)

  result.width = float hudImage.w
  result.height = float hudImage.h

  let font = getFont()

  let bgImage = newUIImage(hudImage)
  result.addChild(bgImage)
  bgImage.imageAlignVertical = ImageAlignment.Center
  bgImage.imageAlignHorizontal = ImageAlignment.Center
  bgImage.stackDirection = StackDirection.Horizontal
  bgImage.alignVertical = SpaceEvenly
  bgImage.alignHorizontal = SpaceEvenly
  bgImage.padding = 10.0

  block day:
    let sun = newUIImage("./assets/sun.png", FILTER_NEAREST)
    sun.scale = vector(3, 3)
    sun.margin = margin(0, 0, 5, 0)

    result.dayLabel = newText(font, "01", WHITE)
    result.dayLabel.margin = margin(0, 0, 0, 0)
    result.dayLabel.textAlignVertical = TextAlignment.Center

    let wrapper = wrap(sun, result.dayLabel)
    wrapper.height = 64.0
    wrapper.width = 100.0
    bgImage.addChild(wrapper)

  block time:
    let hourglass = newUIImage("./assets/hourglass.png", FILTER_NEAREST)
    hourglass.scale = vector(3.5, 3.5)
    hourglass.margin = margin(0, 0, 5, 0)

    result.timeRemainingLabel = newText(font, "", WHITE)
    result.timeRemainingLabel.margin = margin(0, 0, 0, 0)
    result.timeRemainingLabel.textAlignVertical = TextAlignment.Center

    let wrapper = wrap(hourglass, result.timeRemainingLabel)
    wrapper.height = 64.0
    wrapper.width = 100.0
    bgImage.addChild(wrapper)

  block currency:
    let money = newUIImage("./assets/money.png", FILTER_NEAREST)
    money.scale = vector(3.5, 3.5)
    money.margin = margin(0, 0, 5, 0)

    result.moneyLabel = newText(font, "", WHITE)
    result.moneyLabel.margin = margin(0, 0, 0, 0)
    result.moneyLabel.textAlignVertical = TextAlignment.Center

    let wrapper = wrap(money, result.moneyLabel)
    wrapper.height = 64.0
    wrapper.width = 160.0
    bgImage.addChild(wrapper)

  # Eggs

  block whiteEgg:
    let whiteEggImage = newUISprite(newSprite(getEggImage(), 4, 1))
    whiteEggImage.margin = margin(0, 0, 5, 0)
    whiteEggImage.scale = vector(6.0, 6.0)

    result.eggTextWhite = newText(font, "", WHITE)
    result.eggTextWhite.margin = margin(0, 0, 0, 0)
    result.eggTextWhite.textAlignVertical = TextAlignment.Center

    let wrapper = wrap(whiteEggImage, result.eggTextWhite)
    wrapper.height = 64.0
    wrapper.width = 85.0
    bgImage.addChild(wrapper)

  block purpleEgg:
    let purpleEggImage = newUISprite(newSprite(getEggImage(), 4, 1))
    purpleEggImage.margin = margin(0, 0, 5, 0)
    purpleEggImage.sprite.frameCoords.x = ord(EggKind.PURPLE)
    purpleEggImage.scale = vector(6.0, 6.0)

    result.eggTextPurple = newText(font, "", WHITE)
    result.eggTextPurple.margin = margin(0, 0, 0, 0)
    result.eggTextPurple.textAlignVertical = TextAlignment.Center

    let wrapper = wrap(purpleEggImage, result.eggTextPurple)
    wrapper.height = 64.0
    wrapper.width = 85.0
    bgImage.addChild(wrapper)

  block blueEgg:
    let blueEggImage = newUISprite(newSprite(getEggImage(), 4, 1))
    blueEggImage.margin = margin(0, 0, 5, 0)
    blueEggImage.sprite.frameCoords.x = ord(EggKind.BLUE)
    blueEggImage.scale = vector(6.0, 6.0)

    result.eggTextBlue = newText(font, "", WHITE)
    result.eggTextBlue.margin = margin(0, 0, 0, 0)
    result.eggTextBlue.textAlignVertical = TextAlignment.Center

    let wrapper = wrap(blueEggImage, result.eggTextBlue)
    wrapper.height = 64.0
    wrapper.width = 85.0
    bgImage.addChild(wrapper)

  block goldenEgg:
    let goldenEggImage = newUISprite(newSprite(getEggImage(), 4, 1))
    goldenEggImage.margin = margin(0, 0, 5, 0)
    goldenEggImage.sprite.frameCoords.x = ord(EggKind.GOLDEN)
    goldenEggImage.scale = vector(6.0, 6.0)

    result.eggTextGolden = newText(font, "", WHITE)
    result.eggTextGolden.textAlignVertical = TextAlignment.Center
    result.moneyLabel.margin = margin(0, 0, 0, 0)

    let wrapper = wrap(goldenEggImage, result.eggTextGolden)
    wrapper.height = 64.0
    wrapper.width = 85.0
    bgImage.addChild(wrapper)

  for eggKind in EggKind.low .. EggKind.high:
    result.setEggCount(eggKind, 0)

proc setDay*(this: HUD, day: int) =
  this.dayLabel.text = formatInt(day, 2)

proc setTimeRemaining*(this: HUD, timeInSeconds: int) =
  this.timeRemainingLabel.text = formatInt(timeInSeconds, 2)

proc setMoney*(this: HUD, money: int) =
  var displayValue = money
  if displayValue < 0:
    displayValue = 0
    this.moneyLabel.color = RED
  else:
    this.moneyLabel.color = WHITE
  this.moneyLabel.text = formatInt(displayValue, 5)

proc setEggCount*(this: HUD, kind: EggKind, count: int) =
  case kind:
    of EggKind.WHITE:
      this.eggTextWhite.text = formatInt(count, 2)
    of EggKind.PURPLE:
      this.eggTextPurple.text = formatInt(count, 2)
    of EggKind.BLUE:
      this.eggTextBlue.text = formatInt(count, 2)
    of EggKind.GOLDEN:
      this.eggTextGolden.text = formatInt(count, 2)

