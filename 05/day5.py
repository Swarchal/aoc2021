from collections import namedtuple, defaultdict, Counter
from itertools import cycle

Point = namedtuple("Point", "x y")

def is_straight(p1, p2):
    return p1.x == p2.x or p1.y == p2.y

def fill2line(p1, p2):
    xs, ys = zip_range(p1.x, p2.x), zip_range(p1.y, p2.y)
    return [Point(x, y) for x, y in zip(xs, ys)]

def zip_range(x, y):
    r = range(x, y+1) if x < y else range(x, y-1, -1)
    return cycle(r) if len(r) == 1 else r

def find_overlaps(lines):
    point_counts = Counter([j for i in lines for j in i])
    return len([i for i, j in point_counts.items() if j >= 2])

if __name__ == "__main__":
    with open("input.txt") as f:
        lines = [i.split(' -> ') for i in f.read().splitlines()]
        x = [[Point(*map(int, j.split(','))) for j in i] for i in lines]

    print("Part1:", find_overlaps([fill2line(*i) for i in x if is_straight(*i)]))
    print("Part2:", find_overlaps([fill2line(*i) for i in x]))
