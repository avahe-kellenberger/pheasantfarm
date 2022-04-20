import shade
import pheasantfarmpkg/pheasant

initEngineSingleton(
  "Pheasant Pharm",
  1920,
  1080,
  fullscreen = true,
  clearColor = newColor(0, 102, 17)
)

let layer = newPhysicsLayer(gravity = VECTOR_ZERO, z = 1.0)
Game.scene.addLayer layer

# Pheasant
let player = createNewPheasant()

let camera = newCamera()
camera.z = 0.8
Game.scene.camera = camera

layer.addChild(player)

# Custom physics handling for the player
const speed = 40.0

proc physicsProcess(this: Node, deltaTime: float) =
  if Input.wasKeyJustPressed(K_ESCAPE):
    Game.stop()
    return

  let
    leftStickX = Input.leftStickX()
    leftPressed = Input.isKeyPressed(K_LEFT) or leftStickX < -0.01
    rightPressed = Input.isKeyPressed(K_RIGHT) or leftStickX > 0.01

  proc run() =
    ## Handles player running
    if leftPressed == rightPressed:
      # TODO: Need to finish run animation, then transition to idle.
      # Can do this with a finite state machine.
      player.playAnimation("idle")
      player.velocityX = 0
    else:
      if rightPressed:
        player.velocityX = speed
        if player.scale.x < 0.0:
          player.scale = vector(abs(player.scale.x), player.scale.y)
      else:
        player.velocityX = -speed
        if player.scale.y > 0.0:
          player.scale = vector(-1 * abs(player.scale.x), player.scale.y)

      player.playAnimation("run")

  run()

  camera.z += Input.wheelScrolledLastFrame.float * 0.03

player.onUpdate = physicsProcess

when not defined(debug):
  # Play some music
  let (someSong, err) = capture loadMusic("./assets/night_prowler.ogg")
  if err == nil:
    discard capture fadeInMusic(someSong, 2.0, 0.15)
  else:
    echo "Error playing music: " & err.msg

Game.start()

