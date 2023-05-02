import shade

var 
  fontIndex = -1
  font: Font

proc getFontIndex*(): int =
  if fontIndex == -1:
    let (i, font) = Fonts.load("./assets/fonts/mozart.ttf", 64)
    fontIndex = i
  return fontIndex

proc getFont*(): Font =
  if font == nil:
    font = Fonts[getFontIndex()]
  return font

