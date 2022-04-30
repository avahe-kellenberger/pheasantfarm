import std/[sequtils, algorithm, sets, random, tables]

import shade

import egg as eggModule
import nest as nestModule
import grid as gridModule
import ui/hud as hudModule
import ui/shop as shopModule
import grass as grassModule
import player as playerModule
import pheasant as pheasantModule
import ui/overlay as overlayModule
import ui/summary as summaryModule
import ui/itempanel as itempanelModule
import ui/gameover as gameoverModule

const
  numStartingPheasants = 10
  dayLengthInSeconds = 30
  fadeInDuration = 1.0
  startingMoney = 50
  startingPheedCount = 0 # numStartingPheasants * 2
  startingWaterCount = 0 # numStartingPheasants * 2
  startingNestCount = 0 # 2
  taxDayFrequency = 4

var
  song: Music
  menuClickSound: SoundEffect
  tooPoorSound: SoundEffect
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
    gameOverScreen*: GameOverScreen

    grid: Grid
    colliders: HashSet[PhysicsBody]

    player*: Player
    day: int
    money: int
    tax: int
    pheedCount: int
    waterCount: int
    nestCount: int

    shouldHighlightInvalidTile: bool
    invalidTile: TileCoord
    animPlayer: AnimationPlayer

    nestsOnGround: int
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
proc collectEgg(this: GameLayer, egg: Egg)
proc getTilePlayerIsFacing(this: GameLayer): TileCoord
proc isTileInPlayArea(this: GameLayer, tile: TileCoord): bool
proc placeNest(this: GameLayer, tile: TileCoord)
proc isBlocking(body: PhysicsBody): bool

template loseCondition(this: GameLayer): bool =
  this.money < 0

proc playMusic(fadeInTime: float = 0.0) =
  fadeInMusic(song, fadeInTime, 0.25)

proc isBlocking(body: PhysicsBody): bool =
  return not (body of Egg)

proc newGameLayer*(grid: Grid): GameLayer =
  result = GameLayer()
  initLayer(Layer(result))

  result.money = startingMoney
  result.pheedCount = startingPheedCount
  result.waterCount = startingWaterCount
  result.nestCount = startingNestCount

  # Play some music
  let someSong = loadMusic("./assets/music/joy-ride.ogg")
  if someSong != nil:
    song = someSong
    playMusic(3.0)

  menuClickSound = loadSoundEffect("./assets/sfx/menu-click.wav")
  tooPoorSound = loadSoundEffect("./assets/sfx/poor.wav")
  pickupSound = loadSoundEffect("./assets/sfx/pick-up.wav")
  countdownSound = loadSoundEffect("./assets/sfx/countdown.wav")
  timeUpSound = loadSoundEffect("./assets/sfx/time-up.wav")

  let this = result

  this.animPlayer = newAnimationPlayer()
  let invalidTileAnimation = newAnimation(0.5, false)
  var animCoordFrames: seq[KeyFrame[bool]] = @[
    (true, 0.0),
    (false, 0.1),
    (true, 0.2),
    (false, 0.3),
    (true, 0.4),
    (false, invalidTileAnimation.duration)
  ]
  invalidTileAnimation.addNewAnimationTrack(this.shouldHighlightInvalidTile, animCoordFrames)
  this.animPlayer.addAnimation("invalid-tile", invalidTileAnimation)

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
  result.hud.setMoney(result.money)
  result.hud.visible = false
  result.hud.setLocation(
    getLocationInParent(result.hud.position, gamestate.resolution) +
    vector(gamestate.resolution.x * 0.5, gamestate.resolution.y * 0.05)
  )
  Game.hud.addChild(result.hud)

  result.itemPanel = newItemPanel()
  result.itemPanel.setPheedCount(result.pheedCount)
  result.itemPanel.setWaterCount(result.waterCount)
  result.itemPanel.setNestCount(result.nestCount)
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

  result.summary = newSummary(
    proc() =
      if this.loseCondition():
        this.gameOverScreen.visible = true
      else:
        this.openShop()
  )
  result.summary.visible = false
  result.summary.setLocation(
    getLocationInParent(this.summary.position, gamestate.resolution) +
    vector(gamestate.resolution.x * 0.5, gamestate.resolution.y * 0.45)
  )
  Game.hud.addChild(result.summary)

  result.gameOverScreen = newGameOverScreen()
  result.gameOverScreen.visible = false
  result.gameOverScreen.setLocation(
    getLocationInParent(result.gameOverScreen.position, gamestate.resolution) +
    vector(gamestate.resolution.x * 0.5, gamestate.resolution.y * 0.45)
  )
  result.gameOverScreen.size = gamestate.resolution
  Game.hud.addChild(result.gameOverScreen)

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
      vector(gamestate.resolution.x * 0.5, gamestate.resolution.y * 0.45)
    )

    this.gameOverScreen.setLocation(
      getLocationInParent(this.gameOverScreen.position, gamestate.resolution) +
      vector(gamestate.resolution.x * 0.5, gamestate.resolution.y * 0.45)
    )
    this.gameOverScreen.size = gamestate.resolution

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
  this.spawnPhesant(PheasantKind.PURPLE_PEACOCK)

  # Nest controls
  Input.addKeyEventListener(
    K_SPACE,
    proc(key: Keycode, state: KeyState) =
      if state.justPressed and
         this.nestCount > 0 and
         this.player.isControllable and
         this.eggCount[EggKind.WHITE] > 0:
            let placementTile = this.getTilePlayerIsFacing()
            if this.isTileInPlayArea(placementTile):
              if this.grid.isTileAvailable(placementTile, isBlocking):
                this.placeNest(placementTile)
              else:
                this.invalidTile = placementTile
                this.animPlayer.play("invalid-tile")
  )

