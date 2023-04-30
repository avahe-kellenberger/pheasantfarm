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
import tags as tagsModule

const
  numStartingPheasants = 10 # 10_000
  dayLengthInSeconds = 1
  startingMoney = 50
  startingPheedCount = 0 # numStartingPheasants * 2
  startingWaterCount = 0 # numStartingPheasants * 2
  startingNestCount = 0 # 2
  taxDayFrequency = 4
  fadeAnimationTime = 15.0

var
  hasGameStarted = false
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

    innerFenceArea: AABB
    innerFenceAreaForPheasants: AABB

    # Only dynamic physics bodies that require collision checks
    bodies: SafeSet[PhysicsBody]
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

    nestsOnGround: seq[Nest]
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

proc `innerFenceArea=`*(this: GameLayer, aabb: AABB) =
  this.innerFenceArea = aabb

  let halfWidth = pheasantAABB.width * 0.5
  this.innerFenceAreaForPheasants = aabb(
    this.innerFenceArea.left + halfWidth,
    this.innerFenceArea.top + pheasantAABB.height,
    this.innerFenceArea.right - halfWidth,
    this.innerFenceArea.bottom
  )

proc playMusic(fadeInTime: float = 0.0) =
  discard
  # fadeInMusic(song, fadeInTime, 0.25)

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

  let root = Game.getUIRoot()
  root.alignVertical = Alignment.Center
  root.alignHorizontal = Alignment.Center

  result.overlay = newOverlay(
    fadeAnimationTime,
    proc () = this.openSummary,
    proc () = this.startNewDay
  )

  result.overlay.visible = false

  root.addChild(result.overlay)

  let hudContainer = newUIComponent()
  hudContainer.alignHorizontal = Alignment.Center
  hudContainer.processInputEvents = false

  result.hud = newHUD()
  result.hud.setTimeRemaining(0)
  result.hud.setMoney(result.money)
  result.hud.visible = false

  hudContainer.addChild(result.hud)
  root.addChild(hudContainer)

  let itemPanelContainer = newUIComponent()
  itemPanelContainer.alignVertical = Alignment.Center
  itemPanelContainer.processInputEvents = false

  result.itemPanel = newItemPanel()
  result.itemPanel.setPheedCount(result.pheedCount)
  result.itemPanel.setWaterCount(result.waterCount)
  result.itemPanel.setNestCount(result.nestCount)
  result.itemPanel.visible = false

  itemPanelContainer.addChild(result.itemPanel)
  root.addChild(itemPanelContainer)

  result.shop = newShop(
    (proc(item: Item, qty: int) = this.tryPurchase(item, qty)),
    (proc() = this.loadNewDay())
  )
  result.shop.visible = false
  root.addChild(result.shop)

  result.summary = newSummary(
    proc() =
      if this.loseCondition():
        this.gameOverScreen.visible = true
      else:
        this.openShop()
  )
  result.summary.visible = false
  root.addChild(result.summary)

  result.gameOverScreen = newGameOverScreen()
  result.gameOverScreen.visible = false

  root.addChild(result.gameOverScreen)

  result.bodies = newSafeset[PhysicsBody]()
  result.grid = grid
  result.colliders = initHashSet[PhysicsBody]()

  let camera = newCamera()
  camera.z = 0.85
  camera.setLocation(grid.bounds.center)
  Game.scene.camera = camera

  when defined(debug):
    Input.addListener(
      MOUSEWHEEL,
      proc(e: Event): bool =
        camera.z += float(e.wheel.y) * 0.03
    )

  # Create player
  result.player = newPlayer()
  result.player.setLocation(grid.bounds.center)
  result.addChild(result.player)
  result.bodies.add(result.player)

  camera.setTrackedNode(result.player)
  camera.setTrackingEasingFunction(easeOutQuadratic)
  camera.completionRatioPerFrame = 0.03

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
  Input.addKeyPressedListener(
    K_SPACE,
    proc(key: Keycode, state: KeyState) =
      if state.justPressed and
         this.nestCount > 0 and
         this.player.isControllable and
         len(this.eggCount) > 0:
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
  this.bodies.add(pheasant)
  this.pheasants.add(pheasant)

  this.itemPanel.setPheasantCount(this.pheasants.len)

proc spawnEgg(this: GameLayer, kind: EggKind) =
  let
    egg = newEgg(kind)
    tile = this.grid.getRandomAvailableTile(isBlocking)

  if tile != NULL_TILE:
    egg.setLocation(this.grid.getRandomPointInTile(tile))

  this.addChild(egg)
  this.grid.addPhysicsBodies(tagEgg, egg)

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
  hasGameStarted = true
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

  this.nestsOnGround.setLen(0)

proc loadNewDay*(this: GameLayer) =
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
  for nest in this.nestsOnGround:
    var bestPheasantKind = PheasantKind.COMMON
    let numRolls = ord(nest.eggKind) + 1
    for _ in 0..<numRolls:
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
      if kind > bestPheasantKind:
        bestPheasantKind = kind

    this.spawnPhesant(bestPheasantKind)

  this.clearEggsAndNests()
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

proc resolveCollision(this: GameLayer, bodyA, bodyB: PhysicsBody, collisionResult: CollisionResult) =
  if bodyA of Player and bodyB of Egg:
    this.collectEgg(Egg(bodyB))
    return
  bodyA.move(collisionResult.getMinimumTranslationVector())

proc detectCollision(this: GameLayer, bodyA, bodyB: PhysicsBody) =
  let
    collisionResult = collides(
      bodyA.getLocation(),
      bodyA.collisionShape,
      bodyB.getLocation(),
      bodyB.collisionShape
    )

  if collisionResult != nil:
    this.resolveCollision(bodyA, bodyB, collisionResult)

proc isPheasantCollidableWithFences(this: GameLayer, body: PhysicsBody, bounds: AABB): bool =
  return not this.innerFenceAreaForPheasants.contains(body.getLocation())

proc getCollidableTags(this: GameLayer, body: PhysicsBody, bounds: AABB): seq[int] =
  if body of Pheasant:
    # Perform special bounds check for pheasants
    if this.isPheasantCollidableWithFences(body, bounds):
      return @[tagFence]
  elif body of Player:
    return @[tagFence, tagEgg]
  return @[]

proc checkCollisions(this: GameLayer) =
  for body in this.bodies:
    let bounds = body.getBounds()
    if bounds == AABB_ZERO:
      continue

    let collidableTags = this.getCollidableTags(body, bounds)
    if len(collidableTags) == 0:
      continue

    for (x, y) in this.grid.findOverlappingTiles(bounds):
      for bodyInGrid in this.grid.query(x, y, collidableTags):
        this.colliders.incl(bodyInGrid)

    for collider in this.colliders:
      this.detectCollision(body, collider)

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

    if not this.overlay.visible and this.timeRemaining <= fadeAnimationTime - 0.5:
      this.overlay.visible = true
      this.overlay.animationPlayer.play("fade-out")
      this.overlay.animationPlayer.update(fadeAnimationTime - this.timeRemaining)

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
  for body in this.grid.query(tile.x, tile.y, tagEgg):
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
    var bestEggKind = EggKind.WHITE
    for eggKind in countdown(EggKind.high, EggKind.low):
      if this.eggCount[eggKind] > 0:
        bestEggKind = eggKind
        break
    # Create new nest using best egg
    let nest = newNest(bestEggKind)
    nest.setLocation(this.grid.tileToWorldCoord(tile) + vector(0, nest.sprite.size.y * 0.5))
    this.addChild(nest)
    this.grid.addPhysicsBodies(tagNest, nest)
    dec this.nestCount
    this.nestsOnGround.add(nest)
    this.eggCount.inc(bestEggKind, -1)
    this.hud.setEggCount(bestEggKind, this.eggCount[bestEggKind])
    this.itemPanel.setNestCount(this.nestCount)

    this.checkNestAndEggCollisions(nest, tile)

method update*(this: GameLayer, deltaTime: float) =
  if this.isTimeCountingDown or not hasGameStarted:
    # Make the camera snap to pixels to prevent shaking effect).
    let cameraLoc = Game.scene.camera.getLocation()
    Game.scene.camera.setLocation(ceil cameraLoc.x, ceil cameraLoc.y)

    procCall Layer(this).update(deltaTime)
    this.checkCollisions()
    this.updateTimer(deltaTime)
    this.animPlayer.update(deltaTime)

  this.overlay.update(deltaTime)

method render*(this: GameLayer, ctx: Target, offsetX: float = 0, offsetY: float = 0) =
  if hasGameStarted and not this.isTimeCountingDown:
    return

  when defined(debug):
    let camera = Game.scene.camera
    this.grid.render(ctx, camera, offsetX, offsetY)
    let mouseInWorldSpace = camera.screenToWorldCoord(Input.mouseLocation, this.z - camera.z)
    let tile = this.grid.worldCoordToTile(mouseInWorldSpace)
    if tile != NULL_TILE:
      this.grid.highlightTile(ctx, tile, offsetX, offsetY, PURPLE, true)

  if this.shouldHighlightInvalidTile and this.invalidTile != NULL_TILE:
    this.grid.highlightTile(ctx, this.invalidTile, offsetX, offsetY, RED, forceColor = true)

  procCall Layer(this).render(ctx, offsetX, offsetY)
