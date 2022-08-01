import std/os

# Package
version = "0.1.0"
author = "Einheit Technologies"
description = "Pheasant Farm"
license = "?"
srcDir = "src"
bin = @["pheasantfarm"]

# Dependencies
requires "nim >= 1.6.6"
requires "https://github.com/einheit-tech/shade#24427e822241ecc15280a9ae9b3d20f4a45b4751"

import os

switch("multimethods", "on")
switch("import", "std/lenientops")

task runr, "Runs the game":
  exec "nim r -d:release src/pheasantfarm.nim"

task rund, "Runs the game in debug mode":
  exec "nim r -d:debug -d:collisionoutlines src/pheasantfarm.nim"

task runprof, "Runs the game with profiling":
  exec "nim r -d:release --profiler:on --stacktrace:on src/pheasantfarm.nim"

task deploy, "Deploys a production release of the game":
  exec "nim c --app:gui -d:release --outdir:dist/pheasantfarm src/pheasantfarm.nim"
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
