import shade

import ui, fontloader

type
  LabelObj = object of UIElement
    text: string
    color: Color
    imageOfText: Image
    filter: Filter
    font*: Font

  Label* = ref LabelObj

proc `=destroy`(this: var LabelObj)

proc initLabel*(
  label: Label,
  text: string,
  color: Color = BLACK,
  renderFilter: Filter = FILTER_LINEAR_MIPMAP
) =
  initUIElement(UIElement(label))
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

proc setColor*(this: Label, color: Color) =
  if this.color == color:
    return
  this.color = color
  if this.imageOfText != nil:
    this.imageOfText.setColor(this.color)

proc setText*(this: Label, text: string) =
  if this.text == text:
    return
  this.text = text
  if this.imageOfText != nil:
    freeImage(this.imageOfText)
    this.imageOfText = nil

proc setRenderFilter*(this: Label, filter: Filter) =
  this.filter = filter
  if this.imageOfText != nil:
    this.imageOfText.setImageFilter(this.filter)

method render*(this: Label, ctx: Target, offsetX: float = 0, offsetY: float = 0) =
  if not this.visible:
    return

  if this.imageOfText == nil:
    let font =
      if this.font != nil:
        this.font
      else:
        fontloader.getFont()

    let surface = renderText_Blended_Wrapped(
      font,
      cstring this.text,
      this.color,
      # Passing in 0 means lines only wrap on newline chars.
      0
    )
    this.imageOfText = copyImageFromSurface(surface)
    this.imageOfText.setImageFilter(this.filter)
    freeSurface(surface)

  blit(this.imageOfText, nil, ctx, offsetX, offsetY)

proc `=destroy`(this: var LabelObj) =
  if this.imageOfText != nil:
    freeImage(this.imageOfText)

