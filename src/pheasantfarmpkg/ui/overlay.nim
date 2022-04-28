import shade

import strformat

import panel, ui, label
export ui, label

const orangeColor = newColor(179, 89, 0)

type Overlay* = ref object of Panel
  dayLabel*: Label
  currentColor: Color
  startedFadeToBlack: bool
  animationPlayer*: AnimationPlayer

proc setDay*(this: Overlay, day: int)
proc createFadeOutAnimation(this: Overlay): Animation
proc createFadeInAnimation(this: Overlay): Animation

proc newOverlay*(onFadeInFinished: proc()): Overlay =
  result = Overlay()
  initPanel(Panel(result))

  result.currentColor = newColor(0, 0, 0, 0)
  result.dayLabel = newLabel("01", WHITE)
  result.dayLabel.visible = false
  result.add(result.dayLabel)

  result.animationPlayer = newAnimationPlayer()

  let this = result

  let fadeOutAnim = result.createFadeOutAnimation()
  result.animationPlayer.addAnimation("fade-out", fadeOutAnim)

  let fadeInAnim = result.createFadeInAnimation()
  fadeInAnim.onFinished:
    onFadeInFinished()
    this.visible = false
  result.animationPlayer.addAnimation("fade-in", fadeInAnim)

proc createFadeOutAnimation(this: Overlay): Animation =
  let anim = newAnimation(15, false)

  var
    startingColor = orangeColor
    darkerOrange = orangeColor
    nightColor = BLACK

  startingColor.a = 0
  darkerOrange.a = 120
  nightColor.a = 175

  let frames: seq[KeyFrame[Color]] = @[
    (startingColor, 0.0),
    (darkerOrange, 6.0),
    (nightColor, 11.0),
    (nightColor, 14.5),
    (BLACK, 15.0)
  ]

  proc fadeMusic() {.closure.} =
    fadeOutMusic(0.5)

  let procFrames: seq[KeyFrame[ClosureProc]] = @[(fadeMusic, 14.5)]

  anim.addNewAnimationTrack(this.currentColor, frames)
  anim.addProcTrack(procFrames)
  return anim

proc createFadeInAnimation(this: Overlay): Animation =
  let
    anim = newAnimation(3.0, false)
    endColor = newColor(0, 0, 0, 0)
    frames: seq[KeyFrame[Color]] = @[
      (BLACK, 0.0),
      (BLACK, 2.5),
      (endColor, anim.duration)
    ]

    visibilityFrames: seq[KeyFrame[bool]] = @[
      (true, 0.0),
      (false, 2.0)
    ]

  anim.addNewAnimationTrack(this.currentColor, frames)
  anim.addNewAnimationTrack(this.dayLabel.visible, visibilityFrames)
  return anim

proc formatInt(num, digits: int): string =
  let maxValue = 10 ^ digits - 1
  result = alignString($min(num, maxValue), digits, '/', '0')

proc setDay*(this: Overlay, day: int) =
  this.dayLabel.setText("Day " & formatInt(day, 2))

proc update*(this: Overlay, deltaTime: float) =
  this.animationPlayer.update(deltaTime)

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

