import shade

import ui

type
  Button* = ref object of UIElement
    sprite*: Sprite
    onClickHandler*: proc()
    scale*: Vector

proc newButton*(imagePath: string): Button =
  result = Button()
  let (_, image) = Images.loadImage(imagePath, FILTER_NEAREST)
  result.sprite = newSprite(image)
  result.size = result.sprite.size
  result.scale = VECTOR_ONE

template onClick*(this: Button, body: untyped) =
  this.onClickHandler = proc() = body

method render*(this: Button, ctx: Target) =
  ctx.scale(this.scale.x, this.scale.y):
    this.sprite.render(ctx)

  when defined(renderUIBounds):
    this.getBounds().stroke(ctx)