proc spawnPhesant(this: GameLayer, kind: PheasantKind) =
  let
    pheasant = createNewPheasant(kind)
    tile = this.grid.getRandomAvailableTile(isBlocking)

  if tile != NULL_TILE:
    pheasant.setLocation(this.grid.getRandomPointInTile(tile))

  this.addChild(pheasant)
  this.pheasants.add(pheasant)

  this.itemPanel.setPheasantCount(this.pheasants.len)

proc spawnEgg(this: GameLayer, kind: EggKind) =
  let
    egg = newEgg(kind)
    tile = this.grid.getRandomAvailableTile(isBlocking)

  if tile != NULL_TILE:
    egg.setLocation(this.grid.getRandomPointInTile(tile))

  egg.addCollisionListener(
    proc(bodyA, bodyB: PhysicsBody, r: CollisionResult, gravityNormal: Vector): bool =
      if bodyA of Egg and bodyB of Player:
        this.collectEgg(Egg(bodyA))
  )

  this.addChild(egg)
  this.grid.addPhysicsBodies(egg)

proc collectEgg(this: GameLayer, egg: Egg) =
  pickupSound.play()
  this.grid.removePhysicsBodies(egg)
  this.removeChild(egg)

  this.eggCount.inc(egg.eggKind)
  this.hud.setEggCount(egg.eggKind, this.eggCount[egg.eggKind])

proc getEggKind*(kind: PheasantKind): EggKind =
  case kind:
    of PheasantKind.COMMON:
      return EggKind.WHITE
    of PheasantKind.PURPLE_PEACOCK:
      return EggKind.PURPLE
    of PheasantKind.BLUE_EARED:
      return EggKind.BLUE
    of PheasantKind.GOLDEN:
      return EggKind.GOLDEN

proc startNewDay*(this: GameLayer) =
  this.isTimeCountingDown = true
  this.player.isControllable = true

proc fadeIn*(this: GameLayer) =
  this.overlay.animationPlayer.play("fade-in")

template isTaxDay(this: GameLayer): bool =
  this.day mod taxDayFrequency == 0

proc clearEggsAndNests(this: GameLayer) =
  for child in this.childIterator:
    if child of Egg or child of Nest:
      this.removeChild(child)
      this.grid.removePhysicsBodies(PhysicsBody(child))

  this.nestsOnGround = 0

proc loadNewDay*(this: GameLayer) =
  this.clearEggsAndNests()

  inc this.day
  this.summary.updateDaysTillTax(this.day, taxDayFrequency)
  this.hud.setDay(this.day)
  this.overlay.setDay(this.day)

  this.player.setLocation(this.grid.bounds.center)
  this.player.animationPlayer.playAnimation("idleDown")

  this.timeRemaining = float(dayLengthInSeconds)
  this.hud.setTimeRemaining(dayLengthInSeconds)

  let numPheasants = this.pheasants.len

  var
    pheedUsed = min(this.pheedCount, numPheasants)
    waterUsed = min(this.waterCount, numPheasants)
    bothUsed = min(pheedUsed, waterUsed)

  this.pheedCount -= pheedUsed
  this.waterCount -= waterUsed
  this.itemPanel.setPheedCount(this.pheedCount)
  this.itemPanel.setWaterCount(this.waterCount)

  # Randomize pheasants
  shuffle(this.pheasants)

  for pheasant in this.pheasants:
    let eggKind = getEggKind(pheasant.pheasantKind)
    this.spawnEgg(eggKind)

    if pheedUsed > 0:
      this.spawnEgg(eggKind)
      dec pheedUsed

    if waterUsed > 0:
      this.spawnEgg(eggKind)
      dec waterUsed

    if bothUsed > 0:
      this.spawnEgg(eggKind)
      dec bothUsed

  playMusic()

  if this.overlay.visible:
    this.fadeIn()

