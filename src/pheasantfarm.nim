import std/random
import shade

import pheasantfarmpkg/[fences, gamelayer]
import pheasantfarmpkg/ui/startmenu as startMenuModule
import pheasantfarmpkg/player as playerModule
import pheasantfarmpkg/grid as gridModule

randomize()

when isMainModule:
  initEngineSingleton(
    "Pheasant Pharm",
    1920,
    1080,
    fullscreen = true,
    clearColor = newColor(26, 136, 24),
    iconFilename = "./assets/icon.png"
  )

  Game.hud = newLayer()

  let grid = newGrid(20, 13, 16)
  let layer = newGameLayer(grid)
  Game.scene.addLayer(layer)

  layer.innerFenceArea = generateAndAddFences(layer, grid)

  layer.loadNewDay()

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

  let menuClickSound = loadSoundEffect("./assets/sfx/menu-click.wav")

  startMenu.startButton.onClick:
    menuClickSound.play()
    Game.hud.removeChild(startMenu)
    startMenu.visible = false

    # Add in-game HUD
    layer.hud.visible = true
    layer.itemPanel.visible = true

    layer.startNewDay()

  startMenu.quitButton.onClick:
    Game.stop()

  Input.addKeyPressedListener(
    K_ESCAPE,
    proc(key: Keycode, state: KeyState) =
      Game.stop()
  )

  Game.start()

