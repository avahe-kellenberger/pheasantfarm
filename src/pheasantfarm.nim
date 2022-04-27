import shade
import std/[tables, random]

import pheasantfarmpkg/[pheasant, fences, gamelayer]
import pheasantfarmpkg/ui/startmenu as startMenuModule
import pheasantfarmpkg/ui/hud as hudModule
import pheasantfarmpkg/player as playerModule
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

let targetedPheasant = createNewPheasant()
targetedPheasant.setLocation(
  grid.bounds.center +
  vector(rand(-120.0 .. 120.0), rand(-80.0 .. 80.0))
)

layer.addChild(targetedPheasant)

generateAndAddFences(layer, grid)

# Pheasant
let camera = newCamera()
camera.z = 0.85
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

Game.hud = newLayer()

# HUD
let hud = newHUD()
hud.setTimeRemaining(0)
hud.setMoney(0)
Game.hud.addChild(hud)
hud.visible = false
hud.setLocation(
  getLocationInParent(hud.position, gamestate.resolution) +
  vector(gamestate.resolution.x * 0.5, gamestate.resolution.y * 0.05)
)

# Set up the start menu
let startMenu = newStartMenu()
Game.hud.addChild(startMenu)
startMenu.size = gamestate.resolution
startMenu.setLocation(
  getLocationInParent(startMenu.position, gamestate.resolution) + gamestate.resolution * 0.5
)

# Center the menu if the screen size changes.
gamestate.onResolutionChanged:
  startMenu.size = gamestate.resolution
  startMenu.setLocation(
    getLocationInParent(startMenu.position, gamestate.resolution) + gamestate.resolution * 0.5
  )

  hud.setLocation(
    getLocationInParent(hud.position, gamestate.resolution) +
    vector(gamestate.resolution.x * 0.5, gamestate.resolution.y * 0.05)
  )

let menuClickSound = loadSoundEffect("./assets/sfx/menu-click.wav")

startMenu.startButton.onClick:
  menuClickSound.play()
  Game.hud.removeChild(startMenu)
  player.isControllable = true
  startMenu.visible = false

  # TODO: Generate level,
  # Add in-game HUD
  hud.visible = true

startMenu.quitButton.onClick:
  Game.stop()

var eggCount = initCountTable[EggKind]()

let pickupSound = loadSoundEffect("./assets/sfx/pick-up.wav")

proc onEggCollected(this: Egg) =
  pickupSound.play()
  grid.removePhysicsBodies(this)
  layer.removeChild(this)

  eggCount.inc(this.eggKind)
  hud.setEggCount(this.eggKind, eggCount[this.eggKind])

proc spawnEgg() =
  let egg = newEgg(rand(EggKind.low .. EggKind.high))
  egg.setLocation(
    vector(
      rand((grid.bounds.left + grid.tileSize + 4) .. (grid.bounds.right - grid.tileSize - 4)),
      rand((grid.bounds.top + grid.tileSize + 4) .. (grid.bounds.bottom - grid.tileSize - 4))
    )
  )

  egg.addCollisionListener(
    proc(this, other: PhysicsBody, r: CollisionResult, gravityNormal: Vector): bool =
      if other of Player:
        Egg(this).onEggCollected()
  )

  layer.addChild(egg)
  grid.addPhysicsBodies(egg)

for i in 0..8:
  spawnEgg()

Input.addKeyEventListener(
  K_ESCAPE,
  proc(key: Keycode, state: KeyState) =
    Game.stop()
)

when defined(debug):
  Input.addEventListener(
    MOUSEWHEEL,
    proc(e: Event): bool =
      camera.z += float(e.wheel.y) * 0.03
  )

when not defined(debug):
  # Play some music
  let (someSong, err) = capture loadMusic("./assets/music/joy-ride.ogg")
  if err == nil:
    discard capture fadeInMusic(someSong, 3.0, 0.25)
  else:
    echo "Error playing music: " & err.msg

Game.start()

