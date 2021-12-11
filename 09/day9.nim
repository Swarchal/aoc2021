#[ --- Day 9: Smoke Basin ---
#
# These caves seem to be lava tubes. Parts are even still volcanically active;
# small hydrothermal vents release smoke into the caves that slowly settles
# like rain.
#
# If you can model how the smoke flows through the caves, you might be able to
# avoid it and be that much safer. The submarine generates a heightmap of the
# floor of the nearby caves for you (your puzzle input).
#
# Smoke flows to the lowest point of the area it's in. For example, consider
# the following heightmap:
#
# 2199943210
# 3987894921
# 9856789892
# 8767896789
# 9899965678
#
# Each number corresponds to the height of a particular location, where 9 is
# the highest and 0 is the lowest a location can be.
#
# Your first goal is to find the low points - the locations that are lower
# than any of its adjacent locations. Most locations have four adjacent
# locations (up, down, left, and right); locations on the edge or corner of
# the map have three or two adjacent locations, respectively.
# (Diagonal locations do not count as adjacent.)
#
# In the above example, there are four low points, all highlighted: two are in
# the first row (a 1 and a 0), one is in the third row (a 5), and one is in
# the bottom row (also a 5). All other locations on the heightmap have some
# lower adjacent location, and so are not low points.
#
# The risk level of a low point is 1 plus its height. In the above example,
# the risk levels of the low points are 2, 1, 6, and 6. The sum of the risk
# levels of all low points in the heightmap is therefore 15.
#
# Find all of the low points on your heightmap. What is the sum of the risk
# levels of all low points on your heightmap?
]#
import std/[strutils, sequtils]


type Matrix = seq[seq[int]]


proc readMatrix(file="input.txt"): Matrix =
  for line in file.lines:
    var row: seq[int]
    for i in line:
      row.add(parseInt($(i)))
    result.add(row)


func pad(m: Matrix, val= 10): Matrix =
  ## pad edges of Matrix `m` with val
  let newRowLen = m[0].len + 2
  result.add(val.repeat(newRowLen))
  for row in m:
    var newRow = row
    newRow.insert(@[val], pos=0)
    newRow.add(val)
    result.add(newRow)
  result.add(val.repeat(newRowLen))


func lowerthanAll(p: int, n: seq[int]): bool =
  for i in n:
    if p >= i:
      return false
  return true


func getLowVals(m: Matrix): seq[int] =
  ## get low point values
  let mPadded = m.pad()
  let nRows = mPadded.high
  let nCols = mPadded[0].high
  # iterate through inner matrix, ignore padding indices
  for yidx in 1..nRows-1:
    for xidx in 1..nCols-1:
      var point = mPadded[yidx][xidx]
      # get neighbouring vals of point
      var neighbours: seq[int]
      for nyidx in @[-1, 0, 1]:
        for nxidx in @[-1, 0, 1]:
          if nyidx.abs != nxidx.abs:
            neighbours.add(mPadded[yidx+nyidx][xidx+nxidx])
      if point.lowerThanAll(neighbours):
        result.add(point)


func riskLevel(lowPoints: seq[int]): int =
  for i in lowPoints:
    result += i+1


echo readMatrix("input.txt").getLowVals().riskLevel()


#[ --- Part Two ---
#
# Next, you need to find the largest basins so you know what areas are most
# important to avoid.
#
# A basin is all locations that eventually flow downward to a single low point.
# Therefore, every low point has a basin, although some basins are very small.
# Locations of height 9 do not count as being in any basin, and all other
# locations will always be part of exactly one basin.
#
# The size of a basin is the number of locations within the basin, including
# the low point. The example above has four basins.
#
# The top-left basin, size 3:
#
# 2199943210
# 3987894921
# 9856789892
# 8767896789
# 9899965678
#
# The top-right basin, size 9:
#
# 2199943210
# 3987894921
# 9856789892
# 8767896789
# 9899965678
#
# The middle basin, size 14:
#
# 2199943210
# 3987894921
# 9856789892
# 8767896789
# 9899965678
#
# The bottom-right basin, size 9:
#
# 2199943210
# 3987894921
# 9856789892
# 8767896789
# 9899965678
#
# Find the three largest basins and multiply their sizes together. In the above
# example, this is 9 * 14 * 9 = 1134.
#
# What do you get if you multiply together the sizes of the three largest
# basins?
]#

import std/[sets, hashes, algorithm]


type Coord = array[2, int]


func hash(c: Coord): Hash =
    var h: Hash = 0
    h = h !& hash(c[0])
    h = h !& hash(c[1])
    return !$h


func getLowCoords(m: Matrix): seq[Coord] =
  ## get low point co-ordinates
  let mPadded = m.pad()
  let nRows = mPadded.high
  let nCols = mPadded[0].high
  # iterate through inner matrix, ignore padding indices
  for yidx in 1..nRows-1:
    for xidx in 1..nCols-1:
      var point = mPadded[yidx][xidx]
      # get neighbouring vals of point
      var neighbours: seq[int]
      for nyidx in @[-1, 0, 1]:
        for nxidx in @[-1, 0, 1]:
          if nyidx.abs != nxidx.abs:
            neighbours.add(mPadded[yidx+nyidx][xidx+nxidx])
      if point.lowerThanAll(neighbours):
        result.add([yidx-1, xidx-1])


proc calcBasinSize(m: Matrix, p: Coord, points: var HashSet[Coord]): HashSet[Coord] =
  points.incl(p)
  for nyidx in @[-1, 0, 1]:
    for nxidx in @[-1, 0, 1]:
      if nyidx.abs != nxidx.abs:
        var nextPoint: Coord = [p[0]+nyidx, p[1]+nxidx]
        if nextPoint in points: continue
        try:
          if m[nextPoint[0]][nextPoint[1]] == 9: continue
        except IndexError: continue
        discard calcBasinSize(m, nextPoint, points)
  return points


let m = readMatrix("input.txt")
let lowCoords = m.getLowCoords()


var basinSizes: seq[int]

for c in lowCoords:
  var points: HashSet[Coord]
  let basin = calcBasinSize(m, c, points)
  basinSizes.add(basin.len)

basinSizes.sort()
echo basinSizes[^3..basinSizes.high].foldl(a * b)
