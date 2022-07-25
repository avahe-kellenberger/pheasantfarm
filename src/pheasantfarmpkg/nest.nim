import shade

import std/tables

import egg as eggModule

var nestImageId = -1

proc getNestImage*(): Image =
  if nestImageId == -1:
    let (id, _) = Images.loadImage("./assets/nest.png", FILTER_NEAREST)
    nestImageId = id
  return Images[nestImageId]

type Nest* = ref object of PhysicsBody
  sprite*: Sprite
  eggKind*: EggKind

proc newNest*(eggKind: EggKind): Nest =
  result = Nest(kind: PhysicsBodyKind.STATIC)
  var shape = newCollisionShape(aabb(-5.5, -5, 5.5, 0))
  initPhysicsBody(PhysicsBody(result), shape, {LayerObjectFlags.RENDER})
  result.sprite = newSprite(getNestImage(), 4, 1)
  result.sprite.frameCoords.x = ord(eggKind)
  result.sprite.offset.y = -result.sprite.size.y * 0.5
  result.eggKind = eggKind


Nest.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx)

