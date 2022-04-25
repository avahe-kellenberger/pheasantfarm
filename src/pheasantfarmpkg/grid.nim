import shade, safeset

import seq2d

export safeset

type
  Tile* = Safeset[Node]
  Grid* = ref object
    tiles: Seq2D[Tile]
    width*: int
    height*: int
    tileSize*: float
    bounds*: AABB

proc newGrid*(width, height: int, tileSize: float): Grid =
  result = Grid()
  result.tiles = newSeq2D[Tile](width, height)
  result.tileSize = tileSize
  result.width = width
  result.height = height
  result.bounds = newAABB(0.0, 0.0, width * tileSize, height * tileSize)

proc `[]`*(this: Grid, x, y: int): Tile =
  return this.tiles[x, y]

proc getSize*(this: Grid): Vector =
  return this.bounds.getSize()

iterator findOverlappingTiles*(this: Grid, bounds: AABB): tuple[x: int, y: int] =
  let
    topLeft = bounds.topLeft / this.tileSize
    left = int floor(topLeft.x)
    top = int floor(topLeft.y)
    bottomRight = bounds.bottomRight / this.tileSize
    right = int floor(bottomRight.x)
    bottom = int floor(bottomRight.y)
  
  for y in top..bottom:
    for x in left..right:
      yield (x, y)

proc tileToWorldCoord*(this: Grid, x, y: int): Vector =
  return vector(
    this.tileSize * x + this.tileSize * 0.5,
    this.tileSize * y + this.tileSize * 0.5
  )

proc highlightTile*(this: Grid, ctx: Target, tileX, tileY: int, color: Color = PURPLE) =
  let
    left = tileX * this.tileSize
    right = tileY * this.tileSize

  ctx.rectangleFilled(
    left,
    right,
    left + this.tileSize,
    right + this.tileSize,
    color
  )

proc render*(this: Grid, ctx: Target, camera: Camera) =
  for y in 0..this.height:
    ctx.line(
      0.0,
      y * this.tileSize,
      this.width * this.tileSize,
      y * this.tileSize,
      GREEN
    )
    
  for x in 0..this.width:
    ctx.line(
      x * this.tileSize,
      0.0,
      x * this.tileSize,
      this.height * this.tileSize,
      GREEN
    )
    
