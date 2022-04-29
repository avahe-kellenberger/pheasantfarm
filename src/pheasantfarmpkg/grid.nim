import shade, safeset, seq2d
import random
import ui/fontloader

export safeset

type
  Tile* = Safeset[PhysicsBody]
  TileCoord* = tuple[x: int, y: int]
  Grid* = ref object
    tiles: Seq2D[Tile]
    width*: int
    height*: int
    tileSize*: float
    bounds*: AABB

const NULL_TILE* = (-1, -1)

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

proc removePhysicsBodies*(this: Grid, bodies: varargs[PhysicsBody]) =
  for body in bodies:
    let bounds = body.getBounds()
    for (x, y) in this.findOverlappingTiles(bounds):
      this[x, y].remove(body)

proc tileToWorldCoord*(this: Grid, x, y: int): Vector =
  return vector(
    this.tileSize * x + this.tileSize * 0.5,
    this.tileSize * y + this.tileSize * 0.5
  )

template tileToWorldCoord*(this: Grid, tile: TileCoord): Vector =
  this.tileToWorldCoord(tile.x, tile.y)

proc worldCoordToTile*(this: Grid, x, y: float): TileCoord =
  let coord: TileCoord = (
    int floor(x / this.tileSize),
    int floor(y / this.tileSize)
  )

  if coord.x < 0 or coord.x >= this.width or
     coord.y < 0 or coord.y >= this.height:
      return NULL_TILE

  return coord

template worldCoordToTile*(this: Grid, loc: Vector): TileCoord =
  this.worldCoordToTile(loc.x, loc.y)

proc getRandomPointInTile*(this: Grid, tileCoord: TileCoord): Vector =
  result.x = this.tileSize * tileCoord.x + rand(0.0 .. this.tileSize)
  result.y = this.tileSize * tileCoord.y + rand(0.0 .. this.tileSize)

proc isTileAvailable*(this: Grid, tile: TileCoord, isBlocking: proc(body: PhysicsBody): bool): bool =
  if tile.x < 0 or tile.x >= this.width:
    return false

  if tile.y < 0 or tile.y >= this.height:
    return false

  for body in this[tile.x, tile.y]:
    if isBlocking(body):
      return false
  return true

proc getRandomAvailableTile*(this: Grid, isBlocking: proc(body: PhysicsBody): bool): TileCoord =
  let
    width = this.width - 2
    height = this.height - 3

  var availableTiles: seq[TileCoord] = newSeqOfCap[TileCoord](width * height)
  for y in 1 .. height:
    for x in 1 .. width:

      block bodyCheck:
        for body in this[x, y]:
          if isBlocking(body):
            break bodyCheck

        availableTiles.add((x, y))

  if availableTiles.len > 0:
    return availableTiles[rand(0 .. availableTiles.high)]
  else:
    return NULL_TILE

proc highlightTile*(
  this: Grid,
  ctx: Target,
  tileX,
  tileY: int,
  color: Color = PURPLE,
  renderText: bool = false,
  forceColor: bool = false
) =
  let
    left = tileX * this.tileSize
    top = tileY * this.tileSize
    numObjectsOnTile = this[tileX, tileY].len

  ctx.rectangleFilled(
    left,
    top,
    left + this.tileSize,
    top + this.tileSize,
    if forceColor or numObjectsOnTile > 0:
      color
    else:
      GREEN
  )

  if renderText:
    let textbox = newTextBox(getFont(), $numObjectsOnTile, renderFilter = FILTER_NEAREST)
    textbox.scale = vector(0.08, 0.08)
    textbox.setLocation(vector(left, top) + vector(this.tileSize * 0.5, this.tileSize * 0.5))
    textbox.render(ctx)

template highlightTile*(
  this: Grid,
  ctx: Target,
  coord: TileCoord,
  color: Color = RED,
  renderText: bool = false,
  forceColor: bool = false
) =
  this.highlightTile(ctx, coord.x, coord.y, color, renderText, forceColor)

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

