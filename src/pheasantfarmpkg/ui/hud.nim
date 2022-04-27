import shade

import ../egg

import menu, ui, button, label
export ui, button, label

type HUD* = ref object of Panel
  eggTextWhite: Label
  eggTextGray: Label
  eggTextBlue: Label
  eggTextYellow: Label

proc newHUD*(): HUD =
  result = HUD()
  initPanel(Panel(result))

  let whiteEggImage = newButton(newSprite(getEggImage(), 4, 1))
  whiteEggImage.scale = vector(6.0, 6.0)
  result.add(whiteEggImage)

  result.eggTextWhite = newLabel("0")
  result.eggTextWhite.position.x = whiteEggImage.position.x + 0.05
  result.add(result.eggTextWhite)

  let grayEggImage = newButton(newSprite(getEggImage(), 4, 1))
  grayEggImage.position.x = whiteEggImage.position.x + 0.12
  grayEggImage.sprite.frameCoords.x = ord(EggKind.GRAY)
  grayEggImage.scale = vector(6.0, 6.0)
  result.add(grayEggImage)

  result.eggTextGray = newLabel("0")
  result.eggTextGray.position.x = grayEggImage.position.x + 0.05
  result.add(result.eggTextGray)

  let blueEggImage = newButton(newSprite(getEggImage(), 4, 1))
  blueEggImage.position.x = grayEggImage.position.x + 0.12
  blueEggImage.sprite.frameCoords.x = ord(EggKind.BLUE)
  blueEggImage.scale = vector(6.0, 6.0)
  result.add(blueEggImage)

  result.eggTextBlue = newLabel("0")
  result.eggTextBlue.position.x = blueEggImage.position.x + 0.05
  result.add(result.eggTextBlue)

  let yellowEggImage = newButton(newSprite(getEggImage(), 4, 1))
  yellowEggImage.position.x = blueEggImage.position.x + 0.12
  yellowEggImage.sprite.frameCoords.x = ord(EggKind.YELLOW)
  yellowEggImage.scale = vector(6.0, 6.0)
  result.add(yellowEggImage)

  result.eggTextYellow = newLabel("0")
  result.eggTextYellow.position.x = yellowEggImage.position.x + 0.05
  result.add(result.eggTextYellow)

proc setEggCount*(this: HUD, kind: EggKind, count: int) =
  case kind:
    of EggKind.WHITE:
      this.eggTextWhite.setText($count)
    of EggKind.GRAY:
      this.eggTextGray.setText($count)
    of EggKind.BLUE:
      this.eggTextBlue.setText($count)
    of EggKind.YELLOW:
      this.eggTextYellow.setText($count)

