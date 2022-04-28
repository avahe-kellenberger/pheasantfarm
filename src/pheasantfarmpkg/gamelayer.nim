import std/[sequtils, algorithm, sets, random, tables]

import shade

import egg as eggModule
import grid as gridModule
import ui/hud as hudModule
import ui/itempanel as itempanelModule
import ui/shop as shopModule
import grass as grassModule
import player as playerModule
import pheasant as pheasantModule
import ui/overlay as overlayModule
import ui/summary as summaryModule

const
  numStartingPheasants = 15
  dayLengthInSeconds = 30
  fadeInDuration = 1.0

var
  song: Music
  pickupSound: SoundEffect
  countdownSound: SoundEffect
  timeUpSound: SoundEffect

type
  GameLayer* = ref object of Layer
    hud*: HUD
    itemPanel*: ItemPanel
    summary*: Summary
    shop*: Shop
    overlay*: Overlay

    grid: Grid
    colliders: HashSet[PhysicsBody]

    player*: Player
    day: int
    money: int
    timeRemaining: float
    pheasants: seq[Pheasant]
    isTimeCountingDown*: bool
    fadeInTime: float
    eggCount: CountTable[EggKind]

proc startNewDay*(this: GameLayer)
proc loadNewDay*(this: GameLayer)
proc openShop(this: GameLayer)
proc tryPurchase(this: GameLayer, item: Item, qty: int)
proc openSummary(this: GameLayer)
proc spawnPhesant(this: GameLayer, kind: PheasantKind)
proc spawnEgg(this: GameLayer, kind: EggKind)
proc onEggCollected(this: GameLayer, egg: Egg)

proc playMusic(fadeInTime: float = 0.0) =
  discard capture fadeInMusic(song, fadeInTime, 0.25)

proc newGameLayer*(grid: Grid): GameLayer =
  result = GameLayer()
  initLayer(Layer(result))

  # Play some music
  let (someSong, err) = capture loadMusic("./assets/music/joy-ride.ogg")
  if err == nil:
    song = someSong
    playMusic(3.0)
  else:
    echo "Error playing music: " & err.msg

  pickupSound = loadSoundEffect("./assets/sfx/pick-up.wav")
  countdownSound = loadSoundEffect("./assets/sfx/countdown.wav")
  timeUpSound = loadSoundEffect("./assets/sfx/time-up.wav")

  let this = result
  result.overlay = newOverlay(
    proc () = this.openSummary,
    proc () = this.startNewDay
  )
  result.overlay.size = gamestate.resolution
  result.overlay.visible = false
  this.overlay.setLocation(
    getLocationInParent(this.overlay.position, gamestate.resolution) +
    gamestate.resolution * 0.5
  )

  Game.hud.addChild(result.overlay)

  result.hud = newHUD()
  result.hud.setTimeRemaining(0)
  result.hud.setMoney(0)
  result.hud.visible = false
  result.hud.setLocation(
    getLocationInParent(result.hud.position, gamestate.resolution) +
    vector(gamestate.resolution.x * 0.5, gamestate.resolution.y * 0.05)
  )
  Game.hud.addChild(result.hud)

  result.itemPanel = newItemPanel()
  result.itemPanel.visible = false
  result.itemPanel.setLocation(
    getLocationInParent(result.itemPanel.position, gamestate.resolution) +
    vector(result.itemPanel.size.x * 0.5, gamestate.resolution.y * 0.5)
  )
  Game.hud.addChild(result.itemPanel)

  result.shop = newShop(
    (proc(item: Item, qty: int) = this.tryPurchase(item, qty)),
    (proc() = this.loadNewDay())
  )
  result.shop.visible = false
  result.shop.setLocation(
    getLocationInParent(this.shop.position, gamestate.resolution) +
    vector(gamestate.resolution.x * 0.5, gamestate.resolution.y * 0.35)
  )
  Game.hud.addChild(result.shop)

  result.summary = newSummary(proc() = this.openShop)
  result.summary.visible = false
  result.summary.setLocation(
    getLocationInParent(this.summary.position, gamestate.resolution) +
    vector(gamestate.resolution.x * 0.5, gamestate.resolution.y * 0.35)
  )
  Game.hud.addChild(result.summary)

  gamestate.onResolutionChanged:
    this.hud.setLocation(
      getLocationInParent(this.hud.position, gamestate.resolution) +
      vector(gamestate.resolution.x * 0.5, gamestate.resolution.y * 0.05)
    )

    this.itemPanel.setLocation(
      getLocationInParent(this.itemPanel.position, gamestate.resolution) +
      vector(this.itemPanel.size.x * 0.5, gamestate.resolution.y * 0.5)
    )

    this.overlay.setLocation(
      getLocationInParent(this.overlay.position, gamestate.resolution) +
      gamestate.resolution * 0.5
    )
    this.overlay.size = gamestate.resolution

    this.shop.setLocation(
      getLocationInParent(this.shop.position, gamestate.resolution) +
      vector(gamestate.resolution.x * 0.5, gamestate.resolution.y * 0.35)
    )

    this.summary.setLocation(
      getLocationInParent(this.summary.position, gamestate.resolution) +
      vector(gamestate.resolution.x * 0.5, gamestate.resolution.y * 0.35)
    )

  result.grid = grid
  result.colliders = initHashSet[PhysicsBody]()

  let camera = newCamera()
  camera.z = 0.85
  camera.setLocation(grid.bounds.center)
  Game.scene.camera = camera

  when defined(debug):
    Input.addEventListener(
      MOUSEWHEEL,
      proc(e: Event): bool =
        camera.z += float(e.wheel.y) * 0.03
    )

  # Create player
  result.player = newPlayer()
  result.player.setLocation(grid.bounds.center)
  result.addChild(result.player)

  camera.setTrackedNode(result.player)
  camera.setTrackingEasingFunction(easeOutQuadratic)
  camera.completionRatioPerFrame = 0.05

  result.eggCount = initCountTable[EggKind]()

  for i in 0..250:
    let grass = newGrass()
    grass.setLocation(
      vector(
        rand((grid.bounds.left + grid.tileSize + 4) .. (grid.bounds.right - grid.tileSize - 4)),
        rand((grid.bounds.top + grid.tileSize + 4) .. (grid.bounds.bottom - grid.tileSize - 4))
      )
    )
    result.addChild(grass)

  for i in 1..<numStartingPheasants:
    this.spawnPhesant(PheasantKind.COMMON)
  this.spawnPhesant(PheasantKind.GRAY_PEACOCK)

