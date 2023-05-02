import std/[os, strformat]

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

proc deploy(sharedLibExt: string, extraBuildFlags: string = "") =
  exec fmt"nim c {extraBuildFlags} --app:gui -d:release --outdir:dist/pheasantfarm src/pheasantfarm.nim"
  cpDir("assets", "dist/pheasantfarm/assets")
  for sharedLibFile in listFiles(".usr/lib"):
    if sharedLibFile.endsWith(sharedLibExt):
      let filename = extractFilename(sharedLibFile)
      cpFile(sharedLibFile, "dist/pheasantfarm/" & filename)

task deploy_linux, "Deploys a production release of the game for Windows":
  deploy(".so")

task deploy_windows, "Deploys a production release of the game for Windows":
  deploy(".dll", "-d:mingw")

task deploy, "Deploys a production release of the game":
  when defined(linux):
    deploy(".so")
  else:
    deploy(".dll", "-d:mingw")

