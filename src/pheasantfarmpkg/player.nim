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

  Direction {.pure.} = enum
    UP
    DOWN
    LEFT
    RIGHT

  Player* = ref object of PhysicsBody
    animationPlayer*: AnimationPlayer
    sprite*: Sprite
    direction: IVector
    isHoldingItem: bool

const
    INPUT_MAP = {
      K_W: WALKING_UP,
      K_UP: WALKING_UP,
      K_A: WALKING_LEFT,
      K_LEFT: WALKING_LEFT,
      K_S: WALKING_DOWN,
      K_DOWN: WALKING_DOWN,
      K_D: WALKING_RIGHT,
      K_RIGHT: WALKING_RIGHT
    }.toTable()

    MOVEMENT_MAP = {
      UP: ivector(0, -1),
      DOWN: ivector(0, 1),
      LEFT: ivector(-1, 0),
      RIGHT: ivector(1, 0)
    }.toTable()

    MOVEMENT_KEYS = collect(newSeq):
      for key, value in INPUT_MAP.pairs:
        if ($value).startsWith("WALKING_"):
          key

# Idle animations

template createSingleFrameAnimation(
  this: Player,
  coord: IVector,
  flip: bool = false,
  duration: float = 1.0
): Animation =
  this.createPlayerAnimation(duration, false, flip, coord)

template createIdleDownAnimation(this: Player): Animation =
  this.createSingleFrameAnimation(ivector(0, 0))

template createIdleUpAnimation(this: Player): Animation =
  this.createSingleFrameAnimation(ivector(0, 1))

template createIdleLeftAnimation(this: Player): Animation =
  this.createSingleFrameAnimation(ivector(0, 2), true)

template createIdleRightAnimation(this: Player): Animation =
  this.createSingleFrameAnimation(ivector(0, 2))

# Idle holding animations

template createIdleHoldingDownAnimation(this: Player): Animation =
  this.createSingleFrameAnimation(ivector(3, 0))

template createIdleHoldingUpAnimation(this: Player): Animation =
  this.createSingleFrameAnimation(ivector(3, 1))

template createIdleHoldingLeftAnimation(this: Player): Animation =
  this.createSingleFrameAnimation(ivector(3, 2), true)

template createIdleHoldingRightAnimation(this: Player): Animation =
  this.createSingleFrameAnimation(ivector(3, 2))

# Walking animations

template createWalkDownAnimation(this: Player): Animation =
  this.createPlayerAnimation(0.2, true, false, ivector(1, 0), ivector(2, 0))

template createWalkUpAnimation(this: Player): Animation =
  this.createPlayerAnimation(0.2, true, false, ivector(1, 1), ivector(2, 1))

template createWalkLeftAnimation(this: Player): Animation =
  this.createPlayerAnimation(0.2, true, true, ivector(1, 2), ivector(2, 2))

template createWalkRightAnimation(this: Player): Animation =
  this.createPlayerAnimation(0.2, true, false, ivector(1, 2), ivector(2, 2))

# Walking while holding animations

template createWalkDownHoldingAnimation(this: Player): Animation =
  this.createPlayerAnimation(0.2, true, false, ivector(4, 0), ivector(5, 0))

template createWalkUpHoldingAnimation(this: Player): Animation =
  this.createPlayerAnimation(0.2, true, false, ivector(4, 1), ivector(5, 1))

template createWalkLeftHoldingAnimation(this: Player): Animation =
  this.createPlayerAnimation(0.2, true, true, ivector(4, 2), ivector(5, 2))

template createWalkRightHoldingAnimation(this: Player): Animation =
  this.createPlayerAnimation(0.2, true, false, ivector(4, 2), ivector(5, 2))

proc createPlayerAnimation(
  this: Player,
  frameDuration: float,
  looping: bool,
  flip: bool,
  frameCoords: varargs[IVector]
): Animation =
  let anim = newAnimation(frameDuration * frameCoords.len, looping)
  var animCoordFrames: seq[KeyFrame[IVector]] = @[]
  for i, coord in frameCoords:
    animCoordFrames.add((coord, i * frameDuration))
  anim.addNewAnimationTrack(this.sprite.frameCoords, animCoordFrames)

  let scaleFrame: seq[KeyFrame[Vector]] = @[(
    vector(if flip: -1.0 else: 1.0, this.sprite.scale.y),
    0.0
  )]
  anim.addNewAnimationTrack(this.sprite.scale, scaleFrame)

  return anim

proc createPlayerSprite(this: Player): Sprite =
  let (_, image) = Images.loadImage("./assets/pharmer.png", FILTER_NEAREST)
  result = newSprite(image, 6, 3)

