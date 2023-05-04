import shade
import fontloader
import ../hiscores

type
  HiscoresMenu* = ref object of UIComponent
    backButton*: UIImage
    scores: seq[UIImage]
    itemBgImage: Image
    font: Font

proc newHiscoresMenu*(): HiscoresMenu =
  result = HiscoresMenu()
  initUIComponent(UIComponent result)

  result.stackDirection = StackDirection.Vertical
  result.alignHorizontal = Alignment.Center
  result.alignVertical = Alignment.Start

  result.itemBgImage = Images.loadImage("./assets/hiscore_board.png").image
  result.font = Fonts.load("./assets/fonts/mozart.ttf", 86).font

  let titleImage = Images.loadImage("./assets/item_board.png").image
  let title = newUIImage(titleImage)
  title.alignVertical = Alignment.Center
  title.alignHorizontal = Alignment.Center
  title.scale = vector(1.2, 1.0)
  title.margin = 30.0
  result.addChild(title)

  let titleText = newText(result.font, "Hiscores", WHITE)
  titleText.processInputEvents = false
  title.addChild(titleText)

  result.addChild(title)

  result.backButton = newUIImage(titleImage)
  result.backButton.alignVertical = Alignment.Center
  result.backButton.alignHorizontal = Alignment.Center
  result.backButton.scale = vector(1.2, 1.0)
  result.backButton.margin = 30.0
  result.addChild(title)

  let backText = newText(result.font, "Back", WHITE)
  backText.processInputEvents = false
  result.backButton.addChild(backText)
  result.addChild(result.backButton)

proc populateScores*(this: HiscoresMenu) =
  this.removeChild(this.backButton)

  for score in this.scores:
    this.removeChild(score)

  let hiscores = getHiscores()
  for score in hiscores:
    let board = newUIImage(this.itemBgImage)
    board.alignVertical = Alignment.Center
    board.alignHorizontal = Alignment.Center
    board.margin = 30.0

    let name = newText(this.font, score.name & ": Day " & $score.day, WHITE)
    board.addChild(name)

    this.addChild(board)
    this.scores.add(board)

  this.addChild(this.backButton)

