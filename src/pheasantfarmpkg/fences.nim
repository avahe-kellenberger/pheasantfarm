import shade
import grid

var fenceImageId: int = -1

type
  FenceAlignment = enum
    TOP
    BOTTOM
    LEFT
    RIGHT
  Fence = ref object of PhysicsBody
    sprite: Sprite
    lengthInTiles: int
    alignment: FenceAlignment

proc newFence(alignment: FenceAlignment, lengthInTiles: int): Fence =
  result = Fence(kind: PhysicsBodyKind.STATIC)
  initPhysicsBody(PhysicsBody(result))

  result.alignment = alignment
  result.lengthInTiles = lengthInTiles
  if fenceImageId == -1:
    let (id, _) = Images.loadImage("./assets/phence.png", FILTER_NEAREST)
    fenceImageId = id

  result.sprite = newSprite(Images[fenceImageId], 7, 1)
  if alignment == BOTTOM:
    result.sprite.offset = vector(0, -result.sprite.size.y)

  # Create collision shape based on orientation.
  case result.alignment:
    of TOP, BOTTOM:
      let
        size = vector(result.sprite.size.x * lengthInTiles, result.sprite.size.y)
        halfSpriteSize = result.sprite.size * 0.5

      result.collisionShape = newCollisionShape(
        newAABB(-halfSpriteSize.x, -halfSpriteSize.y, size.x - halfSpriteSize.x, size.y - halfSpriteSize.y)
      )

    of LEFT, RIGHT:
      let
        size = vector(result.sprite.size.x, result.sprite.size.y * lengthInTiles)
        halfSpriteSize = result.sprite.size * 0.5
      result.collisionShape = newCollisionShape(
        newAABB(-halfSpriteSize.x, -halfSpriteSize.y, size.x - halfSpriteSize.x, size.y - halfSpriteSize.y)
       )

proc generateAndAddFences*(layer: Layer, grid: Grid) =
  # Create top fence
  let topFence = newFence(TOP, grid.width - 2)
  topFence.setLocation(grid.tileToWorldCoord(1, 0))
  layer.addChild(topFence)

  # Create bottom fence
  let bottomFence = newFence(BOTTOM, grid.width - 2)
  bottomFence.setLocation(grid.tileToWorldCoord(1, grid.height - 1))
  layer.addChild(bottomFence)

  # Create the left fence
  let leftFence = newFence(LEFT, grid.height - 1)
  leftFence.setLocation(grid.tileToWorldCoord(0, 0))
  layer.addChild(leftFence)

  # Create the right fence
  let rightFence = newFence(RIGHT, grid.height - 1)
  rightFence.setLocation(grid.tileToWorldCoord(grid.width - 1, 0))
  layer.addChild(rightFence)

  grid.addPhysicsBodies(topFence, bottomFence, leftFence, rightFence)

template renderHorizontal(this: Fence, ctx: Target) =
  for x in 0..<this.lengthInTiles:
    ctx.translate(x * this.sprite.size.x, 0.0):
      this.sprite.render(ctx)

template renderLeft(this: Fence, ctx: Target) =
  # Top of fence
  this.sprite.frameCoords = ivector(1, 0)
  this.sprite.render(ctx)

  # Middle of "stacking" fence
  this.sprite.frameCoords = ivector(2, 0)
  for y in 1..<this.lengthInTiles:
    ctx.translate(0, y * this.sprite.size.y):
      if y == this.lengthInTiles - 1:
        # Bottom on fence
        this.sprite.frameCoords = ivector(3, 0)
      this.sprite.render(ctx)

template renderRight(this: Fence, ctx: Target) =
  # Top of fence
  this.sprite.frameCoords = ivector(4, 0)
  this.sprite.render(ctx)

  # Middle of "stacking" fence
  this.sprite.frameCoords = ivector(5, 0)
  for y in 1..<this.lengthInTiles:
    ctx.translate(0, y * this.sprite.size.y):
      if y == this.lengthInTiles - 1:
        # Bottom on fence
        this.sprite.frameCoords = ivector(6, 0)
      this.sprite.render(ctx)

Fence.renderAsChildOf(PhysicsBody):
  case this.alignment:
    of TOP, BOTTOM:
      this.renderHorizontal(ctx)
    of LEFT:
      this.renderLeft(ctx)
    of RIGHT:
      this.renderRight(ctx)

  when defined(debug):
    if this.collisionShape != nil:
      this.collisionShape.render(ctx)

