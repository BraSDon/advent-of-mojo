from testing import assert_equal
from read import read
from collections import Set


fn main() raises:
    var input = read(8)
    var example = read(8, True)

    # assert_equal(part_one(example.value()), 40)
    assert_equal(part_one(input.value()), 123234)

    # assert_equal(part_two(example.value()), 25272)
    assert_equal(part_two(input.value()), 9259958565)

struct DSU:
    var parent: List[Int]
    var rank: List[Int]
    var size: List[Int]

    fn __init__(out self, n: Int):
        self.parent = [i for i in range(n)]
        self.rank = [0 for _ in range(n)]
        self.size = [1 for _ in range(n)]

    fn union(mut self, i: Int, j: Int):
        var pi = self.find(i)
        var pj = self.find(j)

        if pi == pj:
            return

        # pi has higher rank
        if self.rank[pi] < self.rank[pj]:
            var temp = pi
            pi = pj
            pj = temp

        self.parent[pj] = pi
        self.size[pi] += self.size[pj]
        self.size[pj] = 0

        if self.rank[pi] == self.rank[pj]:
            self.rank[pi] += 1

    fn find(mut self, i: Int) -> Int:
        if self.parent[i] != i:
            self.parent[i] = self.find(self.parent[i])
        return self.parent[i]

    fn is_one(self) -> Bool:
        var elems = len(self.parent)
        return elems in Set[Int](self.size)

    fn get_size(self) -> List[Int]:
        return self.size.copy()

@fieldwise_init
struct Point(Copyable, Movable):
    var x: Int
    var y: Int
    var z: Int

    fn __init__(out self, s: String) raises:
        var parts = s.split(",")
        assert_equal(len(parts), 3)
        return Point(
            x=atol(parts[0]),
            y=atol(parts[1]),
            z=atol(parts[2]),
        )

    fn distance(self, other: Point) -> Float64:
        var dx = Float64(self.x - other.x)
        var dy = Float64(self.y - other.y)
        var dz = Float64(self.z - other.z)
        return dx * dx + dy * dy + dz * dz

@fieldwise_init
struct Distance(Comparable, Copyable, Movable, Stringable):
    var i: Int
    var j: Int
    var distance: Float64

    fn __lt__(self, other: Distance) -> Bool:
        return self.distance < other.distance

    fn __eq__(self, other: Distance) -> Bool:
        return self.distance == other.distance

    fn __str__(self) -> String:
        return "i: " + String(self.i) + ", j: " + String(self.j) + ", distance: " + String(self.distance)

fn sorted_distances(points: List[Point]) -> List[Distance]:
    var result = List[Distance]()
    for i in range(len(points)):
        for j in range(i + 1, len(points)):
            result.append(Distance(
                i=i,
                j=j,
                distance=points[i].distance(points[j]),
            ))
    sort(result)
    return result^

fn part_one(input: List[String]) raises -> Int:
    var points = [Point(s) for s in input]
    var distances = sorted_distances(points)

    var dsu = DSU(len(points))
    for d in distances[:1000]:
        dsu.union(d.i, d.j)

    var sizes = dsu.get_size()
    sort(sizes)
    return sizes[-1] * sizes[-2] * sizes[-3]

fn part_two(input: List[String]) raises -> Int:
    var points = [Point(s) for s in input]
    var distances = sorted_distances(points)
    var dsu = DSU(len(points))
    var idx = 0
    while not dsu.is_one() and idx < len(distances):
        ref d = distances[idx]
        dsu.union(d.i, d.j)
        idx += 1

    ref last_dist = distances[idx - 1]
    var first_x = points[last_dist.i].x
    var second_x = points[last_dist.j].x
    return first_x * second_x
