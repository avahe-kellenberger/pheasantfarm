import shade

import format, fontloader

const orangeColor = newColor(179, 89, 0)

type Overlay* = ref object of UIComponent
  dayLabel*: UITextComponent
  currentColor: Color
  startedFadeToBlack: bool
  animationPlayer*: AnimationPlayer

proc setDay*(this: Overlay, day: int)
proc createFadeOutAnimation(this: Overlay, fadeTime: float): Animation
proc createFadeInAnimation(this: Overlay): Animation

proc newOverlay*(fadeTime: float, onFadeOutFinished: proc(), onFadeInFinished: proc()): Overlay =
  result = Overlay()
  initUIComponent(UIComponent result)
  result.alignVertical = Alignment.Center
  result.alignHorizontal = Alignment.Center

  result.currentColor = newColor(0, 0, 0, 0)
  result.dayLabel = newText(getFont(), "01", WHITE)
  result.dayLabel.visible = false
  result.addChild(result.dayLabel)
  result.dayLabel.determineWidthAndHeight()

  result.animationPlayer = newAnimationPlayer()

  let this = result
  this.processInputEvents = false

  let fadeOutAnim = result.createFadeOutAnimation(fadeTime)
  fadeOutAnim.onFinished:
    onFadeOutFinished()
  result.animationPlayer.addAnimation("fade-out", fadeOutAnim)

  let fadeInAnim = result.createFadeInAnimation()
  fadeInAnim.onFinished:
    onFadeInFinished()
    this.visible = false
  result.animationPlayer.addAnimation("fade-in", fadeInAnim)

proc createFadeOutAnimation(this: Overlay, fadeTime: float): Animation =
  let anim = newAnimation(fadeTime, false)

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

    textVisibilityFrames: seq[KeyFrame[bool]] = @[
      (true, 0.0),
      (false, 2.0)
    ]

  anim.addNewAnimationTrack(this.currentColor, frames)
  anim.addNewAnimationTrack(this.dayLabel.visible, textVisibilityFrames)
  return anim

proc setDay*(this: Overlay, day: int) =
  this.dayLabel.text = "Day " & $day

proc update*(this: Overlay, deltaTime: float) =
  this.animationPlayer.update(deltaTime)

method preRender*(this: Overlay, ctx: Target, clippedRenderBounds: AABB) =
  ctx.rectangleFilled(
    0,
    0,
    this.bounds.width,
    this.bounds.height,
    this.currentColor
  )

  procCall UIComponent(this).preRender(ctx, clippedRenderBounds)

