import shade

import std/tables

var eggImageId = -1

proc getEggImage*(): Image =
  if eggImageId == -1:
    let (id, _) = Images.loadImage("./assets/egg.png", FILTER_NEAREST)
    eggImageId = id
  return Images[eggImageId]

type
  EggKind* {.pure.} = enum
    WHITE
    PURPLE
    BLUE
    GOLDEN
  Egg* = ref object of PhysicsBody
    sprite*: Sprite
    eggKind*: EggKind

const EGG_PRICES* = {
  EggKind.WHITE: 1,
  EggKind.PURPLE: 5,
  EggKind.BLUE: 10,
  EggKind.GOLDEN: 15
}.toTable()

proc newEgg*(eggKind: EggKind = EggKind.WHITE): Egg =
  result = Egg(kind: PhysicsBodyKind.STATIC)

  let sprite = newSprite(getEggImage(), 4, 1)
  var shape = newCollisionShape(
    aabb(-5, -6, 5, 6).getScaledInstance(sprite.scale)
  )

  initPhysicsBody(PhysicsBody(result), shape, {LayerObjectFlags.RENDER})

  result.eggKind = eggKind
  result.sprite = sprite
  result.sprite.frameCoords.x = ord(eggKind)
  result.sprite.scale = vector(0.75, 0.75)


proc calcTotal*(eggCount: CountTable[EggKind]): int =
  for kind, count in eggCount.pairs():
    result += count * EGG_PRICES[kind]

Egg.renderAsChildOf(PhysicsBody):
  this.sprite.render(ctx)

