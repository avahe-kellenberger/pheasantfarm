import shade

type
  Player* = ref object of PhysicsBody
    animationPlayer*: AnimationPlayer
    sprite*: Sprite

# Idle animations

template createSingleFrameAnimation(this: Player, coord: IVector, duration: float = 1.0): Animation =
  this.createPlayerAnimation(duration, false, coord)

template createIdleDownAnimation(this: Player): Animation =
  this.createSingleFrameAnimation(ivector(0, 0))

template createIdleUpAnimation(this: Player): Animation =
  this.createSingleFrameAnimation(ivector(0, 1))

template createIdleLeftAnimation(this: Player): Animation =
  this.createSingleFrameAnimation(ivector(0, 2))

template createIdleRightAnimation(this: Player): Animation =
  this.createSingleFrameAnimation(ivector(0, 3))

# Idle holding animations

template createIdleHoldingDownAnimation(this: Player): Animation =
  this.createSingleFrameAnimation(ivector(3, 0))

template createIdleHoldingUpAnimation(this: Player): Animation =
  this.createSingleFrameAnimation(ivector(3, 1))

template createIdleHoldingLeftAnimation(this: Player): Animation =
  this.createSingleFrameAnimation(ivector(3, 2))

template createIdleHoldingRightAnimation(this: Player): Animation =
  this.createSingleFrameAnimation(ivector(3, 3))

# Walking animations

template createWalkDownAnimation(this: Player): Animation =
  createPlayerAnimation(0.2, true, ivector(1, 0), ivector(2, 0))

template createWalkUpAnimation(this: Player): Animation =
  createPlayerAnimation(0.2, true, ivector(1, 1), ivector(2, 1))

template createWalkLeftAnimation(this: Player): Animation =
  createPlayerAnimation(0.2, true, ivector(1, 2), ivector(2, 2))

template createWalkRightAnimation(this: Player): Animation =
  createPlayerAnimation(0.2, true, ivector(1, 3), ivector(2, 3))

proc createPlayerAnimation(
  this: Player,
  frameDuration: float,
  looping: bool,
  frameCoords: varargs[IVector]
): Animation =
  result = newAnimation(frameDuration * frameCoords.len, looping)
  var animCoordFrames: seq[KeyFrame[IVector]] = @[]
  for i, coord in frameCoords:
    animCoordFrames.add((coord, i * frameDuration))
  result.addNewAnimationTrack(this.sprite.frameCoords, animCoordFrames)

proc createPlayerSprite(this: Player): Sprite =
  let (_, image) = Images.loadImage("./assets/pharmer.png", FILTER_NEAREST)
  result = newSprite(image, 6, 4)

proc newPlayer*(): Player =
  result = Player()
  initPhysicsBody(PhysicsBody(result))
  result.sprite = result.createPlayerSprite()

Player.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx)


