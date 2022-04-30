import shade

import strformat

import panel, ui, button, label, format, ../egg
export ui, button, label

type HUD* = ref object of Panel
  dayLabel: Label
  timeRemainingLabel: Label
  moneyLabel: Label
  eggTextWhite: Label
  eggTextPurple: Label
  eggTextBlue: Label
  eggTextGolden: Label

proc setEggCount*(this: HUD, kind: EggKind, count: int)

proc newHUD*(): HUD =
  result = HUD()
  initPanel(Panel(result))

  let bgImage = newButton("./assets/hud.png")
  result.size = bgImage.size
  result.add(bgImage)

  # Time

  let sun = newButton("./assets/sun.png")
  sun.scale = vector(3, 3)
  sun.position.x = -0.9
  result.add(sun)

  result.dayLabel = newLabel("01", WHITE)
  result.dayLabel.position.x = sun.position.x + 0.12
  result.add(result.dayLabel)

  let hourglass = newButton("./assets/hourglass.png")
  hourglass.scale = vector(3.5, 3.5)
  hourglass.position.x = result.dayLabel.position.x + 0.12
  result.add(hourglass)

  result.timeRemainingLabel = newLabel("", WHITE)
  result.timeRemainingLabel.position.x = hourglass.position.x + 0.11
  result.add(result.timeRemainingLabel)

  let moneyImage = newButton("./assets/money.png")
  moneyImage.scale = vector(3.5, 3.5)
  moneyImage.position.x = result.timeRemainingLabel.position.x + 0.12
  result.add(moneyImage)

  result.moneyLabel = newLabel("", WHITE)
  result.moneyLabel.position.x = moneyImage.position.x + 0.20
  result.add(result.moneyLabel)

  # Eggs

  const distBetweenEggIcons = 0.12

  result.eggTextGolden = newLabel("", WHITE)
  result.eggTextGolden.position.x = 0.9
  result.add(result.eggTextGolden)

  let goldenEggImage = newButton(newSprite(getEggImage(), 4, 1))
  goldenEggImage.position.x = result.eggTextGolden.position.x - distBetweenEggIcons
  goldenEggImage.sprite.frameCoords.x = ord(EggKind.GOLDEN)
  goldenEggImage.scale = vector(6.0, 6.0)
  result.add(goldenEggImage)

  result.eggTextBlue = newLabel("", WHITE)
  result.eggTextBlue.position.x = goldenEggImage.position.x - distBetweenEggIcons
  result.add(result.eggTextBlue)

  let blueEggImage = newButton(newSprite(getEggImage(), 4, 1))
  blueEggImage.position.x = result.eggTextBlue.position.x - distBetweenEggIcons
  blueEggImage.sprite.frameCoords.x = ord(EggKind.BLUE)
  blueEggImage.scale = vector(6.0, 6.0)
  result.add(blueEggImage)

  result.eggTextPurple = newLabel("", WHITE)
  result.eggTextPurple.position.x = blueEggImage.position.x - distBetweenEggIcons
  result.add(result.eggTextPurple)

  let purpleEggImage = newButton(newSprite(getEggImage(), 4, 1))
  purpleEggImage.position.x = result.eggTextPurple.position.x - distBetweenEggIcons
  purpleEggImage.sprite.frameCoords.x = ord(EggKind.PURPLE)
  purpleEggImage.scale = vector(6.0, 6.0)
  result.add(purpleEggImage)

  result.eggTextWhite = newLabel("", WHITE)
  result.eggTextWhite.position.x = purpleEggImage.position.x - distBetweenEggIcons
  result.add(result.eggTextWhite)

  let whiteEggImage = newButton(newSprite(getEggImage(), 4, 1))
  whiteEggImage.position.x = result.eggTextWhite.position.x - distBetweenEggIcons
  whiteEggImage.scale = vector(6.0, 6.0)
  result.add(whiteEggImage)

  for eggKind in EggKind.low .. EggKind.high:
    result.setEggCount(eggKind, 0)

proc setDay*(this: HUD, day: int) =
  this.dayLabel.setText(formatInt(day, 2))

proc setTimeRemaining*(this: HUD, timeInSeconds: int) =
  this.timeRemainingLabel.setText(formatInt(timeInSeconds, 2))

proc setMoney*(this: HUD, money: int) =
  var displayValue = money
  if displayValue < 0:
    displayValue = 0
    this.moneyLabel.setColor(RED)
  this.moneyLabel.setText(formatInt(displayValue, 5))

proc setEggCount*(this: HUD, kind: EggKind, count: int) =
  case kind:
    of EggKind.WHITE:
      this.eggTextWhite.setText(formatInt(count, 2))
    of EggKind.PURPLE:
      this.eggTextPurple.setText(formatInt(count, 2))
    of EggKind.BLUE:
      this.eggTextBlue.setText(formatInt(count, 2))
    of EggKind.GOLDEN:
      this.eggTextGolden.setText(formatInt(count, 2))