proc createCollisionShape(scale: Vector): CollisionShape =
  result = newCollisionShape(newAABB(-2, 6, 2, 8).getScaledInstance(scale))

proc createAnimPlayer(this: Player): AnimationPlayer =
  result = newAnimationPlayer()

  result.addAnimation("idleDown", this.createIdleDownAnimation())
  result.addAnimation("idleLeft", this.createIdleLeftAnimation())
  result.addAnimation("idleRight", this.createIdleRightAnimation())
  result.addAnimation("idleUp", this.createIdleUpAnimation())

  result.addAnimation("idleDownHolding", this.createIdleHoldingDownAnimation())
  result.addAnimation("idleLeftHolding", this.createIdleHoldingLeftAnimation())
  result.addAnimation("idleRightHolding", this.createIdleHoldingRightAnimation())
  result.addAnimation("idleUpHolding", this.createIdleHoldingUpAnimation())

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

proc updateAnimation(this: Player) =
  let isWalking = this.velocity != VECTOR_ZERO

  # Right
  if this.direction.x == 1:
    if isWalking:
      if this.isHoldingItem:
        this.animationPlayer.play("walkRightHolding")
      else:
        this.animationPlayer.play("walkRight")
    else:
      if this.isHoldingItem:
        this.animationPlayer.play("idleRightHolding")
      else:
        this.animationPlayer.play("idleRight")

  # Left
  if this.direction.x == -1:
    if isWalking:
      if this.isHoldingItem:
        this.animationPlayer.play("walkLeftHolding")
      else:
        this.animationPlayer.play("walkLeft")
    else:
      if this.isHoldingItem:
        this.animationPlayer.play("idleLeftHolding")
      else:
        this.animationPlayer.play("idleLeft")

  # Up
  if this.direction.y == -1:
    if isWalking:
      if this.isHoldingItem:
        this.animationPlayer.play("walkUpHolding")
      else:
        this.animationPlayer.play("walkUp")
    else:
      if this.isHoldingItem:
        this.animationPlayer.play("idleUpHolding")
      else:
        this.animationPlayer.play("idleUp")

  # Down
  if this.direction.y == 1:
    if isWalking:
      if this.isHoldingItem:
        this.animationPlayer.play("walkDownHolding")
      else:
        this.animationPlayer.play("walkDown")
    else:
      if this.isHoldingItem:
        this.animationPlayer.play("idleDownHolding")
      else:
        this.animationPlayer.play("idleDown")

proc calculateDirection(): IVector =
  if Input.isKeyPressed(K_W) or Input.isKeyPressed(K_UP):
    result.y += -1
  if Input.isKeyPressed(K_A) or Input.isKeyPressed(K_LEFT):
    result.x += -1
  if Input.isKeyPressed(K_S) or Input.isKeyPressed(K_DOWN):
    result.y += 1
  if Input.isKeyPressed(K_D) or Input.isKeyPressed(K_RIGHT):
    result.x += 1

proc updateDirection(this: Player) =
  let dir = calculateDirection()
  if dir == IVECTOR_ZERO:
    this.velocity = VECTOR_ZERO
  else:
    this.velocity = dir.normalize() * speed
    this.direction = dir

  this.updateAnimation()

proc handleMovementKeyPressed(this: Player, keycode: KeyCode, repeat: bool) =
  if repeat or keycode notin MOVEMENT_KEYS:
    return

  this.updateDirection()

proc handleMovementKeyReleased(this: Player, keycode: KeyCode, repeat: bool) =
  if not repeat and keycode in MOVEMENT_KEYS:
    this.updateDirection()

proc setupInputListeners(this: Player) =
  Input.addEventListener(KEYUP, proc(e: Event): bool =
    this.handleMovementKeyReleased(e.key.keysym.sym, e.key.repeat != 0)
  )
  
  Input.addEventListener(KEYDOWN, proc(e: Event): bool =
    this.handleMovementKeyPressed(e.key.keysym.sym, e.key.repeat != 0)
  )

proc newPlayer*(): Player =
  result = Player()
  initPhysicsBody(PhysicsBody(result))
  result.scale = vector(1.5, 1.5)

  result.sprite = result.createPlayerSprite()
  # Sprite isn't perfectly centered in frame.
  result.sprite.offset.x = 0.5
  # Move sprite to render his feet at y 0
  result.sprite.offset.y = 0.5


  result.collisionShape = createCollisionShape(result.scale)
  result.animationPlayer = createAnimPlayer(result)
  result.animationPlayer.playAnimation("idleDown")
  result.setupInputListeners()

method update*(this: Player, deltaTime: float) =
  procCall PhysicsBody(this).update(deltaTime)
  this.animationPlayer.update(deltaTime)

Player.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx)

