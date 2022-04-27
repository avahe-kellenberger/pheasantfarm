import shade

import menu, ui, button, label
export ui, button, label

type HUD* = ref object of Panel
  eggText: Label

proc newHUD*(): HUD =
  result = HUD()
  initPanel(Panel(result))

  let eggImage = newButton("./assets/egg.png")
  eggImage.scale = vector(6.0, 6.0)
  result.add(eggImage)

  result.eggText = newLabel("0")
  result.eggText.position.x = eggImage.position.x + 0.05
  result.eggText.position.y = eggImage.position.y
  result.add(result.eggText)

proc setEggCount*(this: HUD, count: int) =
  this.eggText.setText($count)

