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
    var num_components: Int

    fn __init__(out self, n: Int):
        self.parent = [i for i in range(n)]
        self.rank = [0 for _ in range(n)]
        self.size = [1 for _ in range(n)]
        self.num_components = n

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
        self.num_components -= 1

        if self.rank[pi] == self.rank[pj]:
            self.rank[pi] += 1

    fn find(mut self, i: Int) -> Int:
        if self.parent[i] != i:
            self.parent[i] = self.find(self.parent[i])
        return self.parent[i]

alias Vec3 = SIMD[DType.int, 4]
struct Point(Copyable, Movable):
    var vec: Vec3

    fn __init__(out self, s: String) raises:
        var parts = s.split(",")
        self.vec = Vec3(atol(parts[0]), atol(parts[1]), atol(parts[2]), 0)

    fn x(self) -> Int:
        return Int(self.vec[0])

    @always_inline
    fn distance_to(self, other: Point) -> Int:
        var diff = self.vec - other.vec
        return Int((diff * diff).reduce_add())

@register_passable("trivial")
struct Distance(Comparable):
    """
    Bit-packed representation of an edge.
    Layout: [ Distance (40 bits) | i (12 bits) | j (12 bits) ].
    """
    var data: UInt64

    alias INDEX_MASK = 0xFFF # 12 bits
    alias INDEX_SHIFT = 12
    alias DIST_SHIFT = 24

    @always_inline
    fn __init__(out self, i: Int, j: Int, dist: Int):
        self.data = (UInt64(dist) << self.DIST_SHIFT) | (UInt64(i) << self.INDEX_SHIFT) | UInt64(j)

    @always_inline
    fn i(self) -> Int: 
        return Int((self.data >> self.INDEX_SHIFT) & self.INDEX_MASK)

    @always_inline
    fn j(self) -> Int: 
        return Int(self.data & self.INDEX_MASK)

    @always_inline
    fn __lt__(self, other: Distance) -> Bool: 
        return self.data < other.data

    @always_inline
    fn __eq__(self, other: Distance) -> Bool: 
        return self.data == other.data

fn get_sorted_distances(points: List[Point]) -> List[Distance]:
    var n = len(points)
    var num_pairs = (n * (n - 1)) // 2
    var result = List[Distance](capacity=num_pairs)
    for i in range(n):
        ref p_i = points[i]
        for j in range(i + 1, n):
            var d = p_i.distance_to(points[j])
            result.append(Distance(i, j, d))
    sort(result)
    return result^

fn part_one(input: List[String]) raises -> Int:
    var points = [Point(line) for line in input]
    var distances = get_sorted_distances(points)
    var dsu = DSU(len(points))
    for k in range(1000):
        var edge = distances[k]
        dsu.union(edge.i(), edge.j())

    sort(dsu.size)
    return dsu.size[-1] * dsu.size[-2] * dsu.size[-3]

fn part_two(input: List[String]) raises -> Int:
    var points = [Point(line) for line in input]
    var distances = get_sorted_distances(points)
    var dsu = DSU(len(points))
    var last_edge_idx = 0
    for k in range(len(distances)):
        var edge = distances[k]
        dsu.union(edge.i(), edge.j())
        last_edge_idx = k
        if k >= 1000 and dsu.num_components == 1:
            break

    var final_edge = distances[last_edge_idx]
    return points[final_edge.i()].x() * points[final_edge.j()].x()
