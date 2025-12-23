from testing import assert_equal
from read import read
from collections import Set
from collections.interval import Interval


fn main() raises:
    var input = read(9)
    var example = read(9, True)

    assert_equal(part_one(example.value()), 50)
    assert_equal(part_one(input.value()), 4740155680)

    assert_equal(part_two(example.value()), 24)
    assert_equal(part_two(input.value()), 1543501936)

@fieldwise_init
@register_passable("trivial")
struct Point:
    var x: Int
    var y: Int

    fn __init__(out self, input: String) raises:
        var parts = input.split(",")
        self.x = atol(parts[0])
        self.y = atol(parts[1])

    @always_inline
    fn dist(self, other: Point) -> Int:
        return abs(self.x - other.x) + abs(self.y - other.y)

    fn area(self, other: Point) -> Int:
        var x_diff = abs(self.x - other.x) + 1
        var y_diff = abs(self.y - other.y) + 1
        return x_diff * y_diff

alias VEdge = Tuple[Int, Interval[Int]]
struct Polygon:
    var points: List[Point]
    var vedges: List[VEdge]
    
    fn __init__(out self, points: List[Point]) raises:
        self.points = points.copy()
        self.vedges = Self._get_vertical_edges(self.points)

    @staticmethod
    fn _get_vertical_edges(points: List[Point]) -> List[VEdge]:
        var edges = List[VEdge]()
        var n = len(points)
        for i in range(n):
            ref p1 = points[i]
            ref p2 = points[(i + 1) % n]
            if p1.x == p2.x:
                var y_start = min(p1.y, p2.y)
                var y_end = max(p1.y, p2.y)
                edges.append((p1.x, Interval[Int](y_start, y_end)))
        return edges^


struct CompressedGrid(Movable, Copyable):
    var grid: List[List[Int]]
    var prefix: List[List[Int]]
    var xs: List[Int]
    var ys: List[Int]
    var x_map: Dict[Int, Int]
    var y_map: Dict[Int, Int]
    var width: Int
    var height: Int


    fn __init__(out self, polygon: Polygon) raises:
        ref poly_points = polygon.points
        var xs = Set[Int]()
        var ys = Set[Int]()
        for p in poly_points:
            xs.add(p.x)
            ys.add(p.y)

        var xs_list = List[Int](xs)
        var ys_list = List[Int](ys)
        sort(xs_list)
        sort(ys_list)

        self.xs = xs_list^
        self.ys = ys_list^

        # Map from original coordinate to index in compressed list
        self.x_map = {x: i for i, x in enumerate(self.xs)}
        self.y_map = {y: i for i, y in enumerate(self.ys)}

        # Space between the points
        self.width = len(self.xs) - 1
        self.height = len(self.ys) - 1

        # For each space between points, we store if its inside 1 or outside 0 the polygon
        self.grid = [[Int(0) for _ in range(self.height)] for _ in range(self.width)]

        # Pad both dimensions for easier prefix sum calculations
        self.prefix = [[Int(0) for _ in range(self.height + 1)] for _ in range(self.width + 1)]

        self._fill_grid(polygon)
        self._build_prefix_sum()

    fn _fill_grid(mut self, polygon: Polygon) raises:
        # Scanline algorithm
        # Go row-slab by row-slab (interval between two ys)
        # Get all vertical edges that intersect this slab (active edges)
        # Start of with outside the polygon, then flip inside/outside at each edge

        ref vedges = polygon.vedges
        for y_idx in range(self.height):
            var y_start = self.ys[y_idx]
            var y_end = self.ys[y_idx + 1]

            var row = Interval[Int](y_start, y_end) # Implicitly spans the entire x-axis

            # Store the x-coordinates of active edges (those that completely span this row-slab)
            # Those are the x-coordinates where we flip inside/outside
            var active_xs = List[Int]()
            for edge in vedges:
                var edge_x = edge[0]
                var edge_y_interval = edge[1]
                if row in edge_y_interval:
                    active_xs.append(edge_x)

            sort(active_xs)

            # Inside between 0th and 1st edge, outside between 1st and 2nd, etc.
            # NOTE: we can safely assume that len(active_xs) % 2 == 0 for valid polygons
            for i in range(0, len(active_xs), 2):
                var x_start = active_xs[i]
                var x_end = active_xs[i + 1] # SAFE

                var x_start_idx = self.x_map.get(x_start).value()
                var x_end_idx = self.x_map.get(x_end).value()

                for x_idx in range(x_start_idx, x_end_idx):
                    self.grid[x_idx][y_idx] = 1 # Inside the polygon


    fn _build_prefix_sum(mut self):
        for x in range(self.width):
            for y in range(self.height):
                var area = 0
                if self.grid[x][y] == 1:
                    # SAFE, because self.width = len(self.xs) - 1
                    var dx = self.xs[x + 1] - self.xs[x]
                    var dy = self.ys[y + 1] - self.ys[y]
                    area = dx * dy

                # +1 because of padding
                self.prefix[x + 1][y + 1] = self.prefix[x][y + 1] + self.prefix[x + 1][y] - self.prefix[x][y] + area

    fn _rectangle_inside_polygon(self, x_start: Int, y_start: Int, x_end: Int, y_end: Int) -> Bool:
        var x_start_idx = self.x_map.get(x_start).value()
        var x_end_idx = self.x_map.get(x_end).value()
        var y_start_idx = self.y_map.get(y_start).value()
        var y_end_idx = self.y_map.get(y_end).value()

        var area = self.prefix[x_end_idx][y_end_idx] - self.prefix[x_start_idx][y_end_idx] - self.prefix[x_end_idx][y_start_idx] + self.prefix[x_start_idx][y_start_idx]
        
        var total_area = (x_end - x_start) * (y_end - y_start)
        return area == total_area

    fn rectangle_inside(self, p_i: Point, p_j: Point) -> Bool:
        return self._rectangle_inside_polygon(p_i.x, p_i.y, p_j.x, p_j.y)

fn solve(points: List[Point], grid: Optional[CompressedGrid]) raises -> Int:
    var n = len(points)
    var max_dist = 0
    var idx = Tuple[Int, Int](0, 0)
    for i in range(n):
        ref p_i = points[i]
        for j in range(i + 1, n):
            var d = p_i.dist(points[j])
            var cond = True
            if grid:
                ref grid = grid.value()
                cond = grid.rectangle_inside(p_i, points[j])
            if d > max_dist and cond:
                max_dist = d
                idx = (i, j)
    return points[idx[0]].area(points[idx[1]])

fn part_one(input: List[String]) raises -> Int:
    var points = [Point(line) for line in input]
    return solve(points, Optional[CompressedGrid](None))

fn part_two(input: List[String]) raises -> Int:
    var points = [Point(line) for line in input]
    var polygon = Polygon(points)
    var cgrid = CompressedGrid(polygon)
    return solve(points, Optional(cgrid^))
