import math, strformat

proc formatInt*(num, digits: int): string =
  let maxValue = 10 ^ digits - 1
  result = alignString($min(num, maxValue), digits, '/', '0')

