import shade

import ui

type
  Button* = ref object of UIElement
    sprite*: Sprite

proc initButton*(button: Button) =
  initUIElement(UIElement(button))

proc newButton*(sprite: Sprite): Button =
  result = Button()
  initButton(result)
  result.sprite = sprite
  result.size = result.sprite.size

proc newButton*(imagePath: string): Button =
  let (_, image) = Images.loadImage(imagePath, FILTER_NEAREST)
  return newButton(newSprite(image))

proc scale*(this: Button): Vector =
  this.sprite.scale

proc `scale=`*(this: Button, scale: Vector) =
  this.sprite.scale = scale

template size*(this: Button): Vector =
  this.sprite.size

method render*(this: Button, ctx: Target, offsetX: float = 0, offsetY: float = 0) =
  if this.visible:
    this.sprite.render(ctx, offsetX, offsetY)

