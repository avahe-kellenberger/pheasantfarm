import shade
import std/random
import pheasantfarmpkg/pheasant

initEngineSingleton(
  "Pheasant Pharm",
  1920,
  1080,
  fullscreen = true,
  clearColor = newColor(26, 136, 24)
)

let layer = newPhysicsLayer(gravity = VECTOR_ZERO)
Game.scene.addLayer layer

# Pheasant
let camera = newCamera()
camera.z = 0.8
Game.scene.camera = camera

for i in 0..8:
  let pheasant = createNewPheasant()
  pheasant.setLocation(vector(rand(-120.0 .. 120.0), rand(-80.0 .. 80.0)))
  layer.addChild(pheasant)

Input.addKeyEventListener(
  K_ESCAPE,
  proc(key: Keycode, state: KeyState) =
    Game.stop()
)

Input.addEventListener(
  MOUSEWHEEL,
  proc(e: Event): bool =
    camera.z += float(e.wheel.y) * 0.03
)

when not defined(debug):
  # Play some music
  let (someSong, err) = capture loadMusic("./assets/music/joy-ride.ogg")
  if err == nil:
    discard capture fadeInMusic(someSong, 2.0, 0.3)
  else:
    echo "Error playing music: " & err.msg

Game.start()

