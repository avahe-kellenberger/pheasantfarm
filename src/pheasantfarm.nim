import shade
import std/random

import pheasantfarmpkg/player as playerModule
import pheasantfarmpkg/[pheasant, fences, gamelayer]
import pheasantfarmpkg/grid as gridModule

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

Input.addKeyEventListener(
  K_ESCAPE,
  proc(key: Keycode, state: KeyState) =
    Game.stop()
)

Input.addEventListener(
  MOUSEWHEEL,
  proc(e: Event): bool =
    camera.z = camera.z + float(e.wheel.y) * 0.03
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

