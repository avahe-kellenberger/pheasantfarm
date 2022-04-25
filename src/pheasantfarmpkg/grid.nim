import shade, safeset

import seq2d

import options

export safeset, options

# TODO: Fix this later
var fontIndex = -1

type
  Tile* = Safeset[PhysicsBody]
  TileCoord* = tuple[x: int, y: int]
  Grid* = ref object
    tiles: Seq2D[Tile]
    width*: int
    height*: int
    tileSize*: float
    bounds*: AABB

proc newTile(): Tile =
  return newSafeset[PhysicsBody]()

proc newGrid*(width, height: int, tileSize: float): Grid =
  result = Grid()
  result.tiles = newSeq2D[Tile](width, height)
  result.tileSize = tileSize
  result.width = width
  result.height = height
  result.bounds = newAABB(0.0, 0.0, width * tileSize, height * tileSize)

proc `[]`*(this: Grid, x, y: int): Tile =
  result = this.tiles[x, y]
  if result == nil:
    result = newTile()
    this.tiles[x, y] = result

proc getSize*(this: Grid): Vector =
  return this.bounds.getSize()

iterator findOverlappingTiles*(this: Grid, bounds: AABB): TileCoord =
  let
    topLeft = bounds.topLeft / this.tileSize
    left = int floor(topLeft.x)
    top = int floor(topLeft.y)
    bottomRight = bounds.bottomRight / this.tileSize
  var
    right = int floor(bottomRight.x)
    bottom = int floor(bottomRight.y)

  if float(right) == bottomRight.x:
    dec right

  if float(bottom) == bottomRight.y:
    dec bottom

  for y in max(0, top)..min(bottom, this.height - 1):
    for x in max(0, left)..min(right, this.width - 1):
      yield (x, y)

proc addPhysicsBodies*(this: Grid, bodies: varargs[PhysicsBody]) =
  for body in bodies:
    let bounds = body.getBounds()
    for (x, y) in this.findOverlappingTiles(bounds):
      this[x, y].add(body)

proc tileToWorldCoord*(this: Grid, x, y: int): Vector =
  return vector(
    this.tileSize * x + this.tileSize * 0.5,
    this.tileSize * y + this.tileSize * 0.5
  )

proc worldCoordToTile*(this: Grid, x, y: float): Option[TileCoord] =
  let coord: TileCoord = (
    int floor(x / this.tileSize),
    int floor(y / this.tileSize)
  )

  if coord.x < 0 or coord.x >= this.width or
     coord.y < 0 or coord.y >= this.height:
      return none(TileCoord)

  return option(coord)

template worldCoordToTile*(this: Grid, loc: Vector): Option[TileCoord] =
  this.worldCoordToTile(loc.x, loc.y)

proc highlightTile*(this: Grid, ctx: Target, tileX, tileY: int, color: Color = PURPLE) =
  let
    left = tileX * this.tileSize
    top = tileY * this.tileSize
    numObjectsOnTile = this[tileX, tileY].len

  ctx.rectangleFilled(
    left,
    top,
    left + this.tileSize,
    top + this.tileSize,
    if numObjectsOnTile > 0:
      color
    else:
      GREEN
  )

  if fontIndex == -1:
    let (i, font) = Fonts.load("./assets/fonts/kennypixel.ttf", 72)
    fontIndex = i

  let textbox = newTextBox(Fonts[fontIndex], $numObjectsOnTile)
  textbox.scale = vector(0.08, 0.08)
  textbox.setLocation(vector(left, top) + vector(this.tileSize * 0.5, this.tileSize * 0.5))
  textbox.render(ctx)

template highlightTile*(this: Grid, ctx: Target, coord: TileCoord, color: Color = PURPLE) =
  this.highlightTile(ctx, coord.x, coord.y, color)

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

