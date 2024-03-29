import shade

import std/random
import constants

const speed = 16.0
let pheasantAABB* = aabb(-4, -2, 4, 0)

var
  commonPheasantImageId = -1
  purplePheasantImageId = -1
  bluePheasantImageId = -1
  goldenPheasantImageId = -1

type
  PheasantKind* {.pure.} = enum
    COMMON
    PURPLE_PEACOCK
    BLUE_EARED
    GOLDEN
  PheasantAction* = enum
    IDLE,
    WALKING,
    EATING
  Pheasant* = ref object of PhysicsBody
    pheasantKind*: PheasantKind
    animationPlayer*: AnimationPlayer
    sprite*: Sprite
    currentAction: PheasantAction
    timeSinceActionStarted: float
    direction: Vector

proc setAction*(this: Pheasant, action: PheasantAction)

proc pickRandomDirection(this: Pheasant) =
  this.direction = vector(
    if rand(1) == 1: 1.0 else: -1.0,
    if rand(1) == 1: 1.0 else: -1.0
  )

  # Flip sprite to face proper direction
  if this.direction.x > 0:
    this.sprite.scale.x = abs(this.sprite.scale.x)
  else:
    this.sprite.scale.x = -abs(this.sprite.scale.x)

proc createIdleAnimation(this: Pheasant): Animation =
  const frameCount = 1
  let
    frameDuration = rand(0.8 .. 1.2)
    animDuration = frameCount * frameDuration

  # Set up the idle animation
  let idleAnim = newAnimation(animDuration, false)

  # Change the spritesheet coordinate
  let animCoordFrames: seq[KeyFrame[IVector]] = @[(ivector(0, 0), 0.0)]
  idleAnim.addNewAnimationTrack(this.sprite.frameCoords, animCoordFrames)
  return idleAnim

proc createWalkAnimation(this: Pheasant): Animation =
  const
    frameDuration = 0.08
    frameCount = 3
    animDuration = frameCount * frameDuration

  # Set up the walk animation
  let walkAnim = newAnimation(animDuration, false)

  # Change the spritesheet coordinate
  let animCoordFrames: seq[KeyFrame[IVector]] = @[(ivector(0, 0), 0.0)]
  walkAnim.addNewAnimationTrack(
    this.sprite.frameCoords,
    animCoordFrames
  )

  # Sprite render offset for a "hopping" animation
  let spriteOffsetFrames: seq[KeyFrame[Vector]] =
    @[
      (this.sprite.offset, 0.0),
      (vector(this.sprite.offset.x, this.sprite.offset.y - 3), frameDuration * 1),
      (this.sprite.offset, frameDuration * 2)
    ]

  walkAnim.addNewAnimationTrack(
    this.sprite.offset,
    spriteOffsetFrames
  )

  return walkAnim

proc createEatingAnimation(this: Pheasant): Animation =
  const
    frameDuration = 0.08
    frameCount = 9
    animDuration = frameCount * frameDuration

  var eatingAnim = newAnimation(animDuration, false)

  # Change the spritesheet coordinate
  let animCoordFrames: seq[KeyFrame[IVector]] =
    @[
      (ivector(1, 0), 0.0),
      (ivector(2, 0), frameDuration * 1),
      (ivector(3, 0), frameDuration * 2),
      (ivector(2, 0), frameDuration * 3),
      (ivector(3, 0), frameDuration * 4),
      (ivector(2, 0), frameDuration * 5),
      (ivector(3, 0), frameDuration * 6),
      (ivector(2, 0), frameDuration * 7),
      (ivector(1, 0), frameDuration * 8)
    ]

  eatingAnim.addNewAnimationTrack(this.sprite.frameCoords, animCoordFrames)
  return eatingAnim

proc createPheasantSprite(kind: PheasantKind): Sprite =
  var imageId = -1
  case kind:
    of COMMON:
      if commonPheasantImageId == -1:
        let (id, _) = Images.loadImage("./assets/common_pheasant.png", FILTER_NEAREST)
        commonPheasantImageId = id
      imageId = commonPheasantImageId

    of PURPLE_PEACOCK:
      if purplePheasantImageId == -1:
        let (id, _) = Images.loadImage("./assets/purple_peacock_pheasant.png", FILTER_NEAREST)
        purplePheasantImageId = id
      imageId = purplePheasantImageId

    of BLUE_EARED:
      if bluePheasantImageId == -1:
        let (id, _) = Images.loadImage("./assets/blue_eared_pheasant.png", FILTER_NEAREST)
        bluePheasantImageId = id
      imageId = bluePheasantImageId

    of GOLDEN:
      if goldenPheasantImageId == -1:
        let (id, _) = Images.loadImage("./assets/golden_pheasant.png", FILTER_NEAREST)
        goldenPheasantImageId = id
      imageId = goldenPheasantImageId

  result = newSprite(Images[imageId], 4, 1)

proc randomAction(): PheasantAction =
  rand(PheasantAction.low .. PheasantAction.high)

proc onWalkingFinished(this: Pheasant) =
  this.velocity = VECTOR_ZERO
  this.setAction(randomAction())

proc onEatingFinished(this: Pheasant) =
  this.setAction(IDLE)

proc onIdleFinished(this: Pheasant) =
  this.setAction(WALKING)

proc createAnimPlayer(this: Pheasant): AnimationPlayer =
  result = newAnimationPlayer()
  let
    idleAnim = createIdleAnimation(this)
    walkAnim = createWalkAnimation(this)
    eatingAnim = createEatingAnimation(this)

  result.addAnimation("idle", idleAnim)
  result.addAnimation("walk", walkAnim)
  result.addAnimation("eating", eatingAnim)
  result.playAnimation("idle")

  # Add callbacks to each animation.
  idleAnim.onFinished:
    onIdleFinished(this)

  walkAnim.onFinished:
    onWalkingFinished(this)

  eatingAnim.onFinished:
    onEatingFinished(this)

proc createCollisionShape(): CollisionShape =
  result = newCollisionShape(pheasantAABB)

proc createNewPheasant*(kind: PheasantKind): Pheasant =
  result = Pheasant(pheasantKind: kind)
  var shape = createCollisionShape()
  initPhysicsBody(PhysicsBody(result), shape)

  result.sprite = createPheasantSprite(kind)
  result.sprite.scale = vector(0.75, 0.75) * RENDER_SCALAR
  result.sprite.offset.y = -result.sprite.size.y * 0.5

  result.animationPlayer = createAnimPlayer(result)

  # Starts as idle
  result.setAction(randomAction())
  result.pickRandomDirection()

proc playAnimation*(this: Pheasant, name: string) =
  this.animationPlayer.playAnimation(name)

proc setAction*(this: Pheasant, action: PheasantAction) =
  let prevAction = this.currentAction
  this.currentAction = action
  this.timeSinceActionStarted = 0.0

  case this.currentAction:
    of WALKING:
      if prevAction != WALKING:
        this.pickRandomDirection()

      this.velocity = this.direction * speed
      this.playAnimation("walk")
    of EATING:
      this.playAnimation("eating")
    of IDLE:
      this.playAnimation("idle")

proc ai*(this: Pheasant, deltaTime: float) =
  case this.currentAction:
    of WALKING:
      discard
    of EATING:
      discard
    of IDLE:
      discard

method update*(this: Pheasant, deltaTime: float) =
  procCall PhysicsBody(this).update(deltaTime)
  this.ai(deltaTime)
  this.timeSinceActionStarted += deltaTime
  this.animationPlayer.update(deltaTime)

Pheasant.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx, this.x + offsetX, this.y + offsetY)

