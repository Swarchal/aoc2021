#[ --- Day 4: Giant Squid ---

# You're already almost 1.5km (almost a mile) below the surface of the ocean,
# already so deep that you can't see any sunlight. What you can see, however,
# is a giant squid that has attached itself to the outside of your submarine.
#
# Maybe it wants to play bingo?
#
# Bingo is played on a set of boards each consisting of a 5x5 grid of numbers
# Numbers are chosen at random, and the chosen number is marked on all boards
# on which it appears. (Numbers may not appear on all boards.) If all numbers
# in any row or any column of a board are marked, that board wins. (Diagonals
# don't count.)
#
# The submarine has a bingo subsystem to help passengers (currently, you and
# the giant squid) pass the time. It automatically generates a random order in
# which to draw numbers and a random set of boards (your puzzle input).
# For example:
#
# 7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1
#
# 22 13 17 11  0
#  8  2 23  4 24
# 21  9 14 16  7
#  6 10  3 18  5
#  1 12 20 15 19
#
#  3 15  0  2 22
#  9 18 13 17  5
# 19  8  7 25 23
# 20 11 10 24  4
# 14 21 16 12  6
#
# 14 21 17 24  4
# 10 16 15  9 19
# 18  8 23 26 20
# 22 11 13  6  5
#  2  0 12  3  7
#
# After the first five numbers are drawn (7, 4, 9, 5, and 11), there are no
# winners, but the boards are marked as follows (shown here adjacent to each
# other to save space):
#
# 22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
#  8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
# 21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
#  6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
#  1 12 20 15 19        14 21 16 12  6         2  0 12  3  7
#
# After the next six numbers are drawn (17, 23, 2, 0, 14, and 21), there are
# still no winners:
#
# 22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
#  8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
# 21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
#  6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
#  1 12 20 15 19        14 21 16 12  6         2  0 12  3  7
#
# Finally, 24 is drawn:
#
# 22 13 17 11  0         3 15  0  2 22        14 21 17 24  4
#  8  2 23  4 24         9 18 13 17  5        10 16 15  9 19
# 21  9 14 16  7        19  8  7 25 23        18  8 23 26 20
#  6 10  3 18  5        20 11 10 24  4        22 11 13  6  5
#  1 12 20 15 19        14 21 16 12  6         2  0 12  3  7
#
# At this point, the third board wins because it has at least one complete row
# or column of marked numbers (in this case, the entire top row is marked:
# 14 21 17 24 4).
#
# The score of the winning board can now be calculated. Start by finding the
# sum of all unmarked numbers on that board; in this case, the sum is 188.
# Then, multiply that sum by the number that was just called when the board
# won, 24, to get the final score, 188 * 24 = 4512.
#
# To guarantee victory against the giant squid, figure out which board will win
# first. What will your final score be if you choose that board?
]#

import std/[sequtils, strutils, math]


type
    Matrix = array[5, array[5, int]]
    Mask = array[5, array[5, bool]]

    Board = object
        values: Matrix
        mask: Mask

    Input = object
        numbers: seq[int]
        boards: seq[Board]


proc echo(v: Matrix) =
    for i in v:
        for j in i:
            stdout.write align($j, 3)
        stdout.write "\n"


proc echo(m: Mask) =
    for i in m:
        for j in i:
            stdout.write align($j, 6)
        stdout.write "\n"


func asRow[T](l: seq[T]): array[5, T] =
    ## convert known len seq to array, for parsing
    doAssert l.len == 5
    for idx, i in l:
        result[idx] = i


proc parseInput(file="input.txt"): Input =
    var input = file.readFile().splitLines()
    var boards: seq[Board]
    for i in 0..input.high-1:
        if input[i] == "":
            var b: Board
            for j in 1 .. 5:
                 b.values[j-1] = input[i+j].splitWhitespace.map(parseInt).asRow
            boards.add(b)
    let numbers = input[0].split(",").map(parseInt)
    return Input(numbers: numbers, boards: boards)


func markBoard(b: Board, val: int): Board =
    # why are Boards immutable??? this ruins everything
    var c = b
    for idx, i in b.values:
        for jdx, j in i:
            if j == val:
                c.mask[idx][jdx] = true
    return c


func isBingo(b: Board): bool =
    # check rows
    for row in b.mask:
        var trueCount = 0
        for i in row:
            if i:
                trueCount += 1
        if trueCount == 5:
            return true
    # check cols
    for i in 0..4:
        var trueCount = 0
        for idx, row in b.mask:
            if row[i]:
                trueCount += 1
        if trueCount == 5:
            return true
    return false


func sumUnmarked(b: Board): int =
    for i in 0..4:
        for j in 0..4:
            if not b.mask[i][j]:
                result += b.values[i][j]

proc main1() =
    var input = parseInput()
    for i in input.numbers:
        for idx, b in input.boards:
            var b = b.markBoard(i)
            input.boards[idx] = b
            if b.isBingo():
                echo b.sumUnmarked * i
                return

when isMainModule:
    main1()


#[ --- Part Two ---
#
# On the other hand, it might be wise to try a different strategy: let the
# giant squid win.
#
# You aren't sure how many bingo boards a giant squid could play at once, so
# rather than waste time counting its arms, the safe thing to do is to figure
# out which board will win last and choose that one. That way, no matter which
# boards it picks, it will win for sure.
#
# In the above example, the second board is the last to win, which happens after
# 13 is eventually called and its middle column is completely marked. If you
# were to keep playing until this point, the second board would have a sum of
# unmarked numbers equal to 148 for a final score of 148 * 13 = 1924.
#
# Figure out which board will win last. Once it wins, what would its final score be?
]#
import intsets

proc main2() =
    echo "part two"
    var won = initIntSet()
    var input2 = parseInput("input.txt")
    for i in input2.numbers:
        for idx, b in input2.boards:
            var b = b.markBoard(i)
            input2.boards[idx] = b
            if b.isBingo() and not (idx in won):
                won.incl(idx)
                echo b.sumUnmarked * i


when isMainModule:
    echo "\n\n"
    main2()

