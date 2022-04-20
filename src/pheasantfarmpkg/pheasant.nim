import shade

type Pheasant* = ref object of PhysicsBody
  animationPlayer: AnimationPlayer
  sprite*: Sprite

proc createIdleAnimation(pheasant: Pheasant): Animation =
  const
    frameDuration = 1.0
    frameCount = 1
    animDuration = frameCount * frameDuration

  # Set up the idle animation
  let idleAnim = newAnimation(animDuration, false)

  # Change the spritesheet coordinate
  let animCoordFrames: seq[KeyFrame[IVector]] = @[(ivector(0, 0), 0.0)]
  idleAnim.addNewAnimationTrack(pheasant.sprite.frameCoords, animCoordFrames)
  return idleAnim

proc createRunAnimation(pheasant: Pheasant): Animation =
  const
    frameDuration = 0.08
    frameCount = 3
    animDuration = frameCount * frameDuration

  # Set up the run animation
  var runAnim = newAnimation(animDuration, true)

  # Change the spritesheet coordinate
  let animCoordFrames: seq[KeyFrame[IVector]] = @[(ivector(0, 0), 0.0)]
  runAnim.addNewAnimationTrack(
    pheasant.sprite.frameCoords,
    animCoordFrames
  )

  # Sprite render offset for a "hopping" animation
  let spriteOffsetFrames: seq[KeyFrame[Vector]] =
    @[
      (vector(0, 0), 0.0),
      (vector(0, -3), frameDuration * 1),
      (vector(0, 0), frameDuration * 2)
    ]

  runAnim.addNewAnimationTrack(
    pheasant.sprite.offset,
    spriteOffsetFrames
  )

  return runAnim

proc createPheasantSprite(): Sprite =
  let (_, image) = Images.loadImage("./assets/common_pheasant.png", FILTER_NEAREST)
  result = newSprite(image, 4, 1)

proc createAnimPlayer(pheasant: Pheasant): AnimationPlayer =
  result = newAnimationPlayer()
  result.addAnimation("idle", createIdleAnimation(pheasant))
  result.addAnimation("run", createRunAnimation(pheasant))
  result.playAnimation("idle")

proc createCollisionShape(): CollisionShape =
  result = newCollisionShape(newAABB(-8, -8, 8, 8))

proc createNewPheasant*(): Pheasant =
  result = Pheasant()
  initPhysicsBody(PhysicsBody(result))

  let sprite = createPheasantSprite()
  result.sprite = sprite
  result.animationPlayer = createAnimPlayer(result)

  let collisionShape = createCollisionShape()
  result.collisionShape = collisionShape

proc playAnimation*(pheasant: Pheasant, name: string) =
  pheasant.animationPlayer.playAnimation(name)

method update*(this: Pheasant, deltaTime: float) =
  procCall PhysicsBody(this).update(deltaTime)
  this.animationPlayer.update(deltaTime)

Pheasant.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx)

