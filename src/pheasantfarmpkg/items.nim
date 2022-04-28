import tables
export tables

type
  Item* {.pure.} = enum
    PHEED
    WATER
    NEST

const ITEM_PRICES* = {
  PHEED: 1,
  WATER: 1,
  NEST: 15
}.toTable()

