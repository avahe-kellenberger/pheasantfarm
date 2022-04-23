import shade
import pheasantfarmpkg/pheasant

initEngineSingleton(
  "Pheasant Pharm",
  1920,
  1080,
  fullscreen = true,
  clearColor = newColor(0, 102, 17)
)

let layer = newPhysicsLayer(gravity = VECTOR_ZERO)
Game.scene.addLayer layer

# Pheasant
let player = createNewPheasant()

let camera = newCamera()
camera.z = 0.8
Game.scene.camera = camera

layer.addChild(player)

# Custom physics handling for the player
const speed = 16.0

proc onUpdate(this: Node, deltaTime: float) =
  if Input.wasKeyJustPressed(K_ESCAPE):
    Game.stop()
    return

  camera.z += Input.wheelScrolledLastFrame.float * 0.03

player.onUpdate = onUpdate

when not defined(debug):
  # Play some music
  let (someSong, err) = capture loadMusic("./assets/night_prowler.ogg")
  if err == nil:
    discard capture fadeInMusic(someSong, 2.0, 0.15)
  else:
    echo "Error playing music: " & err.msg

Game.start()

