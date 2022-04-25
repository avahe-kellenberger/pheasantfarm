## A FencedArea is the area in which pheasants can roam.
## It must be outlined by a fence sprite,
## which is not passable by pheasants or the player.

# TODO: How will this work into the grid system?
# Does it need to be?
# Ans: Would be easier for physics reasons.

import shade

type
  FencedArea* = ref object
    sizeInTiles: IVector

proc newFencedArea*(sizeInTiles: IVector): FencedArea =
  result = FencedArea()
  result.sizeInTiles = sizeInTiles

