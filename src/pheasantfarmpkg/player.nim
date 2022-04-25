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
  this.createPlayerAnimation(0.2, true, ivector(1, 0), ivector(2, 0))

template createWalkUpAnimation(this: Player): Animation =
  this.createPlayerAnimation(0.2, true, ivector(1, 1), ivector(2, 1))

template createWalkLeftAnimation(this: Player): Animation =
  this.createPlayerAnimation(0.2, true, ivector(1, 2), ivector(2, 2))

template createWalkRightAnimation(this: Player): Animation =
  this.createPlayerAnimation(0.2, true, ivector(1, 3), ivector(2, 3))

# Walking while holding animations

template createWalkDownHoldingAnimation(this: Player): Animation =
  this.createPlayerAnimation(0.2, true, ivector(4, 0), ivector(5, 0))

template createWalkUpHoldingAnimation(this: Player): Animation =
  this.createPlayerAnimation(0.2, true, ivector(4, 1), ivector(5, 1))

template createWalkLeftHoldingAnimation(this: Player): Animation =
  this.createPlayerAnimation(0.2, true, ivector(4, 2), ivector(5, 2))

template createWalkRightHoldingAnimation(this: Player): Animation =
  this.createPlayerAnimation(0.2, true, ivector(4, 3), ivector(5, 3))

proc createPlayerAnimation(
  this: Player,
  frameDuration: float,
  looping: bool,
  frameCoords: varargs[IVector]
): Animation =
  let anim = newAnimation(frameDuration * frameCoords.len, looping)
  var animCoordFrames: seq[KeyFrame[IVector]] = @[]
  for i, coord in frameCoords:
    animCoordFrames.add((coord, i * frameDuration))
  anim.addNewAnimationTrack(this.sprite.frameCoords, animCoordFrames)
  return anim

proc createPlayerSprite(this: Player): Sprite =
  let (_, image) = Images.loadImage("./assets/pharmer.png", FILTER_NEAREST)
  result = newSprite(image, 6, 4)

proc createCollisionShape(): CollisionShape =
  result = newCollisionShape(newAABB(-2, 6, 2, 8))

proc createAnimPlayer(this: Player): AnimationPlayer =
  result = newAnimationPlayer()

  result.addAnimation("idleDownAnimation", this.createIdleDownAnimation())
  result.addAnimation("idleLeftAnimation", this.createIdleLeftAnimation())
  result.addAnimation("idleRightAnimation", this.createIdleRightAnimation())
  result.addAnimation("idleUpAnimation", this.createIdleUpAnimation())

  result.addAnimation("idleHoldingDownAnimation", this.createIdleHoldingDownAnimation())
  result.addAnimation("idleHoldingLeftAnimation", this.createIdleHoldingLeftAnimation())
  result.addAnimation("idleHoldingRightAnimation", this.createIdleHoldingRightAnimation())
  result.addAnimation("idleHoldingUpAnimation", this.createIdleHoldingUpAnimation())

  result.addAnimation("walkDownAnimation", this.createWalkDownAnimation())
  result.addAnimation("walkLeftAnimation", this.createWalkLeftAnimation())
  result.addAnimation("walkRightAnimation", this.createWalkRightAnimation())
  result.addAnimation("walkUpAnimation", this.createWalkUpAnimation())

  result.addAnimation("walkDownHoldingAnimation", this.createWalkDownHoldingAnimation())
  result.addAnimation("walkLeftHoldingAnimation", this.createWalkLeftHoldingAnimation())
  result.addAnimation("walkRightHoldingAnimation", this.createWalkRightHoldingAnimation())
  result.addAnimation("walkUpHoldingAnimation", this.createWalkUpHoldingAnimation())

proc newPlayer*(): Player =
  result = Player()
  initPhysicsBody(PhysicsBody(result))
  result.sprite = result.createPlayerSprite()
  # Sprite isn't perfectly centered in frame.
  result.sprite.offset.x = 0.5
  result.collisionShape = createCollisionShape()
  result.animationPlayer = createAnimPlayer(result)

Player.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx)

