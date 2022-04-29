import std/os

# Package
version = "0.1.0"
author = "Einheit Technologies"
description = "Pheasant Farm"
license = "?"
srcDir = "src"
bin = @["pheasantfarm"]

# Dependencies
requires "nim >= 1.6.4"
requires "https://github.com/avahe-kellenberger/shade#head"

task runr, "Runs the game":
  exec "nim r -d:release src/pheasantfarm.nim"

task rund, "Runs the game in debug mode":
  exec "nim r -d:debug -d:collisionoutlines src/pheasantfarm.nim"

task deploy, "Deploys a production release of the game":
  exec "nim c -d:release --outdir:dist/pheasantfarm src/pheasantfarm.nim"
  cpDir("assets", "dist/pheasantfarm/assets")
  let sharedLibExt =
    when defined(linux):
      ".so"
    else:
      ".dll"
  for sharedLibFile in listFiles(".usr/lib"):
    if sharedLibFile.endsWith(sharedLibExt):
      let filename = extractFilename(sharedLibFile)
      cpFile(sharedLibFile, "dist/pheasantfarm/" & filename)
