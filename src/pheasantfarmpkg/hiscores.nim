import std/[algorithm, os, base64, strutils, parseutils, sequtils]

const
  hiscoresFile = "hiscores.pf"
  maxSavedHiscores = 5

type Hiscore = object
  name*: string
  day*: int

proc hiscore(name: string, day: int): Hiscore =
  Hiscore(name: name, day: day)

var
  file: File = nil
  # Sorted from lowest to highest score
  hiscores: seq[Hiscore]

proc sortHiscores() =
  ## Sorts hiscores from lowest to highest score.
  hiscores = hiscores.sortedByIt(it.day)

proc populateHiscores() =
  if not fileExists(hiscoresFile):
    writeFile(hiscoresFile, "")

  try:
    file = open(hiscoresFile, fmReadWriteExisting)
    let data = readAll(file)
    for line in data.splitLines:
      if line.len > 0:
        let split = decode(line).split(":")
        hiscores.add(hiscore(split[0], parseInt(split[1])))
    sortHiscores()
  finally:
    close(file)

proc saveScoresToFile() =
  try:
    file = open(hiscoresFile, fmWrite)
    for score in hiscores:
      writeLine(file, encode(score.name & ":" & $score.day))
  finally:
    close(file)

proc isNewHighScore*(day: int): bool =
  if file == nil:
    populateHiscores()

  if hiscores.len > 0:
    sortHiscores()

  return hiscores.len < maxSavedHiscores or hiscores[0].day < day

proc saveHiscore*(name: string, day: int) =
  if not isNewHighScore(day):
    return

  if hiscores.len == 0:
    hiscores.add(hiscore(name, day))
  else:
    # Find where to insert the new score, if anywhere.
    var index = -1
    for i, score in hiscores:
      index = i
      if score.day >= day:
        break

    # Insert score and remove last hiscore entry from list.
    if index >= 0:
      hiscores.insert(hiscore(name, day), index)

    if hiscores.len > maxSavedHiscores:
      hiscores = hiscores[^maxSavedHiscores .. ^1]

  saveScoresToFile()

proc getHiscores*(): lent seq[Hiscore] =
  if file == nil:
    populateHiscores()
  return hiscores

when isMainModule:
  saveHiscore("PHEASANT", 4)
  saveHiscore("PHEASANT 27", 18)
  saveHiscore("TONY", 9)
  saveHiscore("JOLENE", 19)
  saveHiscore("AVAHE", 203)
  saveHiscore("BILLY BOB", 2)

  for score in hiscores:
    echo score.name & " - Day " & $score.day

