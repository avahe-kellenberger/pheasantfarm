# Package
version = "0.1.0"
author = "Einheit Technologies"
description = "Pheasant Farm"
license = "?"
srcDir = "src"
bin = @["pheasantfarm"]

# Dependencies
requires "nim >= 1.6.4"
requires "https://github.com/avahe-kellenberger/shade"

task runr, "Runs the game":
  exec "nim r -d:release src/pheasantfarm.nim"

task rund, "Runs the game in debug mode":
  exec "nim r -d:debug -d:collisionoutlines src/pheasantfarm.nim"

