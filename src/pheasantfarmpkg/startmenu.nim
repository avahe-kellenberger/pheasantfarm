import shade

var
  startImageIndex = -1
  startSprite: Sprite

proc newStartMenu*(): Node =
  result = newNode()
  if startImageIndex < 0:
    let (i, startImage) = Images.loadImage("./assets/start.png", FILTER_NEAREST)
    startImageIndex = i
    startSprite = newSprite(startImage)

  result.scale = vector(0.25, 0.25)

  result.onRender = proc(this: Node, ctx: Target) =
    startSprite.render(ctx)

