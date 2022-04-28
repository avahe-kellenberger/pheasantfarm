import shade

import strformat

import panel, ui, label
export ui, label

const orangeColor = newColor(179, 89, 0)

type Overlay* = ref object of Panel
  dayLabel*: Label
  currentColor: Color

proc setDay*(this: Overlay, day: int)

proc newOverlay*(): Overlay =
  result = Overlay()
  initPanel(Panel(result))

  result.currentColor = newColor(0, 0, 0, 0)
  result.dayLabel = newLabel("01", WHITE)
  result.dayLabel.visible = false
  result.add(result.dayLabel)

proc formatInt(num, digits: int): string =
  let maxValue = 10 ^ digits - 1
  result = alignString($min(num, maxValue), digits, '/', '0')

proc setDay*(this: Overlay, day: int) =
  this.dayLabel.setText("Day " & formatInt(day, 2))

proc fadeOut*(this: Overlay, elapsed, fadeOutTime: float) =
  let timeRemainingRatio: float = min(1.0, (fadeOutTime - elapsed) / fadeOutTime)
  if timeRemainingRatio > 0.5:
    return
  elif not this.visible:
    this.visible = true

  if timeRemainingRatio > 0.2:
    # Render orange color
    let colorRatio = min(0.2, 0.5 - timeRemainingRatio) / 0.2
    this.currentColor = orangeColor
    this.currentColor.a = uint8(120 * colorRatio)
  else:
    # Render black color
    let colorRatio = 1.0 - min(1.0, timeRemainingRatio / 0.2)
    this.currentColor.r = uint8(lerp(orangeColor.r, 0, colorRatio))
    this.currentColor.g = uint8(lerp(orangeColor.g, 0, colorRatio))
    this.currentColor.b = uint8(lerp(orangeColor.b, 0, colorRatio))
    this.currentColor.a = uint8(lerp(120, 255, colorRatio))

proc fadeIn*(this: Overlay, elapsed, fadeInDuration: float) =
  this.currentColor = BLACK
  this.currentColor.a = uint8(lerp(255, 0, min(1.0, elapsed / fadeInDuration)))

method render*(this: Overlay, ctx: Target, callback: proc() = nil) =
  if this.visible:
    ctx.rectangleFilled(
      0,
      0,
      this.size.x,
      this.size.y,
      this.currentColor
    )

    procCall Panel(this).render(ctx, callback)

