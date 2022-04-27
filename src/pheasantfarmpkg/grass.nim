import std/random
import shade

var grassImage: Image = nil

type Grass* = ref object of Node
  sprite: Sprite

proc newGrass*(): Grass =
  result = Grass()
  initNode(Node(result), {LayerObjectFlags.RENDER})

  if grassImage == nil:
    let (_, img) = Images.loadImage("./assets/grass.png", FILTER_NEAREST)
    grassImage = img

  result.sprite = newSprite(grassImage, 6, 1)
  result.sprite.frameCoords.x = rand(5)

Grass.renderAsNodeChild:
  this.sprite.render(ctx)

