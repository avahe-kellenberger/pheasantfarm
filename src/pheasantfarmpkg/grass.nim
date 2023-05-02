import std/random
import shade
import constants

var grassImage: Image = nil

type Grass* = ref object of Node
  sprite: Sprite

proc newGrass*(): Grass =
  result = Grass()
  initNode(Node(result), {LayerObjectFlags.RENDER})

  if grassImage == nil:
    let (_, img) = Images.loadImage("./assets/grass.png", FILTER_NEAREST)
    grassImage = img

  result.sprite = newSprite(grassImage, 6, 2)
  result.sprite.scale = vector(RENDER_SCALAR, RENDER_SCALAR)
  result.sprite.frameCoords.x = rand(5)
  result.sprite.frameCoords.y =
    if rand(10) > 8:
      1 # flowers
    else:
      0 # grass

  result.sprite.offset.y = -result.sprite.size.y * 0.5

Grass.renderAsNodeChild:
  this.sprite.render(ctx, this.x + offsetX, this.y + offsetY)