proc updateHUDValues(this: GameLayer) =
  this.hud.setMoney(this.money)
  for kind in EggKind.low .. EggKind.high:
    this.hud.setEggCount(kind, this.eggCount[kind])

func calcTax(day: int): int =
  return int pow(float day, 2.5)

proc openSummary(this: GameLayer) =
  this.summary.setEggCount(this.eggCount)

  let total = eggModule.calcTotal(this.eggCount)
  this.summary.setTotal(total)

  this.eggCount.clear()
  this.money = this.money + total

  if this.isTaxDay:
    this.tax = calcTax(this.day)
    this.money = this.money - this.tax
    this.summary.setTaxPrice(this.tax)

  if this.loseCondition():
    this.summary.setOutOfFunds()

  this.updateHUDValues()

  this.summary.visible = true

proc openShop(this: GameLayer) =
  # Spawn pheasants from nests
  for i in 0 ..< this.nestsOnGround:
    let randNum = rand(0..1000)
    let kind =
      case randNum:
        of 981..1000:
          PheasantKind.GOLDEN
        of 891..980:
          PheasantKind.BLUE_EARED
        of 741..890:
          PheasantKind.PURPLE_PEACOCK
        else:
          PheasantKind.COMMON

    this.spawnPhesant(kind)

  this.shop.visible = true

proc tryPurchase(this: GameLayer, item: Item, qty: int) =
  let price = ITEM_PRICES[item] * qty
  if this.money >= price:
    menuClickSound.play()
    this.money -= price
    this.hud.setMoney(this.money)

    case item:
      of Item.PHEED:
        this.pheedCount += qty
        this.itemPanel.setPheedCount(this.pheedCount)
      of Item.WATER:
        this.waterCount += qty
        this.itemPanel.setWaterCount(this.waterCount)
      of Item.NEST:
        this.nestCount += qty
        this.itemPanel.setNestCount(this.nestCount)
  else:
    tooPoorSound.play()

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
  this.player.velocity = VECTOR_ZERO
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

proc getTilePlayerIsFacing(this: GameLayer): TileCoord =
  var playerLoc = this.player.getLocation()
  playerLoc.x += this.grid.tileSize * float this.player.direction.x
  playerLoc.y += this.grid.tileSize * float this.player.direction.y
  return this.grid.worldCoordToTile(playerLoc.x, playerLoc.y)

proc isTileInPlayArea(this: GameLayer, tile: TileCoord): bool =
  return
    tile.x >= 1 and tile.x <= this.grid.width - 2 and
    tile.y >= 1 and tile.y <= this.grid.height - 3

proc checkNestAndEggCollisions(this: GameLayer, nest: Nest, tile: TileCoord) =
  let bodiesInTile = this.grid[tile.x, tile.y]
  for body in bodiesInTile:
    if not (body of Egg):
      continue

    let
      collisionResult = collides(
        nest.getLocation(),
        nest.collisionShape,
        body.getLocation(),
        body.collisionShape
      )

    if collisionResult != nil:
      this.collectEgg(Egg(body))

proc placeNest(this: GameLayer, tile: TileCoord) =
  if tile != NULL_TILE:
    let nest = newNest()
    nest.setLocation(this.grid.tileToWorldCoord(tile))
    this.addChild(nest)
    this.grid.addPhysicsBodies(nest)
    dec this.nestCount
    inc this.nestsOnGround
    this.eggCount.inc(EggKind.WHITE, -1)
    this.hud.setEggCount(EggKind.WHITE, this.eggCount[EggKind.WHITE])
    this.itemPanel.setNestCount(this.nestCount)

    this.checkNestAndEggCollisions(nest, tile)

method update*(this: GameLayer, deltaTime: float, onChildUpdate: proc(child: Node) = nil) =
  procCall Layer(this).update(deltaTime, onChildUpdate)
  this.checkCollisions()
  this.updateTimer(deltaTime)
  this.overlay.update(deltaTime)
  this.animPlayer.update(deltaTime)

method render*(this: GameLayer, ctx: Target, callback: proc() = nil) =
  let camera = Game.scene.camera
  when defined(debug):
    this.grid.render(ctx, camera)
    let mouseInWorldSpace = camera.screenToWorldCoord(Input.mouseLocation, this.z - camera.z)
    let tile = this.grid.worldCoordToTile(mouseInWorldSpace)
    if tile != NULL_TILE:
      this.grid.highlightTile(ctx, tile, PURPLE, true)

  if this.shouldHighlightInvalidTile and this.invalidTile != NULL_TILE:
    this.grid.highlightTile(ctx, this.invalidTile, RED, forceColor = true)

  procCall Layer(this).render(ctx, callback)