proc spawnPhesant(this: GameLayer, kind: PheasantKind) =
  let pheasant = createNewPheasant(kind)
  pheasant.setLocation(
    this.grid.bounds.center +
    vector(rand(-120.0 .. 120.0), rand(-80.0 .. 80.0))
  )
  this.addChild(pheasant)
  this.pheasants.add(pheasant)

  this.itemPanel.setPheasantCount(this.pheasants.len)

proc spawnEgg(this: GameLayer, kind: EggKind) =
  let egg = newEgg(kind)
  egg.setLocation vector(
    rand((this.grid.bounds.left + this.grid.tileSize + 4) .. (this.grid.bounds.right - this.grid.tileSize - 4)),
    rand((this.grid.bounds.top + this.grid.tileSize + 4) .. (this.grid.bounds.bottom - this.grid.tileSize * 2 - 4))
  )

  egg.addCollisionListener(
    proc(bodyA, bodyB: PhysicsBody, r: CollisionResult, gravityNormal: Vector): bool =
      if bodyA of Egg and bodyB of Player:
        this.onEggCollected(Egg(bodyA))
  )

  this.addChild(egg)
  this.grid.addPhysicsBodies(egg)

proc onEggCollected(this: GameLayer, egg: Egg) =
  pickupSound.play()
  this.grid.removePhysicsBodies(egg)
  this.removeChild(egg)

  this.eggCount.inc(egg.eggKind)
  this.hud.setEggCount(egg.eggKind, this.eggCount[egg.eggKind])

proc getEggKind*(kind: PheasantKind): EggKind =
  case kind:
    of PheasantKind.COMMON:
      return EggKind.WHITE
    of PheasantKind.GRAY_PEACOCK:
      return EggKind.GRAY
    of PheasantKind.BLUE_EARED:
      return EggKind.BLUE
    of PheasantKind.GOLDEN:
      return EggKind.GOLDEN

proc startNewDay*(this: GameLayer) =
  this.isTimeCountingDown = true
  this.player.isControllable = true

proc fadeIn*(this: GameLayer) =
  this.overlay.animationPlayer.play("fade-in")

