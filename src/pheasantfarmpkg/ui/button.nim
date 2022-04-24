import shade

type
  Button* = ref object
    location: Vector
    sprite*: Sprite
    bounds: AABB
    scale*: Vector

proc getBounds*(this: Button): AABB
proc setLocation*(this: Button, x, y: float)

proc newButton*(imagePath: string): Button =
  result = Button()
  let (_, image) = Images.loadImage(imagePath, FILTER_NEAREST)
  result.sprite = newSprite(image)

template x*(this: Button): float =
  this.location.x

template y*(this: Button): float =
  this.location.y

template move*(this: Button, dx, dy: float) =
  this.setLocation(this.x + dx, this.y + dy)

proc contains*(this: Button, point: Vector): bool =
  return this.getBounds().contains(point)

proc getBounds*(this: Button): AABB =
  if this.bounds == nil:
    let halfSpriteSize = this.sprite.size * 0.5 * this.scale
    this.bounds = newAABB(
      this.x - halfSpriteSize.x,
      this.y - halfSpriteSize.y,
      this.x + halfSpriteSize.x,
      this.x + halfSpriteSize.y
    )
  return this.bounds

proc setLocation*(this: Button, x, y: float) =
  this.bounds = nil

proc render*(this: Button, ctx: Target) =
  ctx.scale(this.scale.x, this.scale.y):
    this.sprite.render(ctx)
    this.getBounds().stroke(ctx)

