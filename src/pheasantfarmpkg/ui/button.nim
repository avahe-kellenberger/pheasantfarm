import shade

import ui

type
  Button* = ref object of UIElement
    sprite*: Sprite
    onClickHandler*: proc()
    scale*: Vector

proc initButton*(button: Button) =
  initUIElement(UIElement(button))

proc newButton*(sprite: Sprite): Button =
  result = Button()
  initButton(result)
  result.sprite = sprite
  result.size = result.sprite.size
  result.scale = VECTOR_ONE

proc newButton*(imagePath: string): Button =
  let (_, image) = Images.loadImage(imagePath, FILTER_NEAREST)
  return newButton(newSprite(image))

template size*(this: Button): Vector =
  this.sprite.size

template onClick*(this: Button, body: untyped) =
  this.onClickHandler = proc() = body

Button.renderAsChildOf(UIElement):
  ctx.scale(this.scale.x, this.scale.y):
    this.sprite.render(ctx)

  when defined(renderUIBounds):
    this.getBounds().stroke(ctx)
