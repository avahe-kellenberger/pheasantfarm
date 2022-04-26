import shade
import std/random

import pheasantfarmpkg/player as playerModule
import pheasantfarmpkg/[pheasant, fences, gamelayer]
import pheasantfarmpkg/grid as gridModule
import pheasantfarmpkg/egg as eggModule

initEngineSingleton(
  "Pheasant Pharm",
  1920,
  1080,
  fullscreen = true,
  clearColor = newColor(26, 136, 24)
)

let gridLayer = newLayer()
Game.scene.addLayer(gridLayer)

let grid = newGrid(20, 13, 16)
let layer = newGameLayer(grid)
Game.scene.addLayer(layer)

# Grass blades
let (_, grassImage) = Images.loadImage("./assets/grass.png", FILTER_NEAREST)

type Grass = ref object of Node
  sprite: Sprite

proc newGrass(): Grass =
  result = Grass()
  initNode(Node(result), {LayerObjectFlags.RENDER})
  result.sprite = newSprite(grassImage, 6, 1)
  result.sprite.frameCoords.x = rand(5)

for i in 0..250:
  let grass = newGrass()
  grass.setLocation(
    vector(
      rand((grid.bounds.left + grid.tileSize + 4) .. (grid.bounds.right - grid.tileSize - 4)),
      rand((grid.bounds.top + grid.tileSize + 4) .. (grid.bounds.bottom - grid.tileSize - 4))
    )
  )

  grass.onRender = proc(this: Node, ctx: Target) =
    Grass(this).sprite.render(ctx)

  layer.addChild(grass)

let egg = newEgg()
egg.setLocation(
  vector(
    rand(grid.bounds.left .. grid.bounds.right),
    rand(grid.bounds.top .. grid.bounds.bottom)
  )
)

egg.addCollisionListener(
  proc(this, other: PhysicsBody, r: CollisionResult, gravityNormal: Vector): bool =
    if other of Player:
      grid.removePhysicsBodies(egg)
      layer.removeChild(egg)
)

layer.addChild(egg)
grid.addPhysicsBodies(egg)

let targetedPheasant = createNewPheasant()
targetedPheasant.setLocation(
  grid.bounds.center +
  vector(rand(-120.0 .. 120.0), rand(-80.0 .. 80.0))
)

layer.addChild(targetedPheasant)

generateAndAddFences(layer, grid)

# Pheasant
let camera = newCamera()
camera.z = 0.8
camera.setLocation(grid.bounds.center)
Game.scene.camera = camera

when defined(debug):
  gridLayer.onRender = proc(this: Layer, ctx: Target) =
    for (x, y) in grid.findOverlappingTiles(targetedPheasant.getBounds()):
      grid.highlightTile(ctx, x, y)

    grid.render(ctx, camera)

    let mouseInWorldSpace = camera.screenToWorldCoord(Input.mouseLocation, layer.z - camera.z)
    let tileOpt = grid.worldCoordToTile(mouseInWorldSpace)
    if tileOpt.isSome():
      let tile = tileOpt.get()
      grid.highlightTile(ctx, tile)

# NOTE: Temporary pheasant spawning.
for i in 0..8:
  let pheasant = createNewPheasant()
  pheasant.setLocation(
    grid.bounds.center +
    vector(rand(-120.0 .. 120.0), rand(-80.0 .. 80.0))
  )
  layer.addChild(pheasant)

# Create player
let player = newPlayer()
player.setLocation(grid.bounds.center)
layer.addChild(player)

camera.setTrackedNode(player)
camera.setTrackingEasingFunction(easeOutQuadratic)
camera.completionRatioPerFrame = 0.05

Input.addKeyEventListener(
  K_ESCAPE,
  proc(key: Keycode, state: KeyState) =
    Game.stop()
)

proc isWalkable(grid: Grid, x, y: int): bool =
  # TODO: Will need particular rules about if something is walkable.
  return grid[x, y].len == 0

when not defined(debug):
  # Play some music
  let (someSong, err) = capture loadMusic("./assets/music/joy-ride.ogg")
  if err == nil:
    discard capture fadeInMusic(someSong, 2.0, 0.25)
  else:
    echo "Error playing music: " & err.msg

Game.start()

