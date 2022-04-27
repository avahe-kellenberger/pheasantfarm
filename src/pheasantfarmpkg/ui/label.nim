import shade

import ui, fontloader

type
  LabelObj = object of UIElement
    text: string
    color: Color
    imageOfText: Image
    filter: Filter

  Label* = ref LabelObj

proc `=destroy`(this: var LabelObj)

proc initLabel*(
  label: Label,
  text: string,
  color: Color = BLACK,
  renderFilter: Filter = FILTER_LINEAR_MIPMAP
) =
  label.text = text
  label.color = color
  label.imageOfText = nil
  label.filter = renderFilter

proc newLabel*(
  text: string,
  color: Color = BLACK,
  renderFilter: Filter = FILTER_LINEAR_MIPMAP
): Label =
  result = Label()
  initLabel(result, text, color, renderFilter)

proc setText*(this: Label, text: string) =
  this.text = text
  if this.imageOfText != nil:
    freeImage(this.imageOfText)
    this.imageOfText = nil

proc setRenderFilter*(this: Label, filter: Filter) =
  this.filter = filter
  if this.imageOfText != nil:
    this.imageOfText.setImageFilter(this.filter)

method render*(this: Label, ctx: Target) =
  if this.imageOfText == nil:
    let surface = renderText_Blended_Wrapped(
      fontloader.getFont(),
      cstring this.text,
      this.color,
      # Passing in 0 means lines only wrap on newline chars.
      0
    )
    this.imageOfText = copyImageFromSurface(surface)
    this.imageOfText.setImageFilter(this.filter)
    freeSurface(surface)

  blit(this.imageOfText, nil, ctx, 0, 0)

proc `=destroy`(this: var LabelObj) =
  if this.imageOfText != nil:
    freeImage(this.imageOfText)

