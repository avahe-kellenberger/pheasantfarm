import shade

import ui

type
  Button* = ref object
    position*: Position
    sprite*: Sprite
    scale*: Vector
    onClickHandler*: proc()

proc newButton*(imagePath: string): Button =
  result = Button()
  let (_, image) = Images.loadImage(imagePath, FILTER_NEAREST)
  result.sprite = newSprite(image)
  result.scale = VECTOR_ONE

template onClick*(this: Button, body: untyped) =
  this.onClickHandler = proc() = body

proc size*(this: Button): Vector =
  return this.sprite.size

proc render*(this: Button, ctx: Target) =
  this.sprite.render(ctx)

  when defined(renderUIBounds):
    this.getBounds().stroke(ctx)
