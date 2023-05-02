import shade
import grid, tags, constants

var fenceImageId: int = -1

type
  FenceAlignment = enum
    TOP
    BOTTOM
    LEFT
    RIGHT
  Fence* = ref object of PhysicsBody
    sprite: Sprite
    lengthInTiles: int
    alignment: FenceAlignment

proc newFence(alignment: FenceAlignment, lengthInTiles: int): Fence =
  result = Fence(kind: PhysicsBodyKind.STATIC)

  if fenceImageId == -1:
    let (id, _) = Images.loadImage("./assets/phence.png", FILTER_NEAREST)
    fenceImageId = id

  let sprite = newSprite(Images[fenceImageId], 7, 1)
  sprite.scale = vector(RENDER_SCALAR, RENDER_SCALAR)

  # Create collision shape based on orientation.
  var shape =
    case alignment:
      of TOP, BOTTOM:
        let
          size = vector(sprite.size.x * lengthInTiles, sprite.size.y) * RENDER_SCALAR
          halfSpriteSize = sprite.size * 0.5 * RENDER_SCALAR

        newCollisionShape(
          aabb(-halfSpriteSize.x, -halfSpriteSize.y, size.x - halfSpriteSize.x, size.y - halfSpriteSize.y)
        )

      of LEFT, RIGHT:
        let
          size = vector(sprite.size.x, sprite.size.y * lengthInTiles) * RENDER_SCALAR
          halfSpriteSize = sprite.size * 0.5 * RENDER_SCALAR

        newCollisionShape(
          aabb(-halfSpriteSize.x, -halfSpriteSize.y, size.x - halfSpriteSize.x, size.y - halfSpriteSize.y)
         )

  initPhysicsBody(PhysicsBody(result), shape, {LayerObjectFlags.RENDER})
  result.sprite = sprite
  result.alignment = alignment
  result.lengthInTiles = lengthInTiles

  if alignment == BOTTOM:
    result.sprite.offset = vector(0, -result.sprite.size.y)

proc generateAndAddFences*(layer: Layer, grid: Grid): AABB =
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

  grid.addPhysicsBodies(tagFence, topFence, bottomFence, leftFence, rightFence)

  result = aabb(
    leftFence.getBounds().right,
    topFence.getBounds().bottom,
    rightFence.getBounds().left,
    bottomFence.getBounds().top
  )

template renderHorizontal(this: Fence, ctx: Target, offsetX: float = 0, offsetY: float = 0) =
  for x in 0..<this.lengthInTiles:
    this.sprite.render(
      ctx,
      this.x + x * (this.sprite.size.x * RENDER_SCALAR) + offsetX,
      this.y + offsetY
    )

template renderLeft(this: Fence, ctx: Target, offsetX: float = 0, offsetY: float = 0) =
  # Top of fence
  this.sprite.frameCoords = ivector(1, 0)
  this.sprite.render(ctx, this.x + offsetX, this.y + offsetY)

  # Middle of "stacking" fence
  this.sprite.frameCoords = ivector(2, 0)
  for y in 1..<this.lengthInTiles:
    if y == this.lengthInTiles - 1:
      # Bottom on fence
      this.sprite.frameCoords = ivector(3, 0)
    this.sprite.render(ctx, this.x + offsetX, this.y + y * (this.sprite.size.y * RENDER_SCALAR) + offsetY)

template renderRight(this: Fence, ctx: Target, offsetX: float = 0, offsetY: float = 0) =
  # Top of fence
  this.sprite.frameCoords = ivector(4, 0)
  this.sprite.render(ctx, this.x + offsetX, this.y + offsetY)

  # Middle of "stacking" fence
  this.sprite.frameCoords = ivector(5, 0)
  for y in 1..<this.lengthInTiles:
    if y == this.lengthInTiles - 1:
      # Bottom on fence
      this.sprite.frameCoords = ivector(6, 0)
    this.sprite.render(ctx, this.x + offsetX, this.y + y * (this.sprite.size.y * RENDER_SCALAR) + offsetY)

Fence.renderAsChildOf(PhysicsBody):
  case this.alignment:
    of TOP, BOTTOM:
      this.renderHorizontal(ctx, offsetX, offsetY)
    of LEFT:
      this.renderLeft(ctx, offsetX, offsetY)
    of RIGHT:
      this.renderRight(ctx, offsetX, offsetY)

  when defined(debug):
    this.collisionShape.render(ctx, offsetX, offsetY)

