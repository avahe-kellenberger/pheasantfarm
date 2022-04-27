import shade

var 
  fontIndex = -1
  font: Font

proc getFontIndex*(): int =
  if fontIndex == -1:
    let (i, font) = Fonts.load("./assets/fonts/kennypixel.ttf", 72)
    fontIndex = i
  return fontIndex

proc getFont*(): Font =
  if font == nil:
    font = Fonts[getFontIndex()]
  return font

