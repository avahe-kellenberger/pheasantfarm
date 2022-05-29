import shade

import std/[tables, sugar, strutils]

const speed = 96.0

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
    isControllable*: bool
    animationPlayer*: AnimationPlayer
    sprite*: Sprite
    direction*: IVector

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

# Walking animations

template createWalkDownAnimation(this: Player): Animation =
  this.createPlayerAnimation(0.2, true, false, ivector(1, 0), ivector(2, 0))

template createWalkUpAnimation(this: Player): Animation =
  this.createPlayerAnimation(0.2, true, false, ivector(1, 1), ivector(2, 1))

template createWalkLeftAnimation(this: Player): Animation =
  this.createPlayerAnimation(0.2, true, true, ivector(1, 2), ivector(2, 2))

template createWalkRightAnimation(this: Player): Animation =
  this.createPlayerAnimation(0.2, true, false, ivector(1, 2), ivector(2, 2))

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
  result = newCollisionShape(newAABB(-2, -4, 2, 0).getScaledInstance(scale))

proc createAnimPlayer(this: Player): AnimationPlayer =
  result = newAnimationPlayer()

  result.addAnimation("idleDown", this.createIdleDownAnimation())
  result.addAnimation("idleLeft", this.createIdleLeftAnimation())
  result.addAnimation("idleRight", this.createIdleRightAnimation())
  result.addAnimation("idleUp", this.createIdleUpAnimation())

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

proc isMovementKeyPressed(): bool =
  for key in MOVEMENT_KEYS:
    if Input.isKeyPressed(key):
      return true
  return false

proc updateAnimation*(this: Player) =
  let isWalking = this.velocity != VECTOR_ZERO

  # Right
  if this.direction.x == 1:
    if isWalking:
      this.animationPlayer.play("walkRight")
    else:
      this.animationPlayer.play("idleRight")

  # Left
  if this.direction.x == -1:
    if isWalking:
      this.animationPlayer.play("walkLeft")
    else:
      this.animationPlayer.play("idleLeft")

  # Up
  if this.direction.y == -1:
    if isWalking:
      this.animationPlayer.play("walkUp")
    else:
      this.animationPlayer.play("idleUp")

  # Down
  if this.direction.y == 1:
    if isWalking:
      this.animationPlayer.play("walkDown")
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

proc updateDirection*(this: Player) =
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
  Input.addListener(KEYUP, proc(e: Event): bool =
    if this.isControllable:
      this.handleMovementKeyReleased(e.key.keysym.sym, e.key.repeat != 0)
  )
  
  Input.addListener(KEYDOWN, proc(e: Event): bool =
    if this.isControllable:
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
  result.sprite.offset.y = -result.sprite.size.y * 0.5

  result.collisionShape = createCollisionShape(result.scale)
  result.animationPlayer = createAnimPlayer(result)
  result.animationPlayer.playAnimation("idleDown")
  result.setupInputListeners()

method update*(this: Player, deltaTime: float) =
  procCall PhysicsBody(this).update(deltaTime)
  this.animationPlayer.update(deltaTime)

Player.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx)

