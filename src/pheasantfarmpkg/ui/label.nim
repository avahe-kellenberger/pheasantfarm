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
  this.color = color
  if this.imageOfText != nil:
    freeImage(this.imageOfText)
    this.imageOfText = nil

proc setText*(this: Label, text: string) =
  this.text = text
  if this.imageOfText != nil:
    freeImage(this.imageOfText)
    this.imageOfText = nil

proc setRenderFilter*(this: Label, filter: Filter) =
  this.filter = filter
  if this.imageOfText != nil:
    this.imageOfText.setImageFilter(this.filter)

Label.renderAsChildOf(UIElement):
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

  blit(this.imageOfText, nil, ctx, 0, 0)

proc `=destroy`(this: var LabelObj) =
  if this.imageOfText != nil:
    freeImage(this.imageOfText)

