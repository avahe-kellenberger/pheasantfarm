import shade

import std/tables

var nestImageId = -1

proc getNestImage*(): Image =
  if nestImageId == -1:
    let (id, _) = Images.loadImage("./assets/nest.png", FILTER_NEAREST)
    nestImageId = id
  return Images[nestImageId]

type Nest* = ref object of PhysicsBody
  sprite*: Sprite
  hasEgg: bool

proc newNest*(): Nest =
  result = Nest(kind: PhysicsBodyKind.STATIC)
  initPhysicsBody(PhysicsBody(result))

  result.sprite = newSprite(getNestImage())

  result.collisionShape = newCollisionShape(newAABB(-5, -2.5, 5.5, 2.5))

Nest.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx)