proc loadNewDay*(this: GameLayer) =
  inc this.day
  this.hud.setDay(this.day)
  this.overlay.setDay(this.day)

  this.player.setLocation(this.grid.bounds.center)
  this.player.animationPlayer.playAnimation("idleDown")
  this.player.velocity = VECTOR_ZERO

  this.timeRemaining = float(dayLengthInSeconds)
  this.hud.setTimeRemaining(dayLengthInSeconds)

  for i in 0 ..< 3:
    this.spawnPhesant(PheasantKind.COMMON)

  for pheasant in this.pheasants:
    this.spawnEgg(getEggKind(pheasant.pheasantKind))

  playMusic()

  if this.overlay.visible:
    this.fadeIn()

proc updateHUDValues(this: GameLayer) =
  this.hud.setMoney(this.money)
  for kind in EggKind.low .. EggKind.high:
    this.hud.setEggCount(kind, this.eggCount[kind])

proc openSummary(this: GameLayer) =
  this.summary.setEggCount(this.eggCount)

  let total = eggModule.calcTotal(this.eggCount)
  this.summary.setTotal(total)

  this.eggCount.clear()
  this.money += total
  this.updateHUDValues()

  this.summary.visible = true

proc openShop(this: GameLayer) =
  this.shop.visible = true

proc tryPurchase(this: GameLayer, item: Item, qty: int) =
  # TODO
  echo "Try to purchase " & $qty & " " & $item

method visitChildren*(this: GameLayer, handler: proc(child: Node)) =
  var childrenSeq = this.childIterator.toSeq
  childrenSeq.sort do (a, b: Node) -> int:
    return cmp(a.y, b.y)

  for child in childrenSeq:
    handler(child)

proc resolveCollision(this: GameLayer, bodyA, bodyB: PhysicsBody) =
  let
    collisionResult = collides(
      bodyA.getLocation(),
      bodyA.collisionShape,
      bodyB.getLocation(),
      bodyB.collisionShape
    )

  if collisionResult != nil:
    bodyA.move(collisionResult.getMinimumTranslationVector())

    bodyA.notifyCollisionListeners(bodyB, collisionResult, VECTOR_ZERO)
    bodyB.notifyCollisionListeners(bodyA, collisionResult.invert(), VECTOR_ZERO)

proc checkCollisions(this: GameLayer) =
  for child in this.childIterator:
    if child of PhysicsBody:
      let 
        body = PhysicsBody(child)
        bounds = body.getBounds()

      if bounds != nil and body.kind != PhysicsBodyKind.STATIC:
        for (x, y) in this.grid.findOverlappingTiles(bounds):
          for bodyInGrid in this.grid[x, y]:
            if body != bodyInGrid:
              this.colliders.incl(bodyInGrid)

        for collider in this.colliders:
          this.resolveCollision(body, collider)

        this.colliders.clear()

proc onTimerEnd(this: GameLayer) =
  timeUpSound.play(0.4)

  this.player.isControllable = false
  this.isTimeCountingDown = false

template onSecondCountdown(this: GameLayer, time: int) =
  this.hud.setTimeRemaining(time)
  if time == 0:
    this.onTimerEnd()
  else:
    countdownSound.play(0.35)

proc updateTimer(this: GameLayer, deltaTime: float) =
  if this.isTimeCountingDown:
    let oldTimeInSeconds = int ceil(this.timeRemaining)
    this.timeRemaining = max(0.0, this.timeRemaining - deltaTime)
    let newTimeInSeconds = int ceil(this.timeRemaining)

    if oldTimeInSeconds != newTimeInSeconds:
      this.onSecondCountdown(newTimeInSeconds)

    if not this.overlay.visible and this.timeRemaining <= 14.5:
      this.overlay.visible = true
      this.overlay.animationPlayer.play("fade-out")
      this.overlay.animationPlayer.update(15 - this.timeRemaining)

method update*(this: GameLayer, deltaTime: float, onChildUpdate: proc(child: Node) = nil) =
  procCall Layer(this).update(deltaTime, onChildUpdate)
  this.checkCollisions()
  this.updateTimer(deltaTime)
  this.overlay.update(deltaTime)

when defined(debug):
  method render*(this: GameLayer, ctx: Target, callback: proc() = nil) =
    let camera = Game.scene.camera
    this.grid.render(ctx, camera)
    let mouseInWorldSpace = camera.screenToWorldCoord(Input.mouseLocation, this.z - camera.z)
    let tileOpt = this.grid.worldCoordToTile(mouseInWorldSpace)
    if tileOpt.isSome():
      let tile = tileOpt.get()
      this.grid.highlightTile(ctx, tile)

    procCall Layer(this).render(ctx, callback)

