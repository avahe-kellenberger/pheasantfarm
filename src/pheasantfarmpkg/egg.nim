import shade

var eggImageId = -1

type Egg* = ref object of PhysicsBody
  sprite*: Sprite

proc newEgg*(): Egg =
  result = Egg(kind: PhysicsBodyKind.STATIC)
  initPhysicsBody(PhysicsBody(result))

  if eggImageId == -1:
    let (id, _) = Images.loadImage("./assets/egg.png", FILTER_NEAREST)
    eggImageId = id

  result.sprite = newSprite(Images[eggImageId])
  result.sprite.scale = vector(0.75, 0.75)

  result.collisionShape = newCollisionShape(
    newAABB(-5, -6, 5, 6).getScaledInstance(result.sprite.scale)
  )

Egg.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx)

