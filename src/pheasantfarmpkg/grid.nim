import shade, safeset

import seq2d

export safeset

type
  Tile* = Safeset[Node]
  Grid* = ref object
    tiles: Seq2D[Tile]
    width: int
    height: int
    tileSize: float
    bounds*: AABB

proc newGrid*(width, height: int, tileSize: float): Grid =
  result = Grid()
  result.tiles = newSeq2D[Tile](width, height)
  result.tileSize = tileSize
  result.width = width
  result.height = height
  result.bounds = newAABB(0.0, 0.0, float(width) * tileSize, float(height) * tileSize)

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

proc renderTile*(this: Grid, tileX, tileY: int) =
  discard

proc highlightTile*(this: Grid, ctx: Target, tileX, tileY: int, color: Color = PURPLE) =
  let
    left = float(tileX) * this.tileSize
    right = float(tileY) * this.tileSize

  ctx.rectangleFilled(
    cfloat left,
    cfloat right,
    cfloat(left + this.tileSize),
    cfloat(right + this.tileSize),
    color
  )

proc render*(this: Grid, ctx: Target, camera: Camera) =
  for y in 0..this.height:
    ctx.line(
      cfloat 0.0,
      cfloat(float(y) * this.tileSize),
      cfloat(float(this.width) * this.tileSize),
      cfloat(float(y) * this.tileSize),
      GREEN
    )
    
  for x in 0..this.width:
    ctx.line(
      cfloat(float(x) * this.tileSize),
      cfloat 0.0,
      cfloat(float(x) * this.tileSize),
      cfloat(float(this.height) * this.tileSize),
      GREEN
    )
    
