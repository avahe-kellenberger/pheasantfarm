import shade

var eggImageId = -1

proc getEggImage*(): Image =
  if eggImageId == -1:
    let (id, _) = Images.loadImage("./assets/egg.png", FILTER_NEAREST)
    eggImageId = id
  return Images[eggImageId]

type
  EggKind* {.pure.} = enum
    WHITE
    GRAY
    BLUE
    YELLOW
  Egg* = ref object of PhysicsBody
    sprite*: Sprite
    eggKind*: EggKind

proc newEgg*(eggKind: EggKind = EggKind.WHITE): Egg =
  result = Egg(kind: PhysicsBodyKind.STATIC)
  initPhysicsBody(PhysicsBody(result))
  result.eggKind = eggKind

  result.sprite = newSprite(getEggImage(), 4, 1)
  result.sprite.frameCoords.x = ord(eggKind)
  result.sprite.scale = vector(0.75, 0.75)

  result.collisionShape = newCollisionShape(
    newAABB(-5, -6, 5, 6).getScaledInstance(result.sprite.scale)
  )

Egg.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx)

