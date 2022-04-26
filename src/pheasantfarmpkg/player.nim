import shade

import std/[tables, sugar, strutils]

const speed = 48.0

type
  PlayerAction {.pure.} = enum
    WALKING_UP
    WALKING_DOWN
    WALKING_LEFT
    WALKING_RIGHT
  
  MovementAction = WALKING_UP..WALKING_RIGHT

  Player* = ref object of PhysicsBody
    animationPlayer*: AnimationPlayer
    sprite*: Sprite
    direction: Vector

const
    INPUT_MAP = {
      K_W: WALKING_UP,
      K_UP: WALKING_UP,
      K_S: WALKING_DOWN,
      K_DOWN: WALKING_DOWN,
      K_A: WALKING_LEFT,
      K_LEFT: WALKING_LEFT,
      K_D: WALKING_RIGHT,
      K_RIGHT: WALKING_RIGHT
    }.toTable()

    MOVEMENT_KEYS = collect(newSeq):
      for key, value in INPUT_MAP.pairs:
        if ($value).startsWith("WALKING_"):
          key

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

  result.addAnimation("idleDown", this.createIdleDownAnimation())
  result.addAnimation("idleLeft", this.createIdleLeftAnimation())
  result.addAnimation("idleRight", this.createIdleRightAnimation())
  result.addAnimation("idleUp", this.createIdleUpAnimation())

  result.addAnimation("idleHoldingDown", this.createIdleHoldingDownAnimation())
  result.addAnimation("idleHoldingLeft", this.createIdleHoldingLeftAnimation())
  result.addAnimation("idleHoldingRight", this.createIdleHoldingRightAnimation())
  result.addAnimation("idleHoldingUp", this.createIdleHoldingUpAnimation())

  let walkDownAnimation = this.createWalkDownAnimation()
  walkDownAnimation.onFinished:
    this.animationPlayer.playAnimation("idleDown")
  result.addAnimation("walkDown", walkDownAnimation)

  let walkLeftAnimation = this.createWalkLeftAnimation()
  walkLeftAnimation.onFinished:
    this.animationPlayer.playAnimation("idleLeft")
  result.addAnimation("walkLeft", walkLeftAnimation)

  result.addAnimation("walkRight", this.createWalkRightAnimation())
  result.addAnimation("walkUp", this.createWalkUpAnimation())

  result.addAnimation("walkDownHolding", this.createWalkDownHoldingAnimation())
  result.addAnimation("walkLeftHolding", this.createWalkLeftHoldingAnimation())
  result.addAnimation("walkRightHolding", this.createWalkRightHoldingAnimation())
  result.addAnimation("walkUpHolding", this.createWalkUpHoldingAnimation())

proc isMovementKeyPressed(): bool =
  for key in MOVEMENT_KEYS:
    if Input.isKeyPressed(key):
      return true
  return false

proc handleMovementKeyPressed(this: Player, keycode: KeyCode, repeat: bool) =
  if repeat or keycode notin MOVEMENT_KEYS:
    return

  let action: MovementAction = INPUT_MAP[keycode]
  case action:
    of WALKING_LEFT:
      if this.direction.x >= 0:
        this.direction.x += -1.0
    of WALKING_RIGHT:
      if this.direction.x <= 0:
        this.direction.x += 1.0
    of WALKING_UP:
      if this.direction.y >= 0:
        this.direction.y += -1.0
    of WALKING_DOWN:
      if this.direction.y <= 0:
        this.direction.y += 1.0

  if this.direction == VECTOR_ZERO:
    this.velocity = VECTOR_ZERO
  else:
    this.velocity = this.direction.normalize() * speed

proc handleMovementKeyReleased(this: Player, keycode: KeyCode, repeat: bool) =
  if repeat or keycode notin MOVEMENT_KEYS:
    return

  let action: MovementAction = INPUT_MAP[keycode]
  case action:
    of WALKING_LEFT:
      if this.direction.x <= 0:
        this.direction.x += 1.0
    of WALKING_RIGHT:
      if this.direction.x >= 0:
        this.direction.x -= 1.0
    of WALKING_UP:
      if this.direction.y <= 0:
        this.direction.y += 1.0
    of WALKING_DOWN:
      if this.direction.y >= 0:
        this.direction.y += -1.0

  if this.direction == VECTOR_ZERO:
    # NOTE: This is how we transition to an idle animation.
    this.animationPlayer.currentAnimation.notifyFinishedCallbacks()
    this.velocity = VECTOR_ZERO
  else:
    this.velocity = this.direction.normalize() * speed

proc handleInput(this: Player) =
  Input.addEventListener(KEYUP, proc(e: Event): bool =
    this.handleMovementKeyReleased(e.key.keysym.sym, e.key.repeat != 0)
  )
  
  Input.addEventListener(KEYDOWN, proc(e: Event): bool =
    this.handleMovementKeyPressed(e.key.keysym.sym, e.key.repeat != 0)
  )

proc newPlayer*(): Player =
  result = Player()
  initPhysicsBody(PhysicsBody(result))
  result.sprite = result.createPlayerSprite()
  # Sprite isn't perfectly centered in frame.
  result.sprite.offset.x = 0.5
  result.collisionShape = createCollisionShape()
  result.animationPlayer = createAnimPlayer(result)
  result.animationPlayer.playAnimation("walkDown")
  result.handleInput()

method update*(this: Player, deltaTime: float) =
  procCall PhysicsBody(this).update(deltaTime)
  this.animationPlayer.update(deltaTime)

Player.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx)

