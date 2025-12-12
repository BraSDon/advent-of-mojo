from testing import assert_equal, assert_true
from read import read

fn main() raises:
    var input = read(4)
    var example = read(4, True)

    assert_equal(part_one(example.value()), 13)
    assert_equal(part_one(input.value()), 1367)

    assert_equal(part_two(example.value()), 43)
    assert_equal(part_two(input.value()), 9144)

@fieldwise_init
struct Grid(Stringable, Copyable, Movable):
    var cells: List[List[Bool]]
    var width: Int
    var height: Int

    fn __init__(out self, width: Int, height: Int):
        self.width = width
        self.height = height
        self.cells = List[List[Bool]]()

        for _ in range(height + 2):
            var row = List[Bool]()
            for _ in range(width + 2):
                row.append(False)
            self.cells.append(row^)

    fn __init__(out self, input: List[String]) raises:
        var h = len(input)
        var w = len(input[0]) if h > 0 else 0
        self = self.__init__(width=w, height=h)

        for y in range(h):
            var line = input[y]
            for x in range(w):
                if line[x] == "@":
                    self[y, x] = True

    fn true_neighbors(self, x: Int, y: Int) -> Int:
        # Returns the number of adjacent True cells (up, down, left, right, diagonals)
        adjacent_coords = [
            (x - 1, y - 1), (x, y - 1), (x + 1, y - 1),
            (x - 1, y),                 (x + 1, y),
            (x - 1, y + 1), (x, y + 1), (x + 1, y + 1)
        ]
        count = 0
        for (nx, ny) in adjacent_coords:
            if self[ny, nx]:
                count += 1
        return count

    fn moveable(self) -> Grid:
        var res = Grid(width=self.width, height=self.height)

        for y in range(self.height):
            for x in range(self.width):
                if self[y, x] and self.true_neighbors(x, y) < 4:
                    res[y, x] = True
        return res^

    fn elements(self) -> Int:
        var count = 0
        for row in self.cells:
            for cell in row:
                if cell:
                    count += 1
        return count

    fn __getitem__(self, row: Int, col: Int) -> Bool:
        return self.cells[row + 1][col + 1]

    fn __setitem__(mut self, row: Int, col: Int, value: Bool):
        self.cells[row + 1][col + 1] = value

    fn __str__(self) -> String:
        var lines = List[String]()
        for row in self.cells:
            var line = ""
            for cell in row:
                line += "@" if cell else "."
            lines.append(line)
        return "\n".join(lines^)

    fn clean(mut self) -> Bool:
        var changed = False
        for y in range(self.height):
            for x in range(self.width):
                var new = self[y, x] and self.true_neighbors(x, y) >= 4
                if not changed and (new != self[y, x]):
                    changed = True
                self[y, x] = new
        return changed


fn part_one(input: List[String]) raises -> Int:
    var parsed = Grid(input)
    return parsed.moveable().elements()

fn part_two(input: List[String]) raises -> Int:
    var parsed = Grid(input)
    var start_elements = parsed.elements()
    while parsed.clean():
        pass
    return start_elements - parsed.elements()
