import std/tables
import shade, safeseq, seq2d
import random
import ui/fontloader

export safeseq

type
  Tile = ref object
    taggedBodies: Table[int, SafeSeq[PhysicsBody]]
    unknownBodies: SafeSeq[PhysicsBody]
  TileCoord* = tuple[x: int, y: int]
  Grid* = ref object
    tiles: Seq2D[Tile]
    width*: int
    height*: int
    tileSize*: float
    bounds*: AABB

const NULL_TILE* = (-1, -1)

proc newTile(): Tile =
  result = Tile()
  result.unknownBodies = newSafeSeq[PhysicsBody]()

proc len(this: Tile): int =
  for taggedBodySet in this.taggedBodies.values:
    result += taggedBodySet.len
  result += this.unknownBodies.len

proc newGrid*(width, height: int, tileSize: float): Grid =
  result = Grid()
  result.tiles = newSeq2D[Tile](width, height)
  result.tileSize = tileSize
  result.width = width
  result.height = height
  result.bounds = aabb(0.0, 0.0, width * tileSize, height * tileSize)

proc getSize*(this: Grid): Vector =
  return this.bounds.getSize()

proc `[]`(this: Grid, x, y: int): Tile =
  result = this.tiles[x, y]
  if result == nil:
    result = newTile()
    this.tiles[x, y] = result

iterator queryAll*(this: Grid, x, y: int): PhysicsBody =
  let tile = this[x, y]
  for taggedBodySet in tile.taggedBodies.values:
    for body in taggedBodySet:
      yield body
  for body in tile.unknownBodies:
    yield body

iterator query*(this: Grid, x, y: int, tags: varargs[int]): PhysicsBody =
  let tile = this[x, y]
  for tag in tags:
    let taggedBodySet = tile.taggedBodies.getOrDefault(tag, nil)
    if taggedBodySet != nil:
      for body in taggedBodySet:
        yield body

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
      this[x, y].unknownBodies.add(body)

proc addPhysicsBodies*(this: Grid, tag: int, bodies: varargs[PhysicsBody]) =
  for body in bodies:
    let bounds = body.getBounds()
    for (x, y) in this.findOverlappingTiles(bounds):
      let tile = this[x, y]
      var taggedBodySet = tile.taggedBodies.getOrDefault(tag, nil)
      if taggedBodySet == nil:
        taggedBodySet = newSafeSeq[PhysicsBody]()
        tile.taggedBodies[tag] = taggedBodySet
      taggedBodySet.add(body)

proc removePhysicsBodies*(this: Grid, bodies: varargs[PhysicsBody]) =
  for body in bodies:
    let bounds = body.getBounds()
    for (x, y) in this.findOverlappingTiles(bounds):
      let tile = this[x, y]
      for taggedBodySet in tile.taggedBodies.values:
        taggedBodySet.remove(body)
      tile.unknownBodies.remove(body)

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
  for body in this.queryAll(tile.x, tile.y):
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
        for body in this.queryAll(x, y):
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
  offsetX: float,
  offsetY: float,
  color: Color = PURPLE,
  renderText: bool = false,
  forceColor: bool = false
) =
  let
    left = tileX * this.tileSize + offsetX
    top = tileY * this.tileSize + offsetY
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
  offsetX: float,
  offsetY: float,
  color: Color = RED,
  renderText: bool = false,
  forceColor: bool = false
) =
  this.highlightTile(ctx, coord.x, coord.y, offsetX, offsetY, color, renderText, forceColor)

proc render*(this: Grid, ctx: Target, camera: Camera, offsetX, offsetY: float) =
  for y in 0..this.height:
    ctx.line(
      offsetX,
      y * this.tileSize + offsetY,
      this.width * this.tileSize + offsetX,
      y * this.tileSize + offsetY,
      GREEN
    )

  for x in 0..this.width:
    ctx.line(
      x * this.tileSize + offsetX,
      offsetY,
      x * this.tileSize + offsetX,
      this.height * this.tileSize + offsetY,
      GREEN
    )

