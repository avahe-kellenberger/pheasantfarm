import std/random
import shade

import pheasantfarmpkg/[fences, gamelayer, constants]
import pheasantfarmpkg/ui/startmenu as startMenuModule
import pheasantfarmpkg/ui/hiscoresmenu as hiscoresMenuModule
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

  let root = newUIComponent()
  Game.setUIRoot(root)
  root.stackDirection = Overlap

  let grid = newGrid(20, 13, 16 * RENDER_SCALAR)
  let layer = newGameLayer(grid)
  Game.scene.addLayer(layer)

  layer.innerFenceArea = generateAndAddFences(layer, grid)

  layer.loadNewDay()

  # Set up the start menu
  let startMenu = newStartMenu()
  root.addChild(startMenu)

  let menuClickSound = loadSoundEffect("./assets/sfx/menu-click.wav")

  startMenu.startButton.onPressed:
    menuClickSound.play()
    root.removeChild(startMenu)
    startMenu.visible = false

    # Add in-game HUD
    layer.hud.visible = true
    layer.itemPanel.visible = true

    layer.startNewDay()

  let hiscoresMenu = newHiscoresMenu()
  hiscoresMenu.disableAndHide()

  root.addChild(hiscoresMenu)
  startMenu.hiscoresButton.onPressed:
    menuClickSound.play()
    startMenu.disableAndHide()
    hiscoresMenu.enableAndSetVisible()
    hiscoresMenu.populateScores()

  hiscoresMenu.backButton.onPressed:
    menuClickSound.play()
    hiscoresMenu.disableAndHide()
    startMenu.enableAndSetVisible()

  startMenu.quitButton.onPressed:
    Game.stop()

  Input.addKeyPressedListener(
    K_ESCAPE,
    proc(key: Keycode, state: KeyState) =
      if layer != nil:
        if layer.isGameOver:
          layer.gameOverScreen.quitButton.handlePress(0, 0)
        else:
          Game.stop()
  )

  Game.start()

