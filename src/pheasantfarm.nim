import shade

import pheasantfarmpkg/[fences, gamelayer]
import pheasantfarmpkg/ui/startmenu as startMenuModule
import pheasantfarmpkg/player as playerModule
import pheasantfarmpkg/grid as gridModule

when isMainModule:
  initEngineSingleton(
    "Pheasant Pharm",
    1920,
    1080,
    fullscreen = true,
    clearColor = newColor(26, 136, 24)
  )

  Game.hud = newLayer()

  let gridLayer = newLayer()
  Game.scene.addLayer(gridLayer)

  let grid = newGrid(20, 13, 16)
  let layer = newGameLayer(grid)
  Game.scene.addLayer(layer)

  generateAndAddFences(layer, grid)

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
    layer.overlay.visible = true

    layer.startNewDay()

  startMenu.quitButton.onClick:
    Game.stop()

  Input.addKeyEventListener(
    K_ESCAPE,
    proc(key: Keycode, state: KeyState) =
      Game.stop()
  )

  when not defined(debug):
    # Play some music
    let (someSong, err) = capture loadMusic("./assets/music/joy-ride.ogg")
    if err == nil:
      discard capture fadeInMusic(someSong, 3.0, 0.25)
    else:
      echo "Error playing music: " & err.msg

  Game.start()

