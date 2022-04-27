import shade

import ui

type
  Button* = ref object of UIElement
    sprite*: Sprite
    onClickHandler*: proc()

proc newButton*(imagePath: string): Button =
  result = Button()
  let (_, image) = Images.loadImage(imagePath, FILTER_NEAREST)
  result.sprite = newSprite(image)
  result.size = result.sprite.size

template onClick*(this: Button, body: untyped) =
  this.onClickHandler = proc() = body

method render*(this: Button, ctx: Target) =
  procCall UIElement(this).render(ctx)
  this.sprite.render(ctx)

  when defined(renderUIBounds):
    this.getBounds().stroke(ctx)
